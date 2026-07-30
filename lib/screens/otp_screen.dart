import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import 'profile_screen.dart';
import 'dashboard_screen.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  const OtpScreen({super.key, required this.phoneNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();
  bool _isLoading = false;

  void _verifyOtp() async {
    if (_otpController.text.length < 4) return;

    setState(() => _isLoading = true);
    try {
      final response = await _apiService.verifyOtp(widget.phoneNumber, _otpController.text);
      await _storageService.saveToken(response['token']);

      if (mounted) {
        if (response['is_new_user'] == true) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
            (route) => false,
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Verify OTP',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Sent to ${widget.phoneNumber}',
              style: const TextStyle(color: PranaColors.textGray),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 8),
              decoration: const InputDecoration(
                hintText: '0000',
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _isLoading ? null : _verifyOtp,
              child: _isLoading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Verify'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
