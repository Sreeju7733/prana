import 'package:drift/drift.dart';
import '../database/app_database.dart';
import 'base_repository.dart';

/// Repository for medication CRUD operations with outbox-backed sync.
/// Screens talk ONLY to this repository — never to api_service.dart directly.
class MedicationRepository extends BaseRepository {
  final String _profileUuid;

  MedicationRepository(super.db, super.database, this._profileUuid);

  // ---------- Reads (always from local DB, instant + offline-safe) ----------

  /// Watch medications — live stream from local DB
  Stream<List<Medication>> watchMedications() {
    return db.watchMedications(_profileUuid);
  }

  /// Get current medications snapshot
  Future<List<Medication>> getMedications() async {
    return await db.getMedications(_profileUuid);
  }

  /// Get a single medication by UUID
  Future<Medication?> getMedicationByUuid(String uuid) async {
    final results = await (database.select(database.medications)
          ..where((t) => t.uuid.equals(uuid)))
        .get();
    return results.isNotEmpty ? results.first : null;
  }

  // ---------- Writes (local first, then outbox) ----------

  /// Create a new medication — writes to local DB, marks pending, adds to outbox
  Future<String> createMedication({
    required String name,
    required String dose,
    required String frequency,
    String? reason,
    bool isActive = true,
    String? doseValue,
    String? doseUnit,
    String? startedAt,
  }) async {
    final uuid = AppDatabase.generateUuid();
    final startedAtParsed = startedAt != null ? DateTime.tryParse(startedAt) : null;

    await db.saveMedication(MedicationsCompanion.insert(
      uuid: uuid,
      profileUuid: _profileUuid,
      name: name,
      dose: dose,
      frequency: frequency,
      reason: Value(reason),
      isActive: Value(isActive),
      startedAt: Value(startedAtParsed),
      syncStatus: const Value('pending'),
    ));

    // Add to outbox for sync
    await addToOutbox(
      entity: 'medication',
      action: 'create',
      payload: {
        'uuid': uuid,
        'name': name,
        'dose': dose,
        'frequency': frequency,
        'reason': reason,
        'is_active': isActive,
        'dose_value': doseValue,
        'dose_unit': doseUnit,
        'started_at': startedAt,
      },
    );

    return uuid;
  }

  /// Update an existing medication — local first, then outbox
  Future<void> updateMedication({
    required String uuid,
    String? name,
    String? dose,
    String? frequency,
    String? reason,
    bool? isActive,
    String? doseValue,
    String? doseUnit,
  }) async {
    final existing = await getMedicationByUuid(uuid);
    if (existing == null) return;

    await (database.update(database.medications)
          ..where((t) => t.uuid.equals(uuid)))
        .write(MedicationsCompanion(
      name: name != null ? Value(name) : const Value.absent(),
      dose: dose != null ? Value(dose) : const Value.absent(),
      frequency: frequency != null ? Value(frequency) : const Value.absent(),
      reason: reason != null ? Value(reason) : const Value.absent(),
      isActive: isActive != null ? Value(isActive) : const Value.absent(),
      updatedAt: Value(DateTime.now()),
      syncStatus: const Value('pending'),
    ));

    // Add to outbox for sync
    await addToOutbox(
      entity: 'medication',
      action: 'update',
      payload: {
        'uuid': uuid,
        'name': name,
        'dose': dose,
        'frequency': frequency,
        'reason': reason,
        'is_active': isActive,
        'dose_value': doseValue,
        'dose_unit': doseUnit,
      },
    );
  }

  /// Soft-delete a medication — mark deleted, add to outbox, remove after sync
  Future<void> deleteMedication(String uuid) async {
    // Hard delete from local table (outbox tracks it)
    await (database.delete(database.medications)
          ..where((t) => t.uuid.equals(uuid)))
        .go();

    // Add to outbox for sync
    await addToOutbox(
      entity: 'medication',
      action: 'delete',
      payload: {'uuid': uuid},
    );
  }

  /// Hard-delete after successful sync (called by sync layer)
  Future<void> hardDeleteMedication(String uuid) async {
    await (database.delete(database.medications)
          ..where((t) => t.uuid.equals(uuid)))
        .go();
  }
}