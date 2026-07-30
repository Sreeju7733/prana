import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "http://10.97.134.37:3000"; // Placeholder

  Future<Map<String, dynamic>> sendOtp(String phoneNumber) async {
    // Simulated API call
    // final response = await http.post(Uri.parse('$baseUrl/api/auth/login'), body: {'phone': phoneNumber});
    await Future.delayed(const Duration(seconds: 1));
    return {'status': 'success'};
  }

  Future<Map<String, dynamic>> verifyOtp(String phoneNumber, String otp) async {
    // Simulated API call for /api/auth/verify-otp
    // final response = await http.post(Uri.parse('$baseUrl/api/auth/verify-otp'), body: {'phone': phoneNumber, 'otp': otp});
    await Future.delayed(const Duration(seconds: 1));

    // Mock response based on requirements
    return {
      'token': 'mock_jwt_token',
      'is_new_user': true, // Change this to test flows
    };
  }

  Future<void> updateProfile({
    required String name,
    required String bloodGroup,
    required double weight,
    required double height,
  }) async {
    // Simulated API call
    await Future.delayed(const Duration(seconds: 1));
  }
}
