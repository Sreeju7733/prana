import 'package:drift/drift.dart';
import '../database/app_database.dart';
import 'base_repository.dart';

/// Repository for medical condition CRUD operations with outbox-backed sync.
class ConditionRepository extends BaseRepository {
  final String _profileUuid;

  ConditionRepository(super.db, super.database, this._profileUuid);

  // ---------- Reads ----------

  Stream<List<Condition>> watchConditions() {
    return db.watchConditions(_profileUuid);
  }

  Future<List<Condition>> getConditions() async {
    return await db.getConditions(_profileUuid);
  }

  Future<Condition?> getConditionByUuid(String uuid) async {
    final results = await (database.select(database.conditions)
          ..where((t) => t.uuid.equals(uuid)))
        .get();
    return results.isNotEmpty ? results.first : null;
  }

  // ---------- Writes ----------

  Future<String> createCondition({
    required String name,
    required DateTime diagnosedAt,
    String status = 'active',
    String? notes,
  }) async {
    final uuid = AppDatabase.generateUuid();

    await db.saveCondition(ConditionsCompanion.insert(
      uuid: uuid,
      profileUuid: _profileUuid,
      name: name,
      diagnosedAt: diagnosedAt,
      status: status,
      notes: Value(notes),
      syncStatus: const Value('pending'),
    ));

    await addToOutbox(
      entity: 'condition',
      action: 'create',
      payload: {
        'uuid': uuid,
        'name': name,
        'diagnosed_at': diagnosedAt.toIso8601String(),
        'status': status,
        'notes': notes,
      },
    );

    return uuid;
  }

  Future<void> updateCondition({
    required String uuid,
    String? name,
    String? status,
    String? notes,
  }) async {
    await (database.update(database.conditions)
          ..where((t) => t.uuid.equals(uuid)))
        .write(ConditionsCompanion(
      name: name != null ? Value(name) : const Value.absent(),
      status: status != null ? Value(status) : const Value.absent(),
      notes: notes != null ? Value(notes) : const Value.absent(),
      updatedAt: Value(DateTime.now()),
      syncStatus: const Value('pending'),
    ));

    await addToOutbox(
      entity: 'condition',
      action: 'update',
      payload: {
        'uuid': uuid,
        'name': name,
        'status': status,
        'notes': notes,
      },
    );
  }

  /// Soft-delete — remove from local table, add to outbox
  Future<void> deleteCondition(String uuid) async {
    await (database.delete(database.conditions)
          ..where((t) => t.uuid.equals(uuid)))
        .go();

    await addToOutbox(
      entity: 'condition',
      action: 'delete',
      payload: {'uuid': uuid},
    );
  }

  Future<void> hardDeleteCondition(String uuid) async {
    await (database.delete(database.conditions)
          ..where((t) => t.uuid.equals(uuid)))
        .go();
  }
}