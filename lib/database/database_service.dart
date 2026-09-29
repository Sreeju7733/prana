import 'package:drift/drift.dart';
import 'app_database.dart';

/// Service class to handle database operations for the PRANA app
/// This replaces the in-memory HealthCacheManager with persistent encrypted storage
class DatabaseService {
  final AppDatabase _db;

  DatabaseService(this._db);

  // Profile operations
  Future<ProfileData?> getProfile() async {
    final profiles = await _db.select(_db.profile).get();
    return profiles.isNotEmpty ? profiles.first : null;
  }

  Future<void> saveProfile(ProfileCompanion profile) async {
    final existing = await (_db.select(_db.profile)
          ..where((t) => t.uuid.equals(profile.uuid.value)))
        .get();
    
    if (existing.isEmpty) {
      await _db.into(_db.profile).insert(profile);
    } else {
      await (_db.update(_db.profile)
            ..where((t) => t.uuid.equals(profile.uuid.value)))
          .write(profile);
    }
  }

  Future<void> deleteProfile(String uuid) async {
    await (_db.delete(_db.profile)..where((t) => t.uuid.equals(uuid))).go();
  }

  // Allergies operations
  Stream<List<Allergy>> watchAllergies(String profileUuid) {
    return (_db.select(_db.allergies)
          ..where((t) => t.profileUuid.equals(profileUuid))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch()
        .map((rows) => rows.map((row) => row).toList());
  }

  Future<List<Allergy>> getAllergies(String profileUuid) async {
    return await (_db.select(_db.allergies)
          ..where((t) => t.profileUuid.equals(profileUuid))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  Future<void> saveAllergy(AllergiesCompanion allergy) async {
    final existing = await (_db.select(_db.allergies)
          ..where((t) => t.uuid.equals(allergy.uuid.value)))
        .get();
    
    if (existing.isEmpty) {
      await _db.into(_db.allergies).insert(allergy);
    } else {
      await (_db.update(_db.allergies)
            ..where((t) => t.uuid.equals(allergy.uuid.value)))
          .write(allergy);
    }
  }

  Future<void> deleteAllergy(String uuid) async {
    await (_db.delete(_db.allergies)..where((t) => t.uuid.equals(uuid))).go();
  }

  // Medications operations
  Stream<List<Medication>> watchMedications(String profileUuid) {
    return (_db.select(_db.medications)
          ..where((t) => t.profileUuid.equals(profileUuid))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch()
        .map((rows) => rows.map((row) => row).toList());
  }

  Future<List<Medication>> getMedications(String profileUuid) async {
    return await (_db.select(_db.medications)
          ..where((t) => t.profileUuid.equals(profileUuid))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  Future<void> saveMedication(MedicationsCompanion medication) async {
    final existing = await (_db.select(_db.medications)
          ..where((t) => t.uuid.equals(medication.uuid.value)))
        .get();
    
    if (existing.isEmpty) {
      await _db.into(_db.medications).insert(medication);
    } else {
      await (_db.update(_db.medications)
            ..where((t) => t.uuid.equals(medication.uuid.value)))
          .write(medication);
    }
  }

  Future<void> deleteMedication(String uuid) async {
    await (_db.delete(_db.medications)..where((t) => t.uuid.equals(uuid))).go();
  }

  // Conditions operations
  Stream<List<Condition>> watchConditions(String profileUuid) {
    return (_db.select(_db.conditions)
          ..where((t) => t.profileUuid.equals(profileUuid))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch()
        .map((rows) => rows.map((row) => row).toList());
  }

  Future<List<Condition>> getConditions(String profileUuid) async {
    return await (_db.select(_db.conditions)
          ..where((t) => t.profileUuid.equals(profileUuid))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  Future<void> saveCondition(ConditionsCompanion condition) async {
    final existing = await (_db.select(_db.conditions)
          ..where((t) => t.uuid.equals(condition.uuid.value)))
        .get();
    
    if (existing.isEmpty) {
      await _db.into(_db.conditions).insert(condition);
    } else {
      await (_db.update(_db.conditions)
            ..where((t) => t.uuid.equals(condition.uuid.value)))
          .write(condition);
    }
  }

  Future<void> deleteCondition(String uuid) async {
    await (_db.delete(_db.conditions)..where((t) => t.uuid.equals(uuid))).go();
  }

  // Notes operations
  Stream<List<Note>> watchNotes(String profileUuid) {
    return (_db.select(_db.notes)
          ..where((t) => t.profileUuid.equals(profileUuid))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch()
        .map((rows) => rows.map((row) => row).toList());
  }

  Future<List<Note>> getNotes(String profileUuid) async {
    return await (_db.select(_db.notes)
          ..where((t) => t.profileUuid.equals(profileUuid))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  Future<void> saveNote(NotesCompanion note) async {
    final existing = await (_db.select(_db.notes)
          ..where((t) => t.uuid.equals(note.uuid.value)))
        .get();
    
    if (existing.isEmpty) {
      await _db.into(_db.notes).insert(note);
    } else {
      await (_db.update(_db.notes)
            ..where((t) => t.uuid.equals(note.uuid.value)))
          .write(note);
    }
  }

  Future<void> deleteNote(String uuid) async {
    await (_db.delete(_db.notes)..where((t) => t.uuid.equals(uuid))).go();
  }

  // Emergency contacts operations
  Stream<List<EmergencyContact>> watchEmergencyContacts(String profileUuid) {
    return (_db.select(_db.emergencyContacts)
          ..where((t) => t.profileUuid.equals(profileUuid))
          ..orderBy([(t) => OrderingTerm.desc(t.isPrimary), (t) => OrderingTerm.desc(t.createdAt)]))
        .watch()
        .map((rows) => rows.map((row) => row).toList());
  }

  Future<List<EmergencyContact>> getEmergencyContacts(String profileUuid) async {
    return await (_db.select(_db.emergencyContacts)
          ..where((t) => t.profileUuid.equals(profileUuid))
          ..orderBy([(t) => OrderingTerm.desc(t.isPrimary), (t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  Future<void> saveEmergencyContact(EmergencyContactsCompanion contact) async {
    final existing = await (_db.select(_db.emergencyContacts)
          ..where((t) => t.uuid.equals(contact.uuid.value)))
        .get();
    
    if (existing.isEmpty) {
      await _db.into(_db.emergencyContacts).insert(contact);
    } else {
      await (_db.update(_db.emergencyContacts)
            ..where((t) => t.uuid.equals(contact.uuid.value)))
          .write(contact);
    }
  }

  Future<void> deleteEmergencyContact(String uuid) async {
    await (_db.delete(_db.emergencyContacts)..where((t) => t.uuid.equals(uuid))).go();
  }

  // Cached QR operations
  Stream<CachedQrData?> watchCachedQr(String profileUuid) {
    return (_db.select(_db.cachedQr)
          ..where((t) => t.profileUuid.equals(profileUuid))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(1))
        .watch()
        .map((rows) => rows.isNotEmpty ? rows.first : null);
  }

  Future<CachedQrData?> getCachedQr(String profileUuid) async {
    final rows = await (_db.select(_db.cachedQr)
          ..where((t) => t.profileUuid.equals(profileUuid))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(1))
        .get();
    return rows.isNotEmpty ? rows.first : null;
  }

  Future<void> saveCachedQr(CachedQrCompanion qrData) async {
    final existing = await (_db.select(_db.cachedQr)
          ..where((t) => t.uuid.equals(qrData.uuid.value)))
        .get();
    
    if (existing.isEmpty) {
      await _db.into(_db.cachedQr).insert(qrData);
    } else {
      await (_db.update(_db.cachedQr)
            ..where((t) => t.uuid.equals(qrData.uuid.value)))
          .write(qrData);
    }
  }

  Future<void> deleteCachedQr(String uuid) async {
    await (_db.delete(_db.cachedQr)..where((t) => t.uuid.equals(uuid))).go();
  }

  // Utility methods for sync status
  Future<void> markAsSynced(String table, String uuid) async {
    switch (table) {
      case 'profile':
        await (_db.update(_db.profile)
              ..where((t) => t.uuid.equals(uuid)))
            .write(const ProfileCompanion(syncStatus: Value('synced')));
        break;
      case 'allergies':
        await (_db.update(_db.allergies)
              ..where((t) => t.uuid.equals(uuid)))
            .write(const AllergiesCompanion(syncStatus: Value('synced')));
        break;
      case 'medications':
        await (_db.update(_db.medications)
              ..where((t) => t.uuid.equals(uuid)))
            .write(const MedicationsCompanion(syncStatus: Value('synced')));
        break;
      case 'conditions':
        await (_db.update(_db.conditions)
              ..where((t) => t.uuid.equals(uuid)))
            .write(const ConditionsCompanion(syncStatus: Value('synced')));
        break;
      case 'notes':
        await (_db.update(_db.notes)
              ..where((t) => t.uuid.equals(uuid)))
            .write(const NotesCompanion(syncStatus: Value('synced')));
        break;
      case 'emergencyContacts':
        await (_db.update(_db.emergencyContacts)
              ..where((t) => t.uuid.equals(uuid)))
            .write(const EmergencyContactsCompanion(syncStatus: Value('synced')));
        break;
      case 'cachedQr':
        await (_db.update(_db.cachedQr)
              ..where((t) => t.uuid.equals(uuid)))
            .write(const CachedQrCompanion(syncStatus: Value('synced')));
        break;
    }
  }

  Future<List<Map<String, dynamic>>> getPendingChanges() async {
    final pendingProfiles = await (_db.select(_db.profile)
          ..where((t) => t.syncStatus.equals('pending')))
        .get();
    
    final pendingAllergies = await (_db.select(_db.allergies)
          ..where((t) => t.syncStatus.equals('pending')))
        .get();
    
    final pendingMedications = await (_db.select(_db.medications)
          ..where((t) => t.syncStatus.equals('pending')))
        .get();
    
    final pendingConditions = await (_db.select(_db.conditions)
          ..where((t) => t.syncStatus.equals('pending')))
        .get();
    
    final pendingNotes = await (_db.select(_db.notes)
          ..where((t) => t.syncStatus.equals('pending')))
        .get();
    
    final pendingContacts = await (_db.select(_db.emergencyContacts)
          ..where((t) => t.syncStatus.equals('pending')))
        .get();
    
    final pendingQr = await (_db.select(_db.cachedQr)
          ..where((t) => t.syncStatus.equals('pending')))
        .get();
    
    return [
      {'table': 'profile', 'data': pendingProfiles.map((e) => e.toJson()).toList()},
      {'table': 'allergies', 'data': pendingAllergies.map((e) => e.toJson()).toList()},
      {'table': 'medications', 'data': pendingMedications.map((e) => e.toJson()).toList()},
      {'table': 'conditions', 'data': pendingConditions.map((e) => e.toJson()).toList()},
      {'table': 'notes', 'data': pendingNotes.map((e) => e.toJson()).toList()},
      {'table': 'emergencyContacts', 'data': pendingContacts.map((e) => e.toJson()).toList()},
      {'table': 'cachedQr', 'data': pendingQr.map((e) => e.toJson()).toList()},
    ];
  }

  // Clear all data for a profile (useful for logout)
  Future<void> clearProfileData(String profileUuid) async {
    await (_db.delete(_db.allergies)..where((t) => t.profileUuid.equals(profileUuid))).go();
    await (_db.delete(_db.medications)..where((t) => t.profileUuid.equals(profileUuid))).go();
    await (_db.delete(_db.conditions)..where((t) => t.profileUuid.equals(profileUuid))).go();
    await (_db.delete(_db.notes)..where((t) => t.profileUuid.equals(profileUuid))).go();
    await (_db.delete(_db.emergencyContacts)..where((t) => t.profileUuid.equals(profileUuid))).go();
    await (_db.delete(_db.cachedQr)..where((t) => t.profileUuid.equals(profileUuid))).go();
    await (_db.delete(_db.profile)..where((t) => t.uuid.equals(profileUuid))).go();
  }

  // ---------- Outbox methods ----------

  /// Get all pending outbox entries
  Future<List<OutboxData>> getPendingOutbox() async {
    return await (_db.select(_db.outbox)
          ..where((t) => t.syncStatus.equals('pending'))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  /// Get all outbox entries
  Future<List<OutboxData>> getAllOutbox() async {
    return await (_db.select(_db.outbox)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  /// Mark an outbox entry as synced
  Future<void> markOutboxSynced(int outboxId) async {
    await (_db.update(_db.outbox)
          ..where((t) => t.id.equals(outboxId)))
        .write(const OutboxCompanion(syncStatus: Value('synced')));
  }

  /// Mark an outbox entry as failed and increment attempts
  Future<void> markOutboxFailed(int outboxId) async {
    final entries = await (_db.select(_db.outbox)
          ..where((t) => t.id.equals(outboxId)))
        .get();
    if (entries.isNotEmpty) {
      final entry = entries.first;
      await (_db.update(_db.outbox)
            ..where((t) => t.id.equals(outboxId)))
          .write(OutboxCompanion(
            attempts: Value(entry.attempts + 1),
            syncStatus: const Value('failed'),
          ));
    }
  }
}
