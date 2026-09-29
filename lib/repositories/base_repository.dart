import 'dart:convert';
import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../database/database_service.dart';

/// Base repository providing outbox-backed local-first operations.
/// All writes go to the local DB first, mark syncStatus=pending,
/// and create an outbox entry. Reads always come from the local DB.
abstract class BaseRepository {
  final DatabaseService db;
  final AppDatabase database;

  BaseRepository(DatabaseService db, AppDatabase database)
      : db = db,
        database = database;

  // ---------- Outbox helpers ----------

  /// Add an entry to the outbox table for later sync
  Future<void> addToOutbox({
    required String entity,
    required String action,
    required Map<String, dynamic> payload,
    String? serverId,
  }) async {
    final uuid = AppDatabase.generateUuid();
    await database.into(database.outbox).insert(OutboxCompanion.insert(
      uuid: uuid,
      entity: entity,
      action: action,
      payload: jsonEncode(payload),
      serverId: serverId != null ? Value(serverId) : const Value.absent(),
    ));
  }

  /// Get all pending outbox entries
  Future<List<OutboxData>> getPendingOutbox() async {
    return await (database.select(database.outbox)
          ..where((t) => t.syncStatus.equals('pending'))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  /// Get all outbox entries (including synced/failed)
  Future<List<OutboxData>> getAllOutbox() async {
    return await (database.select(database.outbox)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  /// Stream of pending outbox count
  Stream<int> watchPendingOutboxCount() {
    return (database.select(database.outbox)
          ..where((t) => t.syncStatus.equals('pending')))
        .watch()
        .map((rows) => rows.length);
  }

  /// Mark an outbox entry as synced
  Future<void> markOutboxSynced(int outboxId) async {
    await (database.update(database.outbox)
          ..where((t) => t.id.equals(outboxId)))
        .write(const OutboxCompanion(syncStatus: Value('synced')));
  }

  /// Mark an outbox entry as failed and increment attempts
  Future<void> markOutboxFailed(int outboxId) async {
    final entries = await (database.select(database.outbox)
          ..where((t) => t.id.equals(outboxId)))
        .get();
    if (entries.isNotEmpty) {
      final entry = entries.first;
      await (database.update(database.outbox)
            ..where((t) => t.id.equals(outboxId)))
          .write(OutboxCompanion(
            attempts: Value(entry.attempts + 1),
            syncStatus: const Value('failed'),
          ));
    }
  }

  /// Delete a synced outbox entry
  Future<void> deleteOutboxEntry(int outboxId) async {
    await (database.delete(database.outbox)
          ..where((t) => t.id.equals(outboxId)))
        .go();
  }

  /// Clear all synced outbox entries
  Future<void> clearSyncedOutbox() async {
    await (database.delete(database.outbox)
          ..where((t) => t.syncStatus.equals('synced')))
        .go();
  }

  /// Drain the outbox: process all pending entries via a callback
  /// Returns the number of successfully synced entries
  Future<int> drainOutbox(
    Future<bool> Function(OutboxData entry) syncEntry,
  ) async {
    final pending = await getPendingOutbox();
    int synced = 0;
    for (final entry in pending) {
      try {
        final success = await syncEntry(entry);
        if (success) {
          await markOutboxSynced(entry.id);
          synced++;
        } else {
          await markOutboxFailed(entry.id);
        }
      } catch (_) {
        await markOutboxFailed(entry.id);
      }
    }
    return synced;
  }

  // ---------- Sync status helpers ----------

  /// Mark a row as synced by table name and UUID
  Future<void> markRowSynced(String table, String uuid) async {
    await db.markAsSynced(table, uuid);
  }

  /// Get all pending changes across all tables
  Future<List<Map<String, dynamic>>> getPendingChanges() async {
    return await db.getPendingChanges();
  }
}