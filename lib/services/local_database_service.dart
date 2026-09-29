import '../database/app_database.dart';
import '../database/database_service.dart';

/// Local Database Service - replaces HealthCacheManager with persistent encrypted storage
/// This provides offline-first data access and automatic sync status management
class LocalDatabaseService {
  final DatabaseService _dbService;

  LocalDatabaseService(this._dbService);

  // ========== PROFILE ==========
  
  Future<ProfileData?> getProfile() async {
    return await _dbService.getProfile();
  }

  Future<void> saveProfile(ProfileCompanion profile) async {
    await _dbService.saveProfile(profile);
  }

  // ========== ALLERGIES ==========
  
  Future<List<Allergy>> getAllergies(String profileUuid) async {
    return await _dbService.getAllergies(profileUuid);
  }

  Stream<List<Allergy>> watchAllergies(String profileUuid) {
    return _dbService.watchAllergies(profileUuid);
  }

  Future<void> saveAllergy(AllergiesCompanion allergy) async {
    await _dbService.saveAllergy(allergy);
  }

  Future<void> deleteAllergy(String uuid) async {
    await _dbService.deleteAllergy(uuid);
  }

  // ========== MEDICATIONS ==========
  
  Future<List<Medication>> getMedications(String profileUuid) async {
    return await _dbService.getMedications(profileUuid);
  }

  Stream<List<Medication>> watchMedications(String profileUuid) {
    return _dbService.watchMedications(profileUuid);
  }

  Future<void> saveMedication(MedicationsCompanion medication) async {
    await _dbService.saveMedication(medication);
  }

  Future<void> deleteMedication(String uuid) async {
    await _dbService.deleteMedication(uuid);
  }

  // ========== CONDITIONS ==========
  
  Future<List<Condition>> getConditions(String profileUuid) async {
    return await _dbService.getConditions(profileUuid);
  }

  Stream<List<Condition>> watchConditions(String profileUuid) {
    return _dbService.watchConditions(profileUuid);
  }

  Future<void> saveCondition(ConditionsCompanion condition) async {
    await _dbService.saveCondition(condition);
  }

  Future<void> deleteCondition(String uuid) async {
    await _dbService.deleteCondition(uuid);
  }

  // ========== NOTES ==========
  
  Future<List<Note>> getNotes(String profileUuid) async {
    return await _dbService.getNotes(profileUuid);
  }

  Stream<List<Note>> watchNotes(String profileUuid) {
    return _dbService.watchNotes(profileUuid);
  }

  Future<void> saveNote(NotesCompanion note) async {
    await _dbService.saveNote(note);
  }

  Future<void> deleteNote(String uuid) async {
    await _dbService.deleteNote(uuid);
  }

  // ========== EMERGENCY CONTACTS ==========
  
  Future<List<EmergencyContact>> getEmergencyContacts(String profileUuid) async {
    return await _dbService.getEmergencyContacts(profileUuid);
  }

  Stream<List<EmergencyContact>> watchEmergencyContacts(String profileUuid) {
    return _dbService.watchEmergencyContacts(profileUuid);
  }

  Future<void> saveEmergencyContact(EmergencyContactsCompanion contact) async {
    await _dbService.saveEmergencyContact(contact);
  }

  Future<void> deleteEmergencyContact(String uuid) async {
    await _dbService.deleteEmergencyContact(uuid);
  }

  // ========== CACHED QR ==========
  
  Future<CachedQrData?> getCachedQr(String profileUuid) async {
    return await _dbService.getCachedQr(profileUuid);
  }

  Stream<CachedQrData?> watchCachedQr(String profileUuid) {
    return _dbService.watchCachedQr(profileUuid);
  }

  Future<void> saveCachedQr(CachedQrCompanion qrData) async {
    await _dbService.saveCachedQr(qrData);
  }

  // ========== SYNC STATUS ==========
  
  Future<void> markAsSynced(String table, String uuid) async {
    await _dbService.markAsSynced(table, uuid);
  }

  Future<List<Map<String, dynamic>>> getPendingChanges() async {
    return await _dbService.getPendingChanges();
  }

  // ========== UTILITY ==========
  
  Future<void> clearProfileData(String profileUuid) async {
    await _dbService.clearProfileData(profileUuid);
  }

  // Initialize database with profile UUID
  Future<void> initializeProfile(String profileUuid) async {
    final existing = await getProfile();
    if (existing == null) {
      // Create a new profile with the given UUID
      final companion = ProfileCompanion.insert(
        uuid: profileUuid,
        fullName: '',
        bloodGroup: '',
        dateOfBirth: '',
        gender: '',
      );
      await saveProfile(companion);
    }
  }
}
