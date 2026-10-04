import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../database/database_service.dart';
import 'base_repository.dart';

/// Repository for profile CRUD operations with outbox-backed sync.
class ProfileRepository extends BaseRepository {
  ProfileRepository(super.db, super.database);

  // ---------- Reads ----------

  Future<ProfileData?> getProfile() async {
    return await db.getProfile();
  }

  Stream<ProfileData?> watchProfile() {
    return database.select(database.profile).watch().map(
      (rows) => rows.isNotEmpty ? rows.first : null,
    );
  }

  // ---------- Writes ----------

  Future<void> updateProfile({
    String? fullName,
    String? bloodGroup,
    String? dateOfBirth,
    String? gender,
    double? weightKg,
    double? heightCm,
    String? avatarUrl,
  }) async {
    final existing = await getProfile();
    if (existing == null) return;

    await (database.update(database.profile)
          ..where((t) => t.uuid.equals(existing.uuid)))
        .write(ProfileCompanion(
      fullName: fullName != null ? Value(fullName) : const Value.absent(),
      bloodGroup: bloodGroup != null ? Value(bloodGroup) : const Value.absent(),
      dateOfBirth: dateOfBirth != null ? Value(dateOfBirth) : const Value.absent(),
      gender: gender != null ? Value(gender) : const Value.absent(),
      weightKg: weightKg != null ? Value(weightKg) : const Value.absent(),
      heightCm: heightCm != null ? Value(heightCm) : const Value.absent(),
      avatarUrl: avatarUrl != null ? Value(avatarUrl) : const Value.absent(),
      updatedAt: Value(DateTime.now()),
      syncStatus: const Value('pending'),
    ));

    await addToOutbox(
      entity: 'profile',
      action: 'update',
      payload: {
        'uuid': existing.uuid,
        'full_name': fullName,
        'blood_group': bloodGroup,
        'date_of_birth': dateOfBirth,
        'gender': gender,
        'weight_kg': weightKg,
        'height_cm': heightCm,
        'avatar_url': avatarUrl,
      },
    );
  }
}