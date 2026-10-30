import 'package:drift/drift.dart';
import '../database/app_database.dart';
import 'base_repository.dart';

/// Repository for emergency contact CRUD operations with outbox-backed sync.
class EmergencyContactRepository extends BaseRepository {
  final String _profileUuid;

  EmergencyContactRepository(super.db, super.database, this._profileUuid);

  // ---------- Reads ----------

  Stream<List<EmergencyContact>> watchContacts() {
    return db.watchEmergencyContacts(_profileUuid);
  }

  Future<List<EmergencyContact>> getContacts() async {
    return await db.getEmergencyContacts(_profileUuid);
  }

  Future<EmergencyContact?> getPrimaryContact() async {
    final contacts = await getContacts();
    final primary = contacts.where((c) => c.isPrimary).toList();
    return primary.isNotEmpty
        ? primary.first
        : (contacts.isNotEmpty ? contacts.first : null);
  }

  // ---------- Writes ----------

  Future<String> createContact({
    required String name,
    required String relationship,
    required String phoneNumber,
    bool isPrimary = false,
  }) async {
    final uuid = AppDatabase.generateUuid();

    await db.saveEmergencyContact(EmergencyContactsCompanion.insert(
      uuid: uuid,
      profileUuid: _profileUuid,
      name: name,
      relationship: relationship,
      phoneNumber: phoneNumber,
      isPrimary: Value(isPrimary),
      syncStatus: const Value('pending'),
    ));

    await addToOutbox(
      entity: 'emergency_contact',
      action: 'create',
      payload: {
        'uuid': uuid,
        'name': name,
        'relationship': relationship,
        'phone_number': phoneNumber,
        'is_primary': isPrimary,
      },
    );

    return uuid;
  }

  Future<void> updateContact({
    required String uuid,
    String? name,
    String? relationship,
    String? phoneNumber,
    bool? isPrimary,
  }) async {
    await (database.update(database.emergencyContacts)
          ..where((t) => t.uuid.equals(uuid)))
        .write(EmergencyContactsCompanion(
      name: name != null ? Value(name) : const Value.absent(),
      relationship: relationship != null ? Value(relationship) : const Value.absent(),
      phoneNumber: phoneNumber != null ? Value(phoneNumber) : const Value.absent(),
      isPrimary: isPrimary != null ? Value(isPrimary) : const Value.absent(),
      updatedAt: Value(DateTime.now()),
      syncStatus: const Value('pending'),
    ));

    await addToOutbox(
      entity: 'emergency_contact',
      action: 'update',
      payload: {
        'uuid': uuid,
        'name': name,
        'relationship': relationship,
        'phone_number': phoneNumber,
        'is_primary': isPrimary,
      },
    );
  }

  /// Soft-delete — remove from local table, add to outbox
  Future<void> deleteContact(String uuid) async {
    await (database.delete(database.emergencyContacts)
          ..where((t) => t.uuid.equals(uuid)))
        .go();

    await addToOutbox(
      entity: 'emergency_contact',
      action: 'delete',
      payload: {'uuid': uuid},
    );
  }

  Future<void> hardDeleteContact(String uuid) async {
    await (database.delete(database.emergencyContacts)
          ..where((t) => t.uuid.equals(uuid)))
        .go();
  }
}