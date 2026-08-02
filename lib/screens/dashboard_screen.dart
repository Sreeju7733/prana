import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import 'prescription_scanner_screen.dart';

class DashboardScreen extends StatefulWidget {
  final Function(int tabIndex, {int subTabIndex, bool openAddModal})? onNavigateTab;
  const DashboardScreen({super.key, this.onNavigateTab});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();

  // Static in-memory caches preserved across tab switches
  static Map<String, dynamic>? _cachedDashboardData;
  static List<dynamic>? _cachedEmergencyModalPayload;

  Map<String, dynamic>? _dashboardData;

  Map<String, dynamic> _getFallbackDashboardData() {
    return {
      'profile': {
        'full_name': 'Sreeju S',
        'blood_group': 'B+',
        'prana_id': 'PRAN-2973CAC1',
        'date_of_birth': '2007-01-26',
        'no_known_allergies': false,
        'allergies_recorded': true,
      },
      'health_summary': {
        'critical_allergy': null,
        'allergies_count': 0,
        'meds_count': 0,
        'conditions_count': 0,
      },
      'recent_scans': [],
    };
  }

  @override
  void initState() {
    super.initState();
    // Instant local state - ZERO loading spinner on app launch or dashboard visit
    _dashboardData = _cachedDashboardData ?? HealthCacheManager.dashboardData ?? _getFallbackDashboardData();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    try {
      final res = await _apiService.getDashboard();
      if (mounted) {
        final newJson = jsonEncode(res);
        final oldJson = jsonEncode(_cachedDashboardData);

        // Update state and cache ONLY if data changed or cache was initial fallback
        if (_cachedDashboardData == null || newJson != oldJson) {
          _cachedDashboardData = res;
          HealthCacheManager.dashboardData = res;
          setState(() {
            _dashboardData = res;
          });
        }
      }
    } catch (_) {}
  }

  String _getUserFirstName() {
    final fullName = _dashboardData?['profile']?['full_name'];
    if (fullName != null && fullName.toString().trim().isNotEmpty) {
      return fullName.toString().trim().split(' ').first;
    }
    return 'User';
  }

  String _formatDob(String raw) {
    final s = raw.trim();
    if (s.isEmpty || s == 'null' || s == 'Not specified') return 'Not specified';
    try {
      final clean = s.split('T').first;
      final parts = clean.split('-');
      if (parts.length == 3) {
        return '${parts[2]}/${parts[1]}/${parts[0]}';
      }
      return clean;
    } catch (_) {
      return s;
    }
  }

