import 'dart:convert';
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
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      // Always fetch fresh data from server to reflect latest edits
      final direct = await _apiService.getProfile();
      final directProf = (direct['profile'] ?? direct['data']) as Map<String, dynamic>?;
      if (directProf != null && mounted) {
        _applyProfileData(directProf);
      }
    } catch (_) {}
  }

  void _openEditProfile() {
    final Map<String, dynamic> currentProfData = {
      'full_name': _userName,
      'blood_group': _bloodGroup,
      'date_of_birth': _dob,
      'gender': _gender,
      'weight': _weight,
      'weight_kg': _weight,
      'height': _height,
      'height_cm': _height,
      'avatar_url': _avatarUrl,
    };
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          isEditMode: true,
          initialProfileData: currentProfData,
        ),
      ),
    ).then((_) => _loadProfile());
  }

  double? _parseNumeric(dynamic val) {
    if (val == null) return null;
    final str = val.toString().trim();
    if (str.isEmpty || str == 'null' || str == 'undefined') return null;
    final cleaned = str.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleaned);
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
      final wVal = profile['weight_kg'] ?? profile['weight'];
      if (wVal != null) {
        final parsedW = _parseNumeric(wVal);
        if (parsedW != null) {
          _weight = parsedW % 1 == 0 ? '${parsedW.toInt()} kg' : '$parsedW kg';
        }
      }
      final hVal = profile['height_cm'] ?? profile['height'];
      if (hVal != null) {
        final parsedH = _parseNumeric(hVal);
        if (parsedH != null) {
          _height = parsedH % 1 == 0 ? '${parsedH.toInt()} cm' : '$parsedH cm';
        }
      }
      if (profile['avatar_url'] != null && profile['avatar_url'].toString().trim().isNotEmpty && profile['avatar_url'].toString().trim() != 'undefined') {
        _avatarUrl = profile['avatar_url'].toString().trim();
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

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
                      GestureDetector(
                        onTap: _openEditProfile,
                        child: Stack(
                          children: [
                            ClipOval(
                              child: Container(
                                width: 56,
                                height: 56,
                                color: theme.primaryColor.withValues(alpha: 0.1),
                                child: (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                                    ? (_avatarUrl!.startsWith('data:image')
                                        ? Image.memory(
                                            base64Decode(_avatarUrl!.split(',').last),
                                            fit: BoxFit.cover,
                                            width: 56,
                                            height: 56,
                                          )
                                        : Image.network(
                                            _avatarUrl!,
                                            fit: BoxFit.cover,
                                            width: 56,
                                            height: 56,
                                            errorBuilder: (_, __, ___) => Icon(Icons.person, color: theme.primaryColor, size: 28),
                                          ))
                                    : Icon(Icons.person, color: theme.primaryColor, size: 28),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: theme.primaryColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 1.5),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
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
                        onTap: _openEditProfile,
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
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
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
