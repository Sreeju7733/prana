import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;
import '../database/app_database.dart';
import '../database/database_service.dart';
import '../services/storage_service.dart';
import 'api_service.dart';

/// Sync states for the UI banner
enum SyncState { offline, syncing, synced }

/// Result of a sync run
class SyncResult {
  final int synced;
  final int failed;
  final int pulled;
  final SyncState state;
  SyncResult({required this.synced, required this.failed, required this.pulled, required this.state});
}

/// Sync service — connects to the server when online, pushes outbox, pulls fresh data.
/// Uses last-write-wins by updatedAt for conflict resolution.
class SyncService extends ChangeNotifier {
  final DatabaseService db;
  final AppDatabase database;
  final String baseUrl;
  final Connectivity _connectivity = Connectivity();

  Timer? _periodicTimer;
  static const _periodicInterval = Duration(minutes: 5);
  static const _syncTimeout = Duration(seconds: 30);

  SyncState _state = SyncState.synced;
  int _pendingCount = 0;

  SyncState get state => _state;
  int get pendingCount => _pendingCount;
  Stream<SyncState> get stateStream => _stateController.stream;
  Stream<int> get pendingStream => _pendingController.stream;

  final StreamController<SyncState> _stateController = StreamController<SyncState>.broadcast();
  final StreamController<int> _pendingController = StreamController<int>.broadcast();

  SyncService(this.db, this.database, {String? baseUrl})
      : baseUrl = baseUrl ?? ApiService().baseUrl {
    _setupConnectivityListener();
    // Initial sync attempt
    _trySync();
  }

  void _setupConnectivityListener() {
    _connectivity.onConnectivityChanged.listen((results) {
      final isConnected = results.any((r) => r != ConnectivityResult.none);
      if (isConnected) {
        _onConnected();
      } else {
        _onDisconnected();
      }
    });
  }

  void _onConnected() {
    _state = SyncState.syncing;
    _stateController.add(_state);
    notifyListeners();
    _trySync().then((_) {
      if (_state == SyncState.syncing) {
        _state = SyncState.synced;
        _stateController.add(_state);
        notifyListeners();
      }
    });
    // Start periodic sync
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(_periodicInterval, (_) => _trySync());
  }

