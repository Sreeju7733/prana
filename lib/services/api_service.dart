import 'dart:convert';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

class ApiService {
  final String baseUrl = "http://192.168.1.27:3000";

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
      throw Exception(err['message'] ?? 'Please wait before requesting another OTP');
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
  }) async {
    final token = await StorageService().getToken();
    final Map<String, dynamic> body = {};
    if (fullName != null) body['full_name'] = fullName;
    if (gender != null) body['gender'] = gender;
    if (dateOfBirth != null) body['date_of_birth'] = dateOfBirth;
    if (bloodGroup != null) body['blood_group'] = bloodGroup;
    if (weightKg != null) body['weight_kg'] = weightKg;
    if (heightCm != null) body['height_cm'] = heightCm;

    final response = await http.put(
      Uri.parse('$baseUrl/api/patient/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['error'] ?? 'Failed to update profile');
    }
  }
  // --- MEDICATIONS ---
  Future<List<dynamic>> getMedications() async {
    final token = await StorageService().getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/api/medications'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final res = jsonDecode(response.body);
      return res['data'] ?? [];
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
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete medication');
    }
  }

  // --- ALLERGIES ---
  Future<List<dynamic>> getAllergies() async {
    final token = await StorageService().getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/api/allergies'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final res = jsonDecode(response.body);
      return res['data'] ?? [];
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
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to add allergy');
    }
  }

  Future<void> deleteAllergy(String id) async {
    final token = await StorageService().getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/api/allergies/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
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
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to add condition');
    }
  }

  Future<List<dynamic>> getVitals() async {
    final token = await StorageService().getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/api/vitals'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final res = jsonDecode(response.body);
      return res['data'] ?? [];
    } else {
      throw Exception('Failed to fetch vitals');
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
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to log vital');
    }
  }

  // --- DASHBOARD HYDRATION ---
  Future<Map<String, dynamic>> getDashboard() async {
    final token = await StorageService().getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/api/dashboard'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final res = jsonDecode(response.body);
      return res['data'] ?? {};
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
      throw Exception(res['error']?['message'] ?? 'Rate limited. Please wait a few minutes.');
    } else {
      final res = jsonDecode(response.body);
      throw Exception(res['error']?['message'] ?? 'Failed to regenerate briefing');
    }
  }

  Future<Map<String, dynamic>> getCardSecurity() async {
    final token = await StorageService().getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/api/card/security'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch card security status');
    }
  }

  // --- SCANNER & INTERACTION CHECKER ---
  Future<Map<String, dynamic>> checkDrugInteraction(String candidateDrug) async {
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
}
