import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ApiService _apiService = ApiService();
  String _userName = 'Sreeju S';
  String _bloodGroup = 'B+';
  String _dob = '26/01/2007';
  String _gender = 'Male';
  String _weight = '68 kg';
  String _height = '175 cm';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final dashboard = await _apiService.getDashboard(forceRefresh: true);
      final profile = dashboard['profile'] as Map<String, dynamic>?;
      if (profile != null && mounted) {
        _applyProfileData(profile);
      }
      final direct = await _apiService.getProfile();
      final directProf = direct['profile'] as Map<String, dynamic>?;
      if (directProf != null && mounted) {
        _applyProfileData(directProf);
      }
    } catch (_) {}
  }

  void _applyProfileData(Map<String, dynamic> profile) {
    setState(() {
      if (profile['full_name'] != null && profile['full_name'].toString().trim().isNotEmpty && profile['full_name'].toString().trim() != 'undefined') {
        _userName = profile['full_name'].toString().trim();
      }
      if (profile['blood_group'] != null && profile['blood_group'].toString().trim().isNotEmpty && profile['blood_group'].toString().trim() != 'undefined') {
        _bloodGroup = profile['blood_group'].toString().trim();
      }
      if (profile['date_of_birth'] != null && profile['date_of_birth'].toString().trim().isNotEmpty && profile['date_of_birth'].toString().trim() != 'undefined') {
        final rawDob = profile['date_of_birth'].toString().trim().split('T').first;
        final parts = rawDob.split('-');
        if (parts.length == 3) {
          _dob = '${parts[2]}/${parts[1]}/${parts[0]}';
        } else {
          _dob = rawDob;
        }
      }
      if (profile['gender'] != null && profile['gender'].toString().trim().isNotEmpty && profile['gender'].toString().trim() != 'undefined') {
        final g = profile['gender'].toString().trim().toUpperCase();
        _gender = (g == 'M' || g == 'MALE') ? 'Male' : ((g == 'F' || g == 'FEMALE') ? 'Female' : g);
      }
      if (profile['weight_kg'] != null && profile['weight_kg'].toString().trim().isNotEmpty) {
        _weight = '${profile['weight_kg']} kg';
      } else if (profile['weight'] != null && profile['weight'].toString().trim().isNotEmpty && profile['weight'].toString().trim() != 'undefined') {
        _weight = '${profile['weight']} kg';
      }
      if (profile['height_cm'] != null && profile['height_cm'].toString().trim().isNotEmpty) {
        _height = '${profile['height_cm']} cm';
      } else if (profile['height'] != null && profile['height'].toString().trim().isNotEmpty && profile['height'].toString().trim() != 'undefined') {
        _height = '${profile['height']} cm';
      }
    });
  }


  void _showEmergencyDashboardModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Color(0xFF991B1B),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.emergency_rounded, color: Color(0xFF991B1B), size: 28),
                ),
                const SizedBox(width: 12),
                const Text('🚨 EMERGENCY ACTIVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20, letterSpacing: 1)),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('STATUS: Ambulance En Route', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF991B1B))),
                  SizedBox(height: 4),
                  Text('Target: AIIMS Delhi • ETA: 6 mins', style: TextStyle(color: Color(0xFF475569))),
                  SizedBox(height: 12),
                  LinearProgressIndicator(value: 0.7, backgroundColor: Color(0xFFFEE2E2), valueColor: AlwaysStoppedAnimation(Color(0xFF991B1B))),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Shared Medical Emergency Briefing:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('• Patient: John Doe (O+)\n• Critical: Penicillin Allergy\n• Primary Contact Notified via SMS', style: TextStyle(color: Colors.white70, height: 1.5)),
                  ],
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF991B1B)),
              onPressed: () => Navigator.pop(context),
              child: const Text('Close Emergency Dashboard'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Settings & Emergency'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Live Emergency Trigger Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.emergency, color: Colors.red, size: 32),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Live Emergency Mode', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF991B1B))),
                        Text('Tap to simulate live responder tracking', style: TextStyle(fontSize: 12, color: Color(0xFFB91C1C))),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(80, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    onPressed: _showEmergencyDashboardModal,
                    child: const Text('View 🚨', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Profile Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                        child: Icon(Icons.person, color: theme.primaryColor, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_userName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                            const SizedBox(height: 2),
                            Text('$_gender • $_dob', style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())).then((_) => _loadProfile());
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text('Edit Profile >', style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildProfileDetailItem('Blood Group', _bloodGroup, Icons.water_drop_outlined, Colors.red),
                      _buildProfileDetailItem('Weight', _weight, Icons.monitor_weight_outlined, Colors.teal),
                      _buildProfileDetailItem('Height', _height, Icons.height_outlined, Colors.indigo),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),



            // Data & Privacy
            Text('DATA & PRIVACY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: Colors.grey.shade600)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  const ListTile(
                    leading: Icon(Icons.verified_user_outlined, color: Colors.green),
                    title: Text('Encryption Status'),
                    subtitle: Text('Active (End-to-End Encrypted)'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.download_outlined, color: Color(0xFF0284C7)),
                    title: const Text('Export My Data'),
                    subtitle: const Text('Download FHIR JSON Format'),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exporting FHIR JSON data...')));
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.delete_outline, color: Colors.red),
                    title: const Text('Delete Account', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),


            const SizedBox(height: 32),
            const Center(
              child: Text('PRANA Health App v1.0.0+1', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDetailItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
      ],
    );
  }
}
