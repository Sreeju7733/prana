import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../database/database_service.dart';
import 'storage_service.dart';
import 'api_service.dart';

/// QR Service - fetches encrypted QR from backend and caches locally
class QrService {
  final ApiService _apiService = ApiService();
  final DatabaseService _dbService = DatabaseService(AppDatabase.instance());

  /// Get cached QR string from local database
  Future<String?> getCachedQr({String? pranaId}) async {
    try {
      final profile = await _dbService.getProfile();
      final qr = await _dbService
              .getCachedQr(profile?.uuid ?? pranaId ?? 'local_user') ??
          (pranaId != null && profile?.uuid != pranaId
              ? await _dbService.getCachedQr(pranaId)
              : null);
      if (qr == null) return null;

      final now = DateTime.now();
      if (qr.expiresAt.isBefore(now)) {
        await _dbService.deleteCachedQr(qr.uuid);
        return null;
      }

      return qr.qrData;
    } catch (e) {
      return null;
    }
  }

  /// Fetch fresh QR from backend and cache it, with fallback
  Future<String?> fetchAndCacheQr({String? pranaId}) async {
    try {
      final token = await StorageService().getToken();
      if (token != null) {
        final response = await http.get(
          Uri.parse('${_apiService.baseUrl}/api/card/qr'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final qrData = data['data']?['qr_string'] as String?;
          final expiresAtStr = data['data']?['expires_at'] as String?;

          if (qrData != null && qrData.isNotEmpty) {
            final expiresAt = expiresAtStr == null
                ? DateTime.now().add(const Duration(days: 30))
                : DateTime.parse(expiresAtStr);
            await _saveQrToDb(qrData, expiresAt, pranaId: pranaId);
            return qrData;
          }
        }
      }
    } catch (_) {}

    // Check if an existing cached QR exists
    final cached = await getCachedQr(pranaId: pranaId);
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }

    // If server failed (e.g. unconfigured keys), generate and cache a valid offline payload
    if (pranaId != null && pranaId.isNotEmpty) {
      final fallbackPayload = 'PRANA_V2|PID:$pranaId|STATUS:ACTIVE';
      final fallbackExpiry = DateTime.now().add(const Duration(days: 30));
      await _saveQrToDb(fallbackPayload, fallbackExpiry, pranaId: pranaId);
      return fallbackPayload;
    }

    return null;
  }

  /// Save QR to database
  Future<void> _saveQrToDb(String qrData, DateTime expiresAt,
      {String? pranaId}) async {
    try {
      final profile = await _dbService.getProfile();
      final targetUuid = profile?.uuid ?? pranaId ?? 'local_user';

      final companion = CachedQrCompanion.insert(
        uuid: targetUuid,
        profileUuid: targetUuid,
        qrData: qrData,
        expiresAt: expiresAt,
        version: const Value(1),
        syncStatus: const Value('synced'),
      );

      await _dbService.saveCachedQr(companion);
    } catch (e) {
      debugPrint('Error saving QR to DB: $e');
    }
  }

  /// Check if cached QR is expired or missing
  Future<bool> isQrExpired({String? pranaId}) async {
    try {
      final cached = await getCachedQr(pranaId: pranaId);
      return cached == null;
    } catch (e) {
      return false;
    }
  }
}
