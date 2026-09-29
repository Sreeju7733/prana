import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../database/database_service.dart';
import 'base_repository.dart';

/// Repository for allergy CRUD operations with outbox-backed sync.
class AllergyRepository extends BaseRepository {
  final String _profileUuid;

  AllergyRepository(DatabaseService db, AppDatabase database, this._profileUuid)
      : super(db, database);

  // ---------- Reads ----------

  Stream<List<Allergy>> watchAllergies() {
    return db.watchAllergies(_profileUuid);
  }

  Future<List<Allergy>> getAllergies() async {
    return await db.getAllergies(_profileUuid);
  }

  Future<Allergy?> getAllergyByUuid(String uuid) async {
    final results = await (database.select(database.allergies)
          ..where((t) => t.uuid.equals(uuid)))
        .get();
    return results.isNotEmpty ? results.first : null;
  }

  // Get critical (severe) allergies
  Future<List<Allergy>> getCriticalAllergies() async {
    final all = await getAllergies();
    return all.where((a) => a.isCritical).toList();
  }

  // ---------- Writes ----------

  Future<String> createAllergy({
    required String allergen,
    required String severity,
    String? reaction,
    bool isCritical = false,
    DateTime? diagnosedAt,
  }) async {
    final uuid = AppDatabase.generateUuid();

    await db.saveAllergy(AllergiesCompanion.insert(
      uuid: uuid,
      profileUuid: _profileUuid,
      allergen: allergen,
      severity: severity,
      reaction: Value(reaction),
      isCritical: Value(isCritical),
      diagnosedAt: Value(diagnosedAt),
      syncStatus: Value('pending'),
    ));

    await addToOutbox(
      entity: 'allergy',
      action: 'create',
      payload: {
        'uuid': uuid,
        'allergen': allergen,
        'severity': severity,
        'reaction': reaction,
        'is_critical': isCritical,
        'diagnosed_at': diagnosedAt?.toIso8601String(),
      },
    );

    return uuid;
  }

  Future<void> updateAllergy({
    required String uuid,
    String? allergen,
    String? severity,
    String? reaction,
    bool? isCritical,
  }) async {
    await (database.update(database.allergies)
          ..where((t) => t.uuid.equals(uuid)))
        .write(AllergiesCompanion(
      allergen: allergen != null ? Value(allergen) : const Value.absent(),
      severity: severity != null ? Value(severity) : const Value.absent(),
      reaction: reaction != null ? Value(reaction) : const Value.absent(),
      isCritical: isCritical != null ? Value(isCritical) : const Value.absent(),
      updatedAt: Value(DateTime.now()),
      syncStatus: const Value('pending'),
    ));

    await addToOutbox(
      entity: 'allergy',
      action: 'update',
      payload: {
        'uuid': uuid,
        'allergen': allergen,
        'severity': severity,
        'reaction': reaction,
        'is_critical': isCritical,
      },
    );
  }

  /// Soft-delete — remove from local table, add to outbox
  Future<void> deleteAllergy(String uuid) async {
    await (database.delete(database.allergies)
          ..where((t) => t.uuid.equals(uuid)))
        .go();

    await addToOutbox(
      entity: 'allergy',
      action: 'delete',
      payload: {'uuid': uuid},
    );
  }

  /// Hard-delete after successful server sync
  Future<void> hardDeleteAllergy(String uuid) async {
    await (database.delete(database.allergies)
          ..where((t) => t.uuid.equals(uuid)))
        .go();
  }
}