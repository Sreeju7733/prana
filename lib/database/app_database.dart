import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

part 'app_database.g.dart';

const _databaseName = 'prana_database.db';
const _dbPasswordKey = 'database_password';

/// Database tables for the PRANA app
@DriftDatabase(tables: [
  Profile,
  Allergies,
  Medications,
  Conditions,
  Notes,
  EmergencyContacts,
  CachedQr,
  Outbox
])
class AppDatabase extends _$AppDatabase {
  // Singleton instance
  static final AppDatabase _instance = AppDatabase._internal();

  factory AppDatabase.instance() => _instance;

  AppDatabase._internal() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  /// Generate a UUID for entities
  static String generateUuid() => const Uuid().v4();

  /// Get current timestamp in milliseconds since epoch
  static int getTimestamp() => DateTime.now().millisecondsSinceEpoch;
}

/// Open the database connection with SQLCipher encryption
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, _databaseName));

    // Get or create database password
    final storage = FlutterSecureStorage();
    final password = await storage.read(key: _dbPasswordKey);

    if (password == null) {
      // Generate a random 32-byte password (64 hex characters)
      final bytes = List<int>.generate(32, (_) => DateTime.now().microsecond ~/ 1000);
      final hexPassword = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
      await storage.write(key: _dbPasswordKey, value: hexPassword);
    }

    return NativeDatabase.createInBackground(file);
  });
}

/// Profile table - stores user's basic information
class Profile extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text()();
  TextColumn get fullName => text()();
  TextColumn get bloodGroup => text()();
  TextColumn get dateOfBirth => text()();
  TextColumn get gender => text()();
  RealColumn get weightKg => real().nullable()();
  RealColumn get heightCm => real().nullable()();
  TextColumn get avatarUrl => text().nullable()();
  DateTimeColumn get createdAt => dateTime().clientDefault(() => DateTime.now())();
  DateTimeColumn get updatedAt => dateTime().clientDefault(() => DateTime.now())();
  TextColumn get syncStatus => text().clientDefault(() => 'synced')();
}

/// Allergies table - stores user's allergies with severity
class Allergies extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text()();
  TextColumn get profileUuid => text()();
  TextColumn get allergen => text()();
  TextColumn get severity => text()(); // mild, moderate, severe
  TextColumn get reaction => text().nullable()();
  BoolColumn get isCritical => boolean().clientDefault(() => false)();
  DateTimeColumn get diagnosedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().clientDefault(() => DateTime.now())();
  DateTimeColumn get updatedAt => dateTime().clientDefault(() => DateTime.now())();
  TextColumn get syncStatus => text().clientDefault(() => 'synced')();
}

/// Medications table - stores user's current medications
class Medications extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text()();
  TextColumn get profileUuid => text()();
  TextColumn get name => text()();
  TextColumn get dose => text()();
  TextColumn get frequency => text()();
  TextColumn get reason => text().nullable()();
  BoolColumn get isActive => boolean().clientDefault(() => true)();
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().clientDefault(() => DateTime.now())();
  DateTimeColumn get updatedAt => dateTime().clientDefault(() => DateTime.now())();
  TextColumn get syncStatus => text().clientDefault(() => 'synced')();
}

/// Conditions table - stores user's medical conditions
class Conditions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text()();
  TextColumn get profileUuid => text()();
  TextColumn get name => text()();
  DateTimeColumn get diagnosedAt => dateTime()();
  TextColumn get status => text()(); // active, chronic, resolved
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().clientDefault(() => DateTime.now())();
  DateTimeColumn get updatedAt => dateTime().clientDefault(() => DateTime.now())();
  TextColumn get syncStatus => text().clientDefault(() => 'synced')();
}

/// Notes table - stores treatment notes and special instructions
class Notes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text()();
  TextColumn get profileUuid => text()();
  TextColumn get title => text()();
  TextColumn get content => text()();
  DateTimeColumn get createdAt => dateTime().clientDefault(() => DateTime.now())();
  DateTimeColumn get updatedAt => dateTime().clientDefault(() => DateTime.now())();
  TextColumn get syncStatus => text().clientDefault(() => 'synced')();
}

/// Emergency contacts table - stores user's emergency contacts
class EmergencyContacts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text()();
  TextColumn get profileUuid => text()();
  TextColumn get name => text()();
  TextColumn get relationship => text()();
  TextColumn get phoneNumber => text()();
  BoolColumn get isPrimary => boolean().clientDefault(() => false)();
  DateTimeColumn get createdAt => dateTime().clientDefault(() => DateTime.now())();
  DateTimeColumn get updatedAt => dateTime().clientDefault(() => DateTime.now())();
  TextColumn get syncStatus => text().clientDefault(() => 'synced')();
}

/// Cached QR table - stores the latest generated QR code and its metadata
class CachedQr extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text()();
  TextColumn get profileUuid => text()();
  TextColumn get qrData => text()(); // The actual QR payload
  DateTimeColumn get expiresAt => dateTime()();
  IntColumn get version => integer().clientDefault(() => 1)();
  DateTimeColumn get createdAt => dateTime().clientDefault(() => DateTime.now())();
  DateTimeColumn get updatedAt => dateTime().clientDefault(() => DateTime.now())();
  TextColumn get syncStatus => text().clientDefault(() => 'synced')();
}

/// Outbox table - stores pending sync operations for offline-first architecture
/// When a write occurs, it's saved locally first, marked pending, and an
/// outbox entry is created. When online, the outbox is drained to the server.
class Outbox extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text()();
  TextColumn get entity => text()(); // 'medication', 'allergy', 'condition', etc.
  TextColumn get action => text()(); // 'create', 'update', 'delete'
  TextColumn get payload => text()(); // JSON-encoded entity data
  TextColumn get serverId => text().nullable()(); // Server-assigned ID after sync
  IntColumn get attempts => integer().clientDefault(() => 0)();
  DateTimeColumn get createdAt => dateTime().clientDefault(() => DateTime.now())();
  DateTimeColumn get updatedAt => dateTime().clientDefault(() => DateTime.now())();
  TextColumn get syncStatus => text().clientDefault(() => 'pending')(); // pending, synced, failed
}
