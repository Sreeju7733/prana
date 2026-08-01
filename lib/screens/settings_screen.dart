import 'package:flutter/material.dart';
import 'profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _alertScan = true;
  bool _alertContacts = true;
  bool _includeGps = true;

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
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                    child: Icon(Icons.person, color: theme.primaryColor, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('John Doe', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const Text('PRAN-7843-2910', style: TextStyle(fontFamily: 'monospace', color: Color(0xFF64748B), fontSize: 12)),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
                          },
                          child: Text('Edit Profile >', style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Emergency Contacts Section
            Text('EMERGENCY CONTACTS & FAMILY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: Colors.grey.shade600)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.star, color: Colors.amber),
                    title: const Text('Jane Doe (Wife) ★ Primary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: const Text('Relay Hotline: 1800-PRANA-RELAY'),
                    trailing: OutlinedButton(
                      style: OutlinedButton.styleFrom(minimumSize: const Size(60, 30), padding: EdgeInsets.zero),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Test SMS sent to Jane Doe!')));
                      },
                      child: const Text('Test SMS', style: TextStyle(fontSize: 11)),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.family_restroom_outlined, color: Color(0xFF0284C7)),
                    title: const Text('Manage Dependents / Parents'),
                    subtitle: const Text('PRAN-4491-1102 (Mother) • Synced 1 hr ago'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
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

            // Notifications
            Text('NOTIFICATIONS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: Colors.grey.shade600)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Alert on Every Scan', style: TextStyle(fontSize: 14)),
                    value: _alertScan,
                    onChanged: (val) => setState(() => _alertScan = val),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Alert Emergency Contacts', style: TextStyle(fontSize: 14)),
                    value: _alertContacts,
                    onChanged: (val) => setState(() => _alertContacts = val),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Include GPS in Alerts', style: TextStyle(fontSize: 14)),
                    value: _includeGps,
                    onChanged: (val) => setState(() => _includeGps = val),
                  ),
                ],
              ),
            ),
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
}
