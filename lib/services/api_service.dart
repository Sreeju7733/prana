import 'dart:convert';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

class HealthCacheManager {
  static Map<String, dynamic>? dashboardData;
  static List<dynamic>? emergencyModalPayload;
  static List<dynamic>? medications;
  static List<dynamic>? allergies;
  static List<dynamic>? conditions;
  static List<dynamic>? surgeries;
  static List<dynamic>? devices;
  static List<dynamic>? vitals;
  static Map<String, dynamic>? cardSecurityData;
  static List<dynamic>? scanHistoryData;

  static bool isDirty = true;

  static void invalidate() {
    isDirty = true;
    dashboardData = null;
    emergencyModalPayload = null;
    medications = null;
    allergies = null;
    conditions = null;
    surgeries = null;
    devices = null;
    vitals = null;
    cardSecurityData = null;
    scanHistoryData = null;
  }
}

class ApiService {
  final String baseUrl = "https://hat-cross-sapphire-diploma.trycloudflare.com";

  Future<Map<String, dynamic>> sendOtp(String phoneNumber) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/send-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phoneNumber}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['error'] ?? 'Failed to send OTP');
    }
  }

  Future<Map<String, dynamic>> resendOtp(String phoneNumber) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/resend-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phoneNumber}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data['data'] as Map<String, dynamic>;
    } else if (response.statusCode == 429) {
      final err = data['error'] ?? {};
      throw Exception(
          err['message'] ?? 'Please wait before requesting another OTP');
    } else {
      final err = data['error'] ?? {};
      throw Exception(err['message'] ?? 'Failed to resend OTP');
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String phoneNumber, String otp) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone': phoneNumber,
        'otp': otp,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['error'] ?? 'Invalid or expired OTP');
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    final token = await StorageService().getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/api/patient/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['error'] ?? 'Failed to fetch profile');
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    String? fullName,
    String? gender,
    String? dateOfBirth,
    String? bloodGroup,
    double? weightKg,
    double? heightCm,
    String? avatarUrl,
  }) async {
    final token = await StorageService().getToken();
    final Map<String, dynamic> body = {};
    if (fullName != null) body['full_name'] = fullName;
    if (gender != null) body['gender'] = gender;
    if (dateOfBirth != null) body['date_of_birth'] = dateOfBirth;
    if (bloodGroup != null) body['blood_group'] = bloodGroup;
    if (weightKg != null) {
      body['weight_kg'] = weightKg;
      body['weight'] = weightKg;
    }
    if (heightCm != null) {
      body['height_cm'] = heightCm;
      body['height'] = heightCm;
    }
    if (avatarUrl != null) body['avatar_url'] = avatarUrl;

    final response = await http.put(
      Uri.parse('$baseUrl/api/patient/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      HealthCacheManager.invalidate();
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['error'] ?? 'Failed to update profile');
    }
  }

  Future<String> uploadAvatarBase64(String base64Image) async {
    final token = await StorageService().getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/api/patient/avatar'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'imageBase64': base64Image}),
    );

    if (response.statusCode == 200) {
      HealthCacheManager.invalidate();
      final data = jsonDecode(response.body);
      return data['avatar_url'] ?? base64Image;
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['error'] ?? 'Failed to upload avatar');
    }
  }

  // --- MEDICATIONS ---
  Future<List<dynamic>> getMedications({bool forceRefresh = false}) async {
    if (!forceRefresh &&
        !HealthCacheManager.isDirty &&
        HealthCacheManager.medications != null) {
      return HealthCacheManager.medications!;
    }
    final token = await StorageService().getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/api/medications'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final res = jsonDecode(response.body);
      final list = (res['data'] ?? []) as List<dynamic>;
      HealthCacheManager.medications = list;
      return list;
    } else {
      throw Exception('Failed to fetch medications');
    }
  }

  Future<Map<String, dynamic>> addMedication(Map<String, dynamic> data) async {
    final token = await StorageService().getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/api/medications'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      HealthCacheManager.invalidate();
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to add medication');
    }
  }

  Future<void> deleteMedication(String id) async {
    final token = await StorageService().getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/api/medications/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200 || response.statusCode == 204) {
      HealthCacheManager.invalidate();
    } else {
      throw Exception('Failed to delete medication');
    }
  }

  // --- ALLERGIES ---
  Future<List<dynamic>> getAllergies({bool forceRefresh = false}) async {
    if (!forceRefresh &&
        !HealthCacheManager.isDirty &&
        HealthCacheManager.allergies != null) {
      return HealthCacheManager.allergies!;
    }
    final token = await StorageService().getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/api/allergies'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final res = jsonDecode(response.body);
      final list = (res['data'] ?? []) as List<dynamic>;
      HealthCacheManager.allergies = list;
      return list;
    } else {
      throw Exception('Failed to fetch allergies');
    }
  }

  Future<Map<String, dynamic>> addAllergy(Map<String, dynamic> data) async {
    final token = await StorageService().getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/api/allergies'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      HealthCacheManager.invalidate();
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to add allergy');
    }
  }

  Future<Map<String, dynamic>> updateAllergy(
      String id, Map<String, dynamic> data) async {
    final token = await StorageService().getToken();
    final response = await http.patch(
      Uri.parse('$baseUrl/api/allergies/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      HealthCacheManager.invalidate();
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update allergy');
    }
  }

  Future<void> deleteAllergy(String id) async {
    final token = await StorageService().getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/api/allergies/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200 || response.statusCode == 204) {
      HealthCacheManager.invalidate();
    } else {
      throw Exception('Failed to delete allergy');
    }
  }

  // --- CONDITIONS & VITALS ---
  Future<List<dynamic>> getConditions() async {
    final token = await StorageService().getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/api/conditions'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final res = jsonDecode(response.body);
      return res['data'] ?? [];
    } else {
      throw Exception('Failed to fetch conditions');
    }
  }

  Future<Map<String, dynamic>> addCondition(Map<String, dynamic> data) async {
    final token = await StorageService().getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/api/conditions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      HealthCacheManager.invalidate();
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to add condition');
    }
  }

  Future<Map<String, dynamic>> updateMedication(
      String id, Map<String, dynamic> data) async {
    final token = await StorageService().getToken();
    final response = await http.patch(
      Uri.parse('$baseUrl/api/medications/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      HealthCacheManager.invalidate();
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update medication');
    }
  }

  Future<Map<String, dynamic>> updateCondition(
      String id, Map<String, dynamic> data) async {
    final token = await StorageService().getToken();
    final response = await http.patch(
      Uri.parse('$baseUrl/api/conditions/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      HealthCacheManager.invalidate();
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update condition');
    }
  }

  Future<void> deleteCondition(String id) async {
    final token = await StorageService().getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/api/conditions/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200 || response.statusCode == 204) {
      HealthCacheManager.invalidate();
    } else {
      throw Exception('Failed to delete condition');
    }
  }

  Future<List<dynamic>> getVitals({bool latestOnly = false}) async {
    final token = await StorageService().getToken();
    final url =
        latestOnly ? '$baseUrl/api/vitals?latest=true' : '$baseUrl/api/vitals';
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final res = jsonDecode(response.body);
      return res['data'] ?? [];
    } else {
      throw Exception('Failed to fetch vitals');
    }
  }

  // --- SURGERIES & PROCEDURES ---
  Future<List<dynamic>> getSurgeries() async {
    final token = await StorageService().getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/api/surgeries'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final res = jsonDecode(response.body);
      return res['data'] ?? [];
    } else {
      return [];
    }
  }

  Future<Map<String, dynamic>> addSurgery(Map<String, dynamic> data) async {
    final token = await StorageService().getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/api/surgeries'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(data),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      HealthCacheManager.invalidate();
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to add surgery');
    }
  }

  Future<Map<String, dynamic>> updateSurgery(
      String id, Map<String, dynamic> data) async {
    final token = await StorageService().getToken();
    final response = await http.patch(
      Uri.parse('$baseUrl/api/surgeries/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      HealthCacheManager.invalidate();
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update surgery');
    }
  }

  Future<void> deleteSurgery(String id) async {
    final token = await StorageService().getToken();
    final res = await http.delete(
      Uri.parse('$baseUrl/api/surgeries/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200 || res.statusCode == 204) {
      HealthCacheManager.invalidate();
    }
  }

  // --- IMPLANTED DEVICES ---
  Future<List<dynamic>> getDevices() async {
    final token = await StorageService().getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/api/devices'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final res = jsonDecode(response.body);
      return res['data'] ?? [];
    } else {
      return [];
    }
  }

  Future<Map<String, dynamic>> addDevice(Map<String, dynamic> data) async {
    final token = await StorageService().getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/api/devices'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(data),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      HealthCacheManager.invalidate();
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to add device');
    }
  }

  Future<Map<String, dynamic>> updateDevice(
      String id, Map<String, dynamic> data) async {
    final token = await StorageService().getToken();
    final response = await http.patch(
      Uri.parse('$baseUrl/api/devices/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      HealthCacheManager.invalidate();
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update device');
    }
  }

  Future<void> deleteDevice(String id) async {
    final token = await StorageService().getToken();
    final res = await http.delete(
      Uri.parse('$baseUrl/api/devices/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200 || res.statusCode == 204) {
      HealthCacheManager.invalidate();
    }
  }

  Future<Map<String, dynamic>> logVital(Map<String, dynamic> data) async {
    final token = await StorageService().getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/api/vitals'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      HealthCacheManager.invalidate();
      return jsonDecode(response.body);
    } else {
      final res = jsonDecode(response.body);
      throw Exception(res['error'] ?? 'Failed to log vital');
    }
  }

  Future<Map<String, dynamic>> updateVital(
      String id, Map<String, dynamic> data) async {
    final token = await StorageService().getToken();
    final response = await http.patch(
      Uri.parse('$baseUrl/api/vitals/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      HealthCacheManager.invalidate();
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update vital');
    }
  }

  Future<void> deleteVital(String id) async {
    final token = await StorageService().getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/api/vitals/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200 || response.statusCode == 204) {
      HealthCacheManager.invalidate();
    } else {
      throw Exception('Failed to delete vital');
    }
  }

  // --- DASHBOARD HYDRATION ---
  Future<Map<String, dynamic>> getDashboard({bool forceRefresh = false}) async {
    if (!forceRefresh &&
        !HealthCacheManager.isDirty &&
        HealthCacheManager.dashboardData != null) {
      return HealthCacheManager.dashboardData!;
    }
    final token = await StorageService().getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/api/dashboard'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final res = jsonDecode(response.body);
      final data = (res['data'] ?? {}) as Map<String, dynamic>;
      HealthCacheManager.dashboardData = data;
      return data;
    } else {
      throw Exception('Failed to hydrate dashboard');
    }
  }

  // --- BRIEFING REGENERATION ---
  Future<Map<String, dynamic>> regenerateBriefing() async {
    final token = await StorageService().getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/api/briefing/regenerate'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 429) {
      final res = jsonDecode(response.body);
      throw Exception(res['error']?['message'] ??
          'Rate limited. Please wait a few minutes.');
    } else {
      final res = jsonDecode(response.body);
      throw Exception(
          res['error']?['message'] ?? 'Failed to regenerate briefing');
    }
  }

  Future<Map<String, dynamic>> getCardSecurity(
      {bool forceRefresh = false}) async {
    if (!forceRefresh &&
        !HealthCacheManager.isDirty &&
        HealthCacheManager.cardSecurityData != null) {
      return HealthCacheManager.cardSecurityData!;
    }
    try {
      final token = await StorageService().getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/api/card/security'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body) as Map<String, dynamic>;
        final data = (parsed['data'] is Map<String, dynamic>)
            ? parsed['data'] as Map<String, dynamic>
            : parsed;

        final cardStatus = data['card_status']?.toString();
        data['is_suspended'] =
            cardStatus == 'suspended' || cardStatus == 'deactivated';
        HealthCacheManager.cardSecurityData = data;
        return data;
      }
    } catch (_) {}
    return {
      'is_suspended': false,
      'card_status': 'active',
      'scans_used_today': 0,
      'scans_max_quota': 10,
    };
  }

  Future<Map<String, dynamic>> toggleCardStatus(bool isSuspended) async {
    final token = await StorageService().getToken();
    final endpoint = isSuspended ? 'suspend' : 'reactivate';
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/card/$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          if (isSuspended) 'reason': 'User requested suspension',
        }),
      );
      if (response.statusCode == 200) {
        final res = jsonDecode(response.body) as Map<String, dynamic>;
        HealthCacheManager.cardSecurityData ??= <String, dynamic>{};
        HealthCacheManager.cardSecurityData!['is_suspended'] = isSuspended;
        HealthCacheManager.cardSecurityData!['card_status'] =
            isSuspended ? 'suspended' : 'active';
        return res;
      }
    } catch (_) {}

    // Fallback to PATCH /api/card/security
    try {
      final patchResponse = await http.patch(
        Uri.parse('$baseUrl/api/card/security'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'card_status': isSuspended ? 'suspended' : 'active',
        }),
      );
      if (patchResponse.statusCode == 200) {
        final res = jsonDecode(patchResponse.body) as Map<String, dynamic>;
        HealthCacheManager.cardSecurityData ??= <String, dynamic>{};
        HealthCacheManager.cardSecurityData!['is_suspended'] = isSuspended;
        HealthCacheManager.cardSecurityData!['card_status'] =
            isSuspended ? 'suspended' : 'active';
        return res;
      }
    } catch (_) {}

    if (HealthCacheManager.cardSecurityData != null) {
      HealthCacheManager.cardSecurityData!['is_suspended'] = isSuspended;
      HealthCacheManager.cardSecurityData!['card_status'] =
          isSuspended ? 'suspended' : 'active';
    }
    return {'success': true, 'is_suspended': isSuspended};
  }

  Future<Map<String, dynamic>> removeOldCard() async {
    final token = await StorageService().getToken();
    try {
      // Set card_status to deactivated in security endpoint
      final patchResponse = await http.patch(
        Uri.parse('$baseUrl/api/card/security'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'card_status': 'deactivated',
        }),
      );
      if (patchResponse.statusCode == 200) {
        HealthCacheManager.cardSecurityData ??= <String, dynamic>{};
        HealthCacheManager.cardSecurityData!['card_status'] = 'deactivated';
        HealthCacheManager.cardSecurityData!['is_suspended'] = true;
        return jsonDecode(patchResponse.body);
      }
    } catch (_) {}
    return {'success': true, 'card_status': 'deactivated'};
  }

  Future<List<dynamic>> getScanHistory({bool forceRefresh = false}) async {
    try {
      final token = await StorageService().getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/api/card/scan-history'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        final list = (res['data'] as List<dynamic>?) ?? [];
        HealthCacheManager.scanHistoryData = list;
        return list;
      }
    } catch (_) {}
    return [];
  }

  Future<Map<String, dynamic>> placeCardOrder(
      Map<String, dynamic> orderData) async {
    final token = await StorageService().getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/api/card/order'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(orderData),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      return {
        'success': true,
        'order_id': 'ORD-${DateTime.now().millisecondsSinceEpoch}'
      };
    }
  }

  // --- SCANNER & INTERACTION CHECKER ---
  Future<Map<String, dynamic>> checkDrugInteraction(
      String candidateDrug) async {
    final token = await StorageService().getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/api/checker/drug-interaction'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'candidate_drug': candidateDrug}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to check drug interaction');
    }
  }

  static String cleanPhoneNumber(dynamic raw) {
    if (raw == null) return '';
    final str = raw.toString().trim();
    if (str.startsWith('ENC:')) {
      try {
        final decoded = utf8.decode(base64Decode(str.substring(4)));
        if (decoded.isNotEmpty) return decoded.trim();
      } catch (_) {}
    }
    return str;
  }

  // --- EMERGENCY CONTACTS ---
  Future<Map<String, dynamic>> addEmergencyContact(
      Map<String, dynamic> contactData) async {
    final token = await StorageService().getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/api/emergency-contacts'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(contactData),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final res = jsonDecode(response.body) as Map<String, dynamic>;
      if (res['data'] is Map) {
        final d = Map<String, dynamic>.from(res['data'] as Map);
        final cleaned = cleanPhoneNumber(d['phone'] ?? d['phone_number']);
        d['phone'] = cleaned;
        d['phone_number'] = cleaned;
        res['data'] = d;
      }
      return res;
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['error'] ?? 'Failed to add emergency contact');
    }
  }

  Future<List<dynamic>> getEmergencyContacts() async {
    final token = await StorageService().getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/api/emergency-contacts'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final rawList = (data['data'] as List<dynamic>?) ?? [];
      return rawList.map((item) {
        if (item is Map) {
          final copy = Map<String, dynamic>.from(item);
          final cleaned =
              cleanPhoneNumber(copy['phone'] ?? copy['phone_number']);
          copy['phone'] = cleaned;
          copy['phone_number'] = cleaned;
          return copy;
        }
        return item;
      }).toList();
    } else {
      return [];
    }
  }

  Future<Map<String, dynamic>> updateEmergencyContact(
      String id, Map<String, dynamic> contactData) async {
    final token = await StorageService().getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/api/emergency-contacts/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(contactData),
    );

    if (response.statusCode == 200) {
      final res = jsonDecode(response.body) as Map<String, dynamic>;
      if (res['data'] is Map) {
        final d = Map<String, dynamic>.from(res['data'] as Map);
        final cleaned = cleanPhoneNumber(d['phone'] ?? d['phone_number']);
        d['phone'] = cleaned;
        d['phone_number'] = cleaned;
        res['data'] = d;
      }
      return res;
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(
          errorData['error'] ?? 'Failed to update emergency contact');
    }
  }

  Future<void> deleteEmergencyContact(String id) async {
    final token = await StorageService().getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/api/emergency-contacts/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete emergency contact');
    }
  }

  // Insurance API Methods
  Future<Map<String, dynamic>?> getInsurance() async {
    try {
      final token = await StorageService().getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/api/insurance'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] as Map<String, dynamic>?;
      }
    } catch (_) {}
    return null;
  }

  Future<Map<String, dynamic>> saveInsurance(
      Map<String, dynamic> insuranceData) async {
    final token = await StorageService().getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/api/insurance'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(insuranceData),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['error'] ?? 'Failed to save insurance');
    }
  }

  Future<void> deleteInsurance() async {
    final token = await StorageService().getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/api/insurance'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete insurance');
    }
  }
}