  void _copyPranaId() {
    final String pranaId = _dashboardData?['profile']?['prana_id'] ?? 'PRAN-2973CAC1';
    Clipboard.setData(ClipboardData(text: pranaId));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('PRANA ID ($pranaId) copied to clipboard!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showEmergencyPreviewModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FutureBuilder<List<dynamic>>(
          initialData: _cachedEmergencyModalPayload,
          future: Future.wait([
            _apiService.getAllergies().catchError((_) => []),
            _apiService.getMedications().catchError((_) => []),
            _apiService.getEmergencyContacts().catchError((_) => []),
            _apiService.getProfile().catchError((_) => <String, dynamic>{}),
            _apiService.getConditions().catchError((_) => []),
            _apiService.getSurgeries().catchError((_) => []),
            _apiService.getDevices().catchError((_) => []),
            _apiService.getVitals(latestOnly: true).catchError((_) => []),
          ]).then((payload) {
            final newJson = jsonEncode(payload);
            final oldJson = jsonEncode(_cachedEmergencyModalPayload);
            if (newJson != oldJson) {
              _cachedEmergencyModalPayload = payload;
            }
            return payload;
          }),
          builder: (context, snapshot) {
            final allergies = snapshot.data != null ? snapshot.data![0] as List : [];
            final medications = snapshot.data != null ? snapshot.data![1] as List : [];
            final contacts = snapshot.data != null ? snapshot.data![2] as List : [];
            final fullProfile = snapshot.data != null && snapshot.data!.length > 3 && snapshot.data![3] is Map
                ? (snapshot.data![3]['data'] ?? snapshot.data![3])
                : null;
            final conditions = snapshot.data != null && snapshot.data!.length > 4 ? snapshot.data![4] as List : [];
            final surgeries = snapshot.data != null && snapshot.data!.length > 5 ? snapshot.data![5] as List : [];
            final devices = snapshot.data != null && snapshot.data!.length > 6 ? snapshot.data![6] as List : [];
            final vitals = snapshot.data != null && snapshot.data!.length > 7 ? snapshot.data![7] as List : [];

            final profile = (fullProfile is Map ? fullProfile : _dashboardData?['profile']) as Map?;
            final String name = profile?['full_name'] ?? 'User';
            final String bloodGroup = profile?['blood_group'] ?? 'B+';
            final String pranaId = profile?['prana_id'] ?? 'PRAN-2973CAC1';
            final String rawDob = (profile?['date_of_birth'] ?? profile?['dob'] ?? profile?['dateOfBirth'] ?? '').toString();
            final String dob = _formatDob(rawDob);
            final bool noKnownAllergies = profile?['no_known_allergies'] == true || (allergies.isEmpty && profile?['allergies_recorded'] == true);

            return Container(
              height: MediaQuery.of(context).size.height * 0.88,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.medical_services_outlined, color: Colors.red, size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Paramedic Emergency View', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('What first responders see on QR scan', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 28),
                  Expanded(
                    child: snapshot.connectionState == ConnectionState.waiting
                        ? const Center(child: CircularProgressIndicator(color: Color(0xFF0D9488)))
                        : ListView(
                            children: [
                              // 1. Patient Identifier Card
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 28,
                                      backgroundColor: const Color(0xFF0D9488),
                                      child: Text(bloodGroup, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                          Text('DOB: $dob', style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                                          Text('PRANA ID: $pranaId', style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w600, color: Color(0xFF0D9488))),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),

                              // 2. Critical Allergies
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: noKnownAllergies ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: noKnownAllergies ? const Color(0xFF86EFAC) : const Color(0xFFFCA5A5)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          noKnownAllergies ? Icons.check_circle_outline_rounded : Icons.warning_amber_rounded,
                                          color: noKnownAllergies ? const Color(0xFF16A34A) : Colors.red,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          noKnownAllergies ? 'NO KNOWN ALLERGIES' : 'CRITICAL ALLERGIES',
                                          style: TextStyle(
                                            color: noKnownAllergies ? const Color(0xFF16A34A) : Colors.red,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    if (noKnownAllergies)
                                      const Text('✅ Patient has recorded No Known Drug or Food Allergies.', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF14532D)))
                                    else if (allergies.isEmpty)
                                      const Text('No allergy records filed.', style: TextStyle(color: Color(0xFF64748B)))
                                    else
                                      ...allergies.where((a) {
                                        final rawName = (a['allergen'] ?? a['name'] ?? '').toString().trim();
                                        return rawName.isNotEmpty && rawName.toLowerCase() != 'null' && rawName.toLowerCase() != 'undefined';
                                      }).map((a) {
                                        final allergen = (a['allergen'] ?? a['name'] ?? 'Allergy').toString().toUpperCase();
                                        final severity = (a['severity'] ?? 'Severe').toString();
                                        final reaction = a['reaction_description'] ?? a['reaction'];
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 4),
                                          child: Text(
                                            '• $allergen ($severity${reaction != null && reaction.toString().isNotEmpty ? " - $reaction" : ""})',
                                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF991B1B)),
                                          ),
                                        );
                                      }),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),

                              // 3. Active Medications
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0FDF4),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFF86EFAC)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.medication_outlined, color: Color(0xFF16A34A), size: 20),
                                        SizedBox(width: 8),
                                        Text('ACTIVE MEDICATIONS', style: TextStyle(color: Color(0xFF16A34A), fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1)),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    if (medications.isEmpty)
                                      const Text('No active medications recorded.', style: TextStyle(color: Color(0xFF64748B)))
                                    else
                                      ...medications.map((m) {
                                        final mName = m['name'] ?? 'Medication';
                                        final dose = m['dose'] ?? '';
                                        final freq = m['frequency'] ?? '';
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 4),
                                          child: Text(
                                            '• $mName ${dose.toString().isNotEmpty ? dose : ""} ${freq.toString().isNotEmpty ? "($freq)" : ""}'.trim(),
                                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF14532D)),
                                          ),
                                        );
                                      }),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),

                              // 4. Active Medical Conditions
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F3FF),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFDDD6FE)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.assignment_outlined, color: Color(0xFF7C3AED), size: 20),
                                        SizedBox(width: 8),
                                        Text('MEDICAL CONDITIONS', style: TextStyle(color: Color(0xFF7C3AED), fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1)),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    if (conditions.isEmpty)
                                      const Text('No chronic conditions recorded.', style: TextStyle(color: Color(0xFF64748B)))
                                    else
                                      ...conditions.map((c) {
                                        final cName = c['name'] ?? 'Condition';
                                        final cStatus = c['status'] ?? 'Active';
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 4),
                                          child: Text(
                                            '• $cName ($cStatus)',
                                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5B21B6)),
                                          ),
                                        );
                                      }),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),

                              // 5. Medical Devices & Implants
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF7ED),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFFED7AA)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.memory_outlined, color: Color(0xFFC2410C), size: 20),
                                        SizedBox(width: 8),
                                        Text('IMPLANTED DEVICES / WEARABLES', style: TextStyle(color: Color(0xFFC2410C), fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1)),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    if (devices.isEmpty)
                                      const Text('No medical devices or implants logged.', style: TextStyle(color: Color(0xFF64748B)))
                                    else
                                      ...devices.map((d) {
                                        final devName = d['device_name'] ?? d['name'] ?? 'Medical Device';
                                        final serial = d['serial_number'] ?? d['serial'] ?? '';
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 4),
                                          child: Text(
                                            '• $devName ${serial.toString().isNotEmpty ? "(SN: $serial)" : ""}'.trim(),
                                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF9A3412)),
                                          ),
                                        );
                                      }),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),

                              // 6. Surgeries & Procedures
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFDF4FF),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFF5D0FE)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.healing_outlined, color: Color(0xFFC026D3), size: 20),
                                        SizedBox(width: 8),
                                        Text('SURGERIES & PROCEDURES', style: TextStyle(color: Color(0xFFC026D3), fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1)),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    if (surgeries.isEmpty)
                                      const Text('No prior surgeries or procedures recorded.', style: TextStyle(color: Color(0xFF64748B)))
                                    else
                                      ...surgeries.map((s) {
                                        final procName = s['procedure_name'] ?? s['name'] ?? 'Procedure';
                                        final hospital = s['hospital'] ?? '';
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 4),
                                          child: Text(
                                            '• $procName ${hospital.toString().isNotEmpty ? "($hospital)" : ""}'.trim(),
                                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF86198F)),
                                          ),
                                        );
                                      }),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),

                              // 7. Last Recorded Vitals
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0FDF4),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFBBF7D0)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.favorite_outline, color: Color(0xFF15803D), size: 20),
                                        SizedBox(width: 8),
                                        Text('LAST RECORDED VITALS', style: TextStyle(color: Color(0xFF15803D), fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1)),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    if (vitals.isEmpty)
                                      const Text('No vital logs filed.', style: TextStyle(color: Color(0xFF64748B)))
                                    else
                                      ...vitals.take(4).map((v) {
                                        final type = (v['vital_type'] ?? 'vital').toString().replaceAll('_', ' ').toUpperCase();
                                        final val = v['value'] ?? '';
                                        final unit = v['unit'] ?? '';
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 4),
                                          child: Text(
                                            '• $type: $val $unit'.trim(),
                                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF166534)),
                                          ),
                                        );
                                      }),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),

                              // 8. Emergency Relay Contact
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0F9FF),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFBAE6FD)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.phone_in_talk_outlined, color: Color(0xFF0284C7), size: 20),
                                        SizedBox(width: 8),
                                        Text('EMERGENCY RELAY CONTACT', style: TextStyle(color: Color(0xFF0284C7), fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1)),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    if (contacts.isEmpty)
                                      const Text('No primary emergency contact recorded.', style: TextStyle(color: Color(0xFF64748B)))
                                    else
                                      ...contacts.map((c) {
                                        final cName = c['name'] ?? 'Primary Contact';
                                        final cRel = c['relationship'] ?? 'Family';
                                        final cPhone = c['phone_number'] ?? c['phone'] ?? '';
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 4),
                                          child: Text('$cName ($cRel) • $cPhone', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0C4A6E))),
                                        );
                                      }),
                                    const SizedBox(height: 4),
                                    const Text('Relay Hotline: 1800-PRANA-RELAY (Option 1)', style: TextStyle(color: Color(0xFF0C4A6E), fontSize: 12)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmergencySummaryCard(Map<String, dynamic>? data, String bloodGroup, String topAllergy, int medsCount, int conditionsCount) {
    final profile = data?['profile'];
    final healthSummary = data?['health_summary'];
    final bool noKnownAllergies = profile?['no_known_allergies'] == true || (healthSummary?['allergies_count'] == 0 && profile?['allergies_recorded'] == true);

    List<Widget> badges = [];

    // Badge 1: Blood Group (High Visual Weight - Bystander Tier)
    badges.add(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFCA5A5), width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🩸 ', style: TextStyle(fontSize: 14)),
            Text(
              bloodGroup,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFFDC2626)),
            ),
          ],
        ),
      ),
    );

    // Badge 2: Allergies State (High Visual Weight - Bystander Tier)
    if (noKnownAllergies) {
      badges.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF86EFAC), width: 1.5),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('✅ ', style: TextStyle(fontSize: 14)),
              Text(
                'No Known Allergies',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF166534)),
              ),
            ],
          ),
        ),
      );
    } else if (healthSummary?['critical_allergy'] != null) {
      final ca = healthSummary['critical_allergy'];
      badges.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFDBA74), width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⚠️ ', style: TextStyle(fontSize: 14)),
              Text(
                '${ca['allergen']} (${ca['severity'] ?? "Severe"})',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFFC2410C)),
              ),
            ],
          ),
        ),
      );
    }

    // Badge 3: Active Meds Count (Muted Visual Weight - Paramedic Tier, Pluralization Fixed)
    if (medsCount > 0) {
      badges.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('💊 ', style: TextStyle(fontSize: 12)),
              Text(
                medsCount == 1 ? '1 Active Med' : '$medsCount Active Meds',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      );
    } else {
      badges.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('💊 ', style: TextStyle(fontSize: 12)),
              Text(
                'No meds recorded',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
        ),
      );
    }

    // Badge 4: Conditions (Muted Visual Weight - Paramedic Tier)
    if (conditionsCount > 0) {
      badges.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('❤️ ', style: TextStyle(fontSize: 12)),
              Text(
                conditionsCount == 1 ? '1 Condition' : '$conditionsCount Conditions',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: badges,
    );
  }

  Widget _buildDynamicHintCard(int medsCount, int conditionsCount) {
    if (medsCount == 0 && conditionsCount == 0) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDFA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF99F6E4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Text('💊', style: TextStyle(fontSize: 18)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "You haven't added your health records yet.",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              "Add prescriptions or medical conditions to inform first responders during emergencies.",
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  if (widget.onNavigateTab != null) widget.onNavigateTab!(1, subTabIndex: 0, openAddModal: false);
                },
                child: const Text('Add Health Records', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      );
    }

    // Silence = everything is fine. Complete state suppresses the banner to avoid redundancy with the green Active status dot.
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final profile = _dashboardData?['profile'];
    final healthSummary = _dashboardData?['health_summary'];
    final recentScans = (_dashboardData?['recent_scans'] as List?) ?? [];

    final String pranaId = profile?['prana_id'] ?? 'PRAN-2973CAC1';
    final String bloodGroup = profile?['blood_group'] ?? 'B+';
    final criticalAllergy = healthSummary?['critical_allergy'];
    final String topAllergy = criticalAllergy != null
        ? '${criticalAllergy['allergen']} — ${criticalAllergy['severity'] ?? "Severe"}'
        : 'Penicillin — Severe';

    final int medsCount = healthSummary?['meds_count'] ?? 0;
    final int conditionsCount = healthSummary?['conditions_count'] ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header (2 lines max: Active status + Hello + Monospace PRANA ID + Trust Signal)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(color: Color(0xFF0D9488), shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Active',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0D9488)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Hello, ${_getUserFirstName()}',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), letterSpacing: -0.5),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Profile verified & active',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: _copyPranaId,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Text(
                            pranaId,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.copy_rounded, size: 14, color: Color(0xFF64748B)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 3. Emergency Health Overview Card (Dynamic Badges)
              GestureDetector(
                onTap: _showEmergencyPreviewModal,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: const [
                      BoxShadow(color: Color(0x04000000), blurRadius: 10, offset: Offset(0, 2)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Emergency Profile Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                          const Text('View QR →', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0D9488))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildEmergencySummaryCard(_dashboardData, bloodGroup, topAllergy, medsCount, conditionsCount),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 4. Dynamic Hint Card (Only rendered when profile incomplete)
              _buildDynamicHintCard(medsCount, conditionsCount),

              // 6. Adaptive Quick Actions (Horizontally Scrollable with peek hint)
              Text(
                'QUICK ACTIONS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(right: 8.0),
                child: Row(
                  children: [
                    _buildQuickActionButton(
                      icon: Icons.warning_amber_rounded,
                      label: (healthSummary?['allergies_count'] ?? 0) > 0 || profile?['no_known_allergies'] == true ? 'Manage Allergies' : 'Add Allergy',
                      onTap: () {
                        if (widget.onNavigateTab != null) widget.onNavigateTab!(1, subTabIndex: 1, openAddModal: false);
                      },
                    ),
                    _buildQuickActionButton(
                      icon: Icons.medication_outlined,
                      label: medsCount > 0 ? 'Manage Meds' : 'Add Med',
                      onTap: () {
                        if (widget.onNavigateTab != null) widget.onNavigateTab!(1, subTabIndex: 0, openAddModal: false);
                      },
                    ),
                    _buildQuickActionButton(
                      icon: Icons.camera_alt_outlined,
                      label: 'Scan RX',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PrescriptionScannerScreen()),
                        );
                      },
                    ),
                    _buildQuickActionButton(
                      icon: Icons.favorite_outline,
                      label: 'Log Vitals',
                      onTap: () {
                        if (widget.onNavigateTab != null) widget.onNavigateTab!(1, subTabIndex: 3, openAddModal: false);
                      },
                    ),
                    _buildQuickActionButton(
                      icon: Icons.assignment_outlined,
                      label: conditionsCount > 0 ? 'Manage Conditions' : 'Add Condition',
                      onTap: () {
                        if (widget.onNavigateTab != null) widget.onNavigateTab!(1, subTabIndex: 2, openAddModal: false);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 6. Recent Activity / Scan Log (Explained purpose empty state)
              Text(
                'RECENT FIELD SCANS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: recentScans.isEmpty
                    ? const Row(
                        children: [
                          Icon(Icons.qr_code_scanner_outlined, color: Color(0xFF94A3B8), size: 24),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'No field scans yet',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155)),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'This shows when someone scans your emergency QR — you\'ll be notified instantly.',
                                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: Color(0xFFCCFBF1),
                            child: Icon(Icons.qr_code_scanner, color: Color(0xFF0D9488), size: 20),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(recentScans.first['responder_org'] ?? 'AIIMS Emergency (Paramedic)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                                const SizedBox(height: 2),
                                Text('Scanned ${recentScans.first['scanned_at'] != null ? recentScans.first['scanned_at'].toString().split('T').first : "recently"} • ${recentScans.first['location_city'] ?? "IN"}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                              ],
                            ),
                          ),
                          const Icon(Icons.verified_outlined, color: Color(0xFF0D9488), size: 18),
                        ],
                      ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0D9488).withValues(alpha: 0.08),
                border: Border.all(color: const Color(0xFF0D9488).withValues(alpha: 0.2)),
              ),
              child: Icon(icon, color: const Color(0xFF0D9488), size: 22),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 72,
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