  void _onDisconnected() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
    _state = SyncState.offline;
    _stateController.add(_state);
    notifyListeners();
  }

  /// Main sync entry point — push outbox then pull fresh data
  Future<void> _trySync() async {
    final results = await Future.wait([
      _pushOutbox().timeout(_syncTimeout, onTimeout: () => {'synced': 0, 'failed': 0}),
      Future.delayed(const Duration(milliseconds: 500), () => _pullFreshData()),
    ]);

    final pushResult = results[0] as Map<String, int>;
    final totalFailed = pushResult['failed'] ?? 0;
    final totalPending = await getPendingCount();

    if (totalPending > 0 && totalFailed > 0) {
      _state = SyncState.syncing;
    } else if (totalPending == 0) {
      _state = SyncState.synced;
    }
    _pendingCount = totalPending;
    _stateController.add(_state);
    _pendingController.add(_pendingCount);
    notifyListeners();
  }

  /// Push all pending outbox entries to the server in order
  Future<Map<String, int>> _pushOutbox() async {
    final pending = await (database.select(database.outbox)
          ..where((t) => t.syncStatus.equals('pending')))
        .get();

    int synced = 0;
    int failed = 0;

    for (final entry in pending) {
      try {
        final success = await _syncEntry(entry);
        if (success) {
          await db.markAsSynced(entry.entity, entry.uuid);
          await db.markOutboxSynced(entry.id);
          synced++;
        } else {
          await db.markOutboxFailed(entry.id);
          failed++;
        }
      } catch (_) {
        await db.markOutboxFailed(entry.id);
        failed++;
      }
    }

    return {'synced': synced, 'failed': failed};
  }

  /// Sync a single outbox entry to the server
  Future<bool> _syncEntry(OutboxData entry) async {
    final token = await StorageService().getToken();
    if (token == null || token.isEmpty) return false;

    final payload = jsonDecode(entry.payload) as Map<String, dynamic>;
    // Include client UUID in payload for upsert
    payload['id'] = entry.uuid;

    switch (entry.entity) {
      case 'medication':
        return _syncMedication(entry, payload, token);
      case 'allergy':
        return _syncAllergy(entry, payload, token);
      case 'condition':
        return _syncCondition(entry, payload, token);
      case 'emergency_contact':
        return _syncEmergencyContact(entry, payload, token);
      case 'profile':
        return _syncProfile(entry, payload, token);
      default:
        return false;
    }
  }

  Future<bool> _syncMedication(OutboxData entry, Map<String, dynamic> payload, String token) async {
    try {
      if (entry.action == 'delete') {
        await http.delete(
          Uri.parse('$baseUrl/api/medications/${entry.uuid}'),
          headers: {'Authorization': 'Bearer $token'},
        ).timeout(_syncTimeout);
        return true;
      }
      // POST with id field triggers upsert by client_uuid
      final response = await http.post(
        Uri.parse('$baseUrl/api/medications'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      ).timeout(_syncTimeout);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _syncAllergy(OutboxData entry, Map<String, dynamic> payload, String token) async {
    try {
      if (entry.action == 'delete') {
        await http.delete(
          Uri.parse('$baseUrl/api/allergies/${entry.uuid}'),
          headers: {'Authorization': 'Bearer $token'},
        ).timeout(_syncTimeout);
        return true;
      }
      final response = await http.post(
        Uri.parse('$baseUrl/api/allergies'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      ).timeout(_syncTimeout);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _syncCondition(OutboxData entry, Map<String, dynamic> payload, String token) async {
    try {
      if (entry.action == 'delete') {
        await http.delete(
          Uri.parse('$baseUrl/api/conditions/${entry.uuid}'),
          headers: {'Authorization': 'Bearer $token'},
        ).timeout(_syncTimeout);
        return true;
      }
      final response = await http.post(
        Uri.parse('$baseUrl/api/conditions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      ).timeout(_syncTimeout);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _syncEmergencyContact(OutboxData entry, Map<String, dynamic> payload, String token) async {
    try {
      if (entry.action == 'delete') {
        await http.delete(
          Uri.parse('$baseUrl/api/emergency-contacts/${entry.uuid}'),
          headers: {'Authorization': 'Bearer $token'},
        ).timeout(_syncTimeout);
        return true;
      }
      final response = await http.post(
        Uri.parse('$baseUrl/api/emergency-contacts'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      ).timeout(_syncTimeout);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _syncProfile(OutboxData entry, Map<String, dynamic> payload, String token) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/patient/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      ).timeout(_syncTimeout);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Pull fresh data from server and merge into local DB (last-write-wins by updatedAt)
  Future<int> _pullFreshData() async {
    final token = await StorageService().getToken();
    if (token == null || token.isEmpty) return 0;

    int pulled = 0;
    try {
      pulled += await _pullMedications(token);
      pulled += await _pullAllergies(token);
      pulled += await _pullConditions(token);
      pulled += await _pullContacts(token);
    } catch (_) {}
    return pulled;
  }

  Future<int> _pullMedications(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/medications'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(_syncTimeout);

      if (response.statusCode != 200) return 0;
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final serverItems = (body['data'] as List?) ?? [];

      final localItems = await (database.select(database.medications)
            ..where((t) => t.profileUuid.equals(_getProfileUuid())))
        .get();

      final localMap = <String, Medication>{};
      for (final m in localItems) {
        localMap[m.uuid] = m;
      }

      int pulledCount = 0;
      for (final item in serverItems) {
        final serverUuid = item['client_uuid'] as String?;
        final serverUpdatedAt = item['updated_at'] as String?;
        if (serverUuid == null) continue;

        final existing = localMap[serverUuid];
        if (existing == null) {
          // New on server — insert locally
          await _insertMedicationFromServer(item, serverUuid);
          pulledCount++;
        } else if (serverUpdatedAt != null && _isNewer(serverUpdatedAt, existing.updatedAt)) {
          // Server is newer — update locally
          await _updateMedicationFromServer(item, serverUuid);
          pulledCount++;
        }
        // else: local is newer or same, keep local
      }
      return pulledCount;
    } catch (_) {
      return 0;
    }
  }

  Future<int> _pullAllergies(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/allergies'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(_syncTimeout);

      if (response.statusCode != 200) return 0;
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final serverItems = (body['data'] as List?) ?? [];

      final localItems = await (database.select(database.allergies)
            ..where((t) => t.profileUuid.equals(_getProfileUuid())))
        .get();

      final localMap = <String, Allergy>{};
      for (final a in localItems) {
        localMap[a.uuid] = a;
      }

      int pulledCount = 0;
      for (final item in serverItems) {
        final serverUuid = item['client_uuid'] as String?;
        final serverUpdatedAt = item['updated_at'] as String?;
        if (serverUuid == null) continue;

        final existing = localMap[serverUuid];
        if (existing == null) {
          await _insertAllergyFromServer(item, serverUuid);
          pulledCount++;
        } else if (serverUpdatedAt != null && _isNewer(serverUpdatedAt, existing.updatedAt)) {
          await _updateAllergyFromServer(item, serverUuid);
          pulledCount++;
        }
      }
      return pulledCount;
    } catch (_) {
      return 0;
    }
  }

  Future<int> _pullConditions(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/conditions'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(_syncTimeout);

      if (response.statusCode != 200) return 0;
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final serverItems = (body['data'] as List?) ?? [];

      final localItems = await (database.select(database.conditions)
            ..where((t) => t.profileUuid.equals(_getProfileUuid())))
        .get();

      final localMap = <String, Condition>{};
      for (final c in localItems) {
        localMap[c.uuid] = c;
      }

      int pulledCount = 0;
      for (final item in serverItems) {
        final serverUuid = item['client_uuid'] as String?;
        final serverUpdatedAt = item['updated_at'] as String?;
        if (serverUuid == null) continue;

        final existing = localMap[serverUuid];
        if (existing == null) {
          await _insertConditionFromServer(item, serverUuid);
          pulledCount++;
        } else if (serverUpdatedAt != null && _isNewer(serverUpdatedAt, existing.updatedAt)) {
          await _updateConditionFromServer(item, serverUuid);
          pulledCount++;
        }
      }
      return pulledCount;
    } catch (_) {
      return 0;
    }
  }

  Future<int> _pullContacts(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/emergency-contacts'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(_syncTimeout);

      if (response.statusCode != 200) return 0;
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final serverItems = (body['data'] as List?) ?? [];

      final localItems = await (database.select(database.emergencyContacts)
            ..where((t) => t.profileUuid.equals(_getProfileUuid())))
        .get();

      final localMap = <String, EmergencyContact>{};
      for (final c in localItems) {
        localMap[c.uuid] = c;
      }

      int pulledCount = 0;
      for (final item in serverItems) {
        final serverUuid = item['client_uuid'] as String?;
        final serverUpdatedAt = item['created_at'] as String?;
        if (serverUuid == null) continue;

        final existing = localMap[serverUuid];
        if (existing == null) {
          await _insertContactFromServer(item, serverUuid);
          pulledCount++;
        } else if (serverUpdatedAt != null && _isNewer(serverUpdatedAt, existing.updatedAt)) {
          await _updateContactFromServer(item, serverUuid);
          pulledCount++;
        }
      }
      return pulledCount;
    } catch (_) {
      return 0;
    }
  }

  // ---------- Local DB insert/update from server data ----------

  Future<void> _insertMedicationFromServer(Map<String, dynamic> item, String uuid) async {
    final companion = MedicationsCompanion.insert(
      uuid: uuid,
      profileUuid: _getProfileUuid(),
      name: item['name'] ?? '',
      dose: item['dose'] ?? '',
      frequency: item['frequency'] ?? '',
      reason: Value(item['reason']),
      isActive: Value(item['is_active'] ?? true),
      createdAt: Value(_parseIsoDateTime(item['created_at']) ?? DateTime.now()),
      updatedAt: Value(_parseIsoDateTime(item['updated_at']) ?? DateTime.now()),
      syncStatus: const Value('synced'),
    );
    await db.saveMedication(companion);
  }

  Future<void> _updateMedicationFromServer(Map<String, dynamic> item, String uuid) async {
    await (database.update(database.medications)
          ..where((t) => t.uuid.equals(uuid)))
        .write(MedicationsCompanion(
      name: Value(item['name']),
      dose: Value(item['dose']),
      frequency: Value(item['frequency']),
      reason: Value(item['reason']),
      isActive: Value(item['is_active'] ?? true),
      updatedAt: Value(_parseIsoDateTime(item['updated_at']) ?? DateTime.now()),
      syncStatus: const Value('synced'),
    ));
  }

  Future<void> _insertAllergyFromServer(Map<String, dynamic> item, String uuid) async {
    final companion = AllergiesCompanion.insert(
      uuid: uuid,
      profileUuid: _getProfileUuid(),
      allergen: item['allergen'] ?? '',
      severity: item['severity'] ?? '',
      reaction: Value(item['reaction_description']),
      isCritical: Value(item['is_critical'] ?? false),
      diagnosedAt: Value(item['date_diagnosed'] != null
          ? DateTime.tryParse(item['date_diagnosed'])
          : null),
      createdAt: Value(_parseIsoDateTime(item['created_at']) ?? DateTime.now()),
      updatedAt: Value(_parseIsoDateTime(item['updated_at']) ?? DateTime.now()),
      syncStatus: const Value('synced'),
    );
    await db.saveAllergy(companion);
  }

  Future<void> _updateAllergyFromServer(Map<String, dynamic> item, String uuid) async {
    await (database.update(database.allergies)
          ..where((t) => t.uuid.equals(uuid)))
        .write(AllergiesCompanion(
      allergen: Value(item['allergen']),
      severity: Value(item['severity']),
      reaction: Value(item['reaction_description']),
      isCritical: Value(item['is_critical'] ?? false),
      updatedAt: Value(_parseIsoDateTime(item['updated_at']) ?? DateTime.now()),
      syncStatus: const Value('synced'),
    ));
  }

  Future<void> _insertConditionFromServer(Map<String, dynamic> item, String uuid) async {
    final companion = ConditionsCompanion.insert(
      uuid: uuid,
      profileUuid: _getProfileUuid(),
      name: item['name'] ?? '',
      diagnosedAt: item['diagnosed_date'] != null
          ? (DateTime.tryParse(item['diagnosed_date']) ?? DateTime.now())
          : DateTime.now(),
      status: item['status'] ?? 'active',
      notes: Value(item['notes']),
      createdAt: Value(_parseIsoDateTime(item['created_at']) ?? DateTime.now()),
      updatedAt: Value(_parseIsoDateTime(item['updated_at']) ?? DateTime.now()),
      syncStatus: const Value('synced'),
    );
    await db.saveCondition(companion);
  }

  Future<void> _updateConditionFromServer(Map<String, dynamic> item, String uuid) async {
    await (database.update(database.conditions)
          ..where((t) => t.uuid.equals(uuid)))
        .write(ConditionsCompanion(
      name: Value(item['name']),
      status: Value(item['status']),
      notes: Value(item['notes']),
      updatedAt: Value(_parseIsoDateTime(item['updated_at']) ?? DateTime.now()),
      syncStatus: const Value('synced'),
    ));
  }

  Future<void> _insertContactFromServer(Map<String, dynamic> item, String uuid) async {
    final rawPhone = item['phone'] ?? item['phone_number'] ?? '';
    final companion = EmergencyContactsCompanion.insert(
      uuid: uuid,
      profileUuid: _getProfileUuid(),
      name: item['name'] ?? '',
      relationship: item['relationship'] ?? '',
      phoneNumber: ApiService.cleanPhoneNumber(rawPhone),
      isPrimary: Value(item['is_primary'] ?? false),
      createdAt: Value(_parseIsoDateTime(item['created_at']) ?? DateTime.now()),
      updatedAt: Value(_parseIsoDateTime(item['created_at']) ?? DateTime.now()),
      syncStatus: const Value('synced'),
    );
    await db.saveEmergencyContact(companion);
  }

  Future<void> _updateContactFromServer(Map<String, dynamic> item, String uuid) async {
    final rawPhone = item['phone'] ?? item['phone_number'] ?? '';
    await (database.update(database.emergencyContacts)
          ..where((t) => t.uuid.equals(uuid)))
        .write(EmergencyContactsCompanion(
      name: Value(item['name']),
      relationship: Value(item['relationship']),
      phoneNumber: Value(ApiService.cleanPhoneNumber(rawPhone)),
      isPrimary: Value(item['is_primary'] ?? false),
      updatedAt: Value(DateTime.now()),
      syncStatus: const Value('synced'),
    ));
  }

  // ---------- Helpers ----------

  String _getProfileUuid() {
    // Use empty string — the DB queries already filter by profileUuid
    // In production this would come from auth state
    return '';
  }

  bool _isNewer(String serverIso, DateTime localDateTime) {
    try {
      final serverTime = DateTime.parse(serverIso).toUtc();
      return serverTime.isAfter(localDateTime.toUtc());
    } catch (_) {
      return false;
    }
  }

  DateTime? _parseIsoDateTime(dynamic value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value).toLocal();
    } catch (_) {
      return null;
    }
  }

  /// Public: get pending outbox count
  Future<int> getPendingCount() async {
    return await (database.select(database.outbox)
          ..where((t) => t.syncStatus.equals('pending')))
        .get().then((rows) => rows.length);
  }

  /// Public: force a sync now
  Future<void> syncNow() async {
    _state = SyncState.syncing;
    _stateController.add(_state);
    notifyListeners();
    await _trySync();
  }

  /// Public: manual sync trigger (for UI button)
  Future<void> triggerSync() async {
    await syncNow();
  }

  @override
  void dispose() {
    _periodicTimer?.cancel();
    _stateController.close();
    _pendingController.close();
    super.dispose();
  }
}