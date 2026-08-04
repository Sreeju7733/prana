import 'package:flutter/material.dart';
import '../main_navigation_screen.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import 'onboarding_screen.dart';
import 'profile_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final token = await StorageService().getToken();
    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      try {
        final profileRes = await ApiService().getProfile();
        final profile = profileRes['profile'] ?? profileRes['data'];
        final String? fullName = profile != null ? profile['full_name']?.toString().trim() : null;

        if (!mounted) return;

        if (fullName != null && fullName.isNotEmpty && fullName != 'undefined') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
          );
        } else {
          try {
            final dash = await ApiService().getDashboard();
            final dashProfile = dash['profile'];
            final dashName = dashProfile != null ? dashProfile['full_name']?.toString().trim() : null;
            if (dashName != null && dashName.isNotEmpty && dashName != 'undefined') {
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
                );
                return;
              }
            }
          } catch (_) {}

          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          }
        }
      } catch (_) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/app_icon.png',
              width: 140,
              height: 140,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),
            Text(
              'YOUR MEDICAL IDENTITY',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
