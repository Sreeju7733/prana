import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/theme.dart';
import 'screens/splash_screen.dart';
import 'database/app_database.dart';
import 'database/database_service.dart';
import 'services/local_database_service.dart';
import 'services/sync_service.dart';
import 'repositories/medication_repository.dart';
import 'repositories/allergy_repository.dart';
import 'repositories/condition_repository.dart';
import 'repositories/emergency_contact_repository.dart';
import 'repositories/profile_repository.dart';

// Global database instance
final database = AppDatabase.instance();
final dbService = DatabaseService(database);
final localDbService = LocalDatabaseService(dbService);

/// Get the current profile UUID (used by repositories)
Future<String> getCurrentProfileUuid() async {
  final profile = await localDbService.getProfile();
  return profile?.uuid ?? '';
}

/// Repository instances
MedicationRepository get medicationRepo =>
    MedicationRepository(dbService, database, '');
AllergyRepository get allergyRepo =>
    AllergyRepository(dbService, database, '');
ConditionRepository get conditionRepo =>
    ConditionRepository(dbService, database, '');
EmergencyContactRepository get contactRepo =>
    EmergencyContactRepository(dbService, database, '');
ProfileRepository get profileRepo =>
    ProfileRepository(dbService, database);

/// Shared sync service instance
final syncService = SyncService(dbService, database);

/// Shared sync service — initialized once, used by all screens
final syncServiceProvider = Provider<SyncService>((ref) {
  return syncService;
});

void main() {
  runApp(
    const ProviderScope(
      child: PranaApp(),
    ),
  );
}

class PranaApp extends StatelessWidget {
  const PranaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prana',
      debugShowCheckedModeBanner: false,
      theme: PranaTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
