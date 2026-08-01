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
}
