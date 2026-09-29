import 'dart:convert';
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
  Future<String?> getCachedQr() async {
    try {
      final profile = await _dbService.getProfile();
      if (profile == null) return null;
      
      final qr = await _dbService.getCachedQr(profile.uuid);
      if (qr == null) return null;
      
      final now = DateTime.now();
      if (qr.expiresAt.isBefore(now)) {
        // Expired - clear cache
        await _dbService.clearProfileData(profile.uuid);
        return null;
      }
      
      return qr.qrData;
    } catch (e) {
      return null;
    }
  }

  /// Fetch fresh QR from backend and cache it
  Future<String?> fetchAndCacheQr() async {
    try {
      final token = await StorageService().getToken();
      if (token == null) return null;
      
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
        
        if (qrData != null && expiresAtStr != null) {
          await _saveQrToDb(qrData, DateTime.parse(expiresAtStr));
          return qrData;
        }
      }
    } catch (e) {
      // Return cached if available
      return getCachedQr();
    }
    return null;
  }

  /// Save QR to database
  Future<void> _saveQrToDb(String qrData, DateTime expiresAt) async {
    try {
      final profile = await _dbService.getProfile();
      if (profile == null) return;
      
      final companion = CachedQrCompanion.insert(
        uuid: profile.uuid,
        profileUuid: profile.uuid,
        qrData: qrData,
        expiresAt: expiresAt,
        version: const Value(1),
        syncStatus: const Value('synced'),
      );
      
      await _dbService.saveCachedQr(companion);
    } catch (e) {
      print('Error saving QR to DB: $e');
    }
  }

  /// Check if cached QR is expired or missing
  Future<bool> isQrExpired() async {
    try {
      final profile = await _dbService.getProfile();
      if (profile == null) return true;
      
      final qr = await _dbService.getCachedQr(profile.uuid);
      if (qr == null) return true;
      
      return qr.expiresAt.isBefore(DateTime.now());
    } catch (e) {
      return true;
    }
  }
}
