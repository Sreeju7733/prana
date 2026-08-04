import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import 'prescription_scanner_screen.dart';

class DashboardScreen extends StatefulWidget {
  final Function(int tabIndex, {int subTabIndex, bool openAddModal})?
      onNavigateTab;
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
  Future<List<dynamic>>? _contactsFuture;
  Future<Map<String, dynamic>?>? _insuranceFuture;

  void _refreshContacts() {
    _cachedEmergencyModalPayload = null;
    HealthCacheManager.isDirty = true;
    setState(() {
      _contactsFuture = _apiService.getEmergencyContacts();
    });
  }

  void _refreshInsurance() {
    setState(() {
      _insuranceFuture = _apiService.getInsurance();
    });
  }

  Future<void> _confirmDeleteDialog({
    required String title,
    required String message,
    required Future<void> Function() onConfirm,
  }) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 12,
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: const Color(0xFFFCA5A5), width: 1.5),
                ),
                child: const Icon(
                  Icons.delete_forever_rounded,
                  color: Color(0xFFDC2626),
                  size: 32,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF475569),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text(
                        'Delete',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm == true) {
      await onConfirm();
      _refreshContacts();
    }
  }

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
    _contactsFuture = _apiService.getEmergencyContacts();
    _insuranceFuture = _apiService.getInsurance();
    _dashboardData = _cachedDashboardData ??
        HealthCacheManager.dashboardData ??
        _getFallbackDashboardData();
    _fetchDashboardData(force: true);
  }

  Future<void> _fetchDashboardData({bool force = false}) async {
    try {
      final results = await Future.wait([
        _apiService
            .getDashboard(forceRefresh: force)
            .catchError((_) => <String, dynamic>{}),
        _apiService
            .getMedications(forceRefresh: force)
            .catchError((_) => <dynamic>[]),
        _apiService
            .getAllergies(forceRefresh: force)
            .catchError((_) => <dynamic>[]),
        _apiService.getConditions().catchError((_) => <dynamic>[]),
      ]);

      final dashRes = results[0] as Map<String, dynamic>;
      final medsList = results[1] as List<dynamic>;
      final allergiesList = results[2] as List<dynamic>;
      final conditionsList = results[3] as List<dynamic>;

      final Map<String, dynamic> merged = Map<String, dynamic>.from(
          dashRes.isNotEmpty ? dashRes : _getFallbackDashboardData());

      merged['health_summary'] =
          Map<String, dynamic>.from(merged['health_summary'] ?? {});
      final healthSummary = merged['health_summary'] as Map<String, dynamic>;

      final int actualMedsCount = medsList.isNotEmpty
          ? medsList.length
          : (healthSummary['meds_count'] ?? 0);
      final int actualAllergiesCount = allergiesList.isNotEmpty
          ? allergiesList.length
          : (healthSummary['allergies_count'] ?? 0);
      final int actualConditionsCount = conditionsList.isNotEmpty
          ? conditionsList.length
          : (healthSummary['conditions_count'] ?? 0);

      healthSummary['meds_count'] = actualMedsCount;
      healthSummary['allergies_count'] = actualAllergiesCount;
      healthSummary['conditions_count'] = actualConditionsCount;

      final critical = allergiesList.firstWhere(
        (a) =>
            a['is_critical'] == true ||
            (a['severity']?.toString().toLowerCase().contains('severe') ??
                false),
        orElse: () => null,
      );

      if (critical != null) {
        healthSummary['critical_allergy'] = {
          'allergen': critical['allergen'],
          'severity': critical['severity'] ?? 'Severe',
        };
      }

      merged['health_summary'] = healthSummary;

      if (merged['profile'] != null) {
        final profile = Map<String, dynamic>.from(merged['profile']);
        if (actualAllergiesCount > 0) {
          profile['no_known_allergies'] = false;
          profile['allergies_recorded'] = true;
        }
        merged['profile'] = profile;
      }

      if (mounted) {
        _cachedDashboardData = merged;
        HealthCacheManager.dashboardData = merged;
        HealthCacheManager.isDirty = false;
        setState(() {
          _dashboardData = merged;
        });
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
    if (s.isEmpty || s == 'null' || s == 'Not specified')
      return 'Not specified';
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
    final String pranaId =
        _dashboardData?['profile']?['prana_id'] ?? 'PRAN-2973CAC1';
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
        return StatefulBuilder(
          builder: (context, setModalState) {
            return FutureBuilder<List<dynamic>>(
              initialData: _cachedEmergencyModalPayload,
              future: (!HealthCacheManager.isDirty &&
                      _cachedEmergencyModalPayload != null)
                  ? Future.value(_cachedEmergencyModalPayload!)
                  : Future.wait([
                      _apiService.getAllergies().catchError((_) => []),
                      _apiService.getMedications().catchError((_) => []),
                      _apiService.getEmergencyContacts().catchError((_) => []),
                      _apiService
                          .getProfile()
                          .catchError((_) => <String, dynamic>{}),
                      _apiService.getConditions().catchError((_) => []),
                      _apiService.getSurgeries().catchError((_) => []),
                      _apiService.getDevices().catchError((_) => []),
                      _apiService
                          .getVitals(latestOnly: true)
                          .catchError((_) => []),
                    ]).then((payload) {
                      _cachedEmergencyModalPayload = payload;
                      return payload;
                    }),
              builder: (context, snapshot) {
                final allergies =
                    snapshot.data != null ? snapshot.data![0] as List : [];
                final medications =
                    snapshot.data != null ? snapshot.data![1] as List : [];
                final contacts =
                    snapshot.data != null ? snapshot.data![2] as List : [];
                final rawProfileRes = snapshot.data != null &&
                        snapshot.data!.length > 3 &&
                        snapshot.data![3] is Map
                    ? snapshot.data![3] as Map
                    : null;
                final fullProfile = rawProfileRes != null
                    ? (rawProfileRes['profile'] ??
                        rawProfileRes['data'] ??
                        rawProfileRes)
                    : null;
                final conditions =
                    snapshot.data != null && snapshot.data!.length > 4
                        ? snapshot.data![4] as List
                        : [];
                final surgeries =
                    snapshot.data != null && snapshot.data!.length > 5
                        ? snapshot.data![5] as List
                        : [];
                final devices =
                    snapshot.data != null && snapshot.data!.length > 6
                        ? snapshot.data![6] as List
                        : [];
                final vitals =
                    snapshot.data != null && snapshot.data!.length > 7
                        ? snapshot.data![7] as List
                        : [];

                final profile = (fullProfile is Map
                    ? fullProfile
                    : _dashboardData?['profile']) as Map?;
                final String name =
                    (profile?['full_name'] ?? 'User').toString().toUpperCase();
                final String bloodGroup = profile?['blood_group'] ?? 'B+';
                final String pranaId = profile?['prana_id'] ?? 'PRAN-2973CAC1';
                final String rawDob = (profile?['date_of_birth'] ??
                        profile?['dob'] ??
                        profile?['dateOfBirth'] ??
                        '')
                    .toString();
                final String dob = _formatDob(rawDob);
                final bool noKnownAllergies =
                    profile?['no_known_allergies'] == true ||
                        (allergies.isEmpty &&
                            profile?['allergies_recorded'] == true);

                return Container(
                  height: MediaQuery.of(context).size.height * 0.88,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24)),
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
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'PRANA EMERGENCY BRIEFING',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0F172A),
                                  letterSpacing: 0.2),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(10),
                              border:
                                  Border.all(color: const Color(0xFFF59E0B)),
                            ),
                            child: const Text(
                              'PARAMEDIC FULL BRIEFING',
                              style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFFB45309)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: (snapshot.connectionState ==
                                    ConnectionState.waiting &&
                                !snapshot.hasData &&
                                _cachedEmergencyModalPayload == null)
                            ? const Center(
                                child: CircularProgressIndicator(
                                    color: Color(0xFF0D9488)))
                            : ListView(
                                children: [
                                  // 1. Patient Identifier Card
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                          color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 28,
                                          backgroundColor:
                                              const Color(0xFF0D9488),
                                          child: Text(bloodGroup,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20)),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(name,
                                                  style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              Text('DOB: $dob',
                                                  style: const TextStyle(
                                                      color: Color(0xFF64748B),
                                                      fontSize: 13)),
                                              Text('PRANA ID: $pranaId',
                                                  style: const TextStyle(
                                                      fontFamily: 'monospace',
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color:
                                                          Color(0xFF0D9488))),
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
                                      color: noKnownAllergies
                                          ? const Color(0xFFF0FDF4)
                                          : const Color(0xFFFEF2F2),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                          color: noKnownAllergies
                                              ? const Color(0xFF86EFAC)
                                              : const Color(0xFFFCA5A5)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              noKnownAllergies
                                                  ? Icons
                                                      .check_circle_outline_rounded
                                                  : Icons.warning_amber_rounded,
                                              color: noKnownAllergies
                                                  ? const Color(0xFF16A34A)
                                                  : Colors.red,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              noKnownAllergies
                                                  ? 'NO KNOWN ALLERGIES'
                                                  : 'CRITICAL ALLERGIES',
                                              style: TextStyle(
                                                color: noKnownAllergies
                                                    ? const Color(0xFF16A34A)
                                                    : Colors.red,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                                letterSpacing: 1,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        if (noKnownAllergies)
                                          const Text(
                                              '✅ Patient has recorded No Known Drug or Food Allergies.',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF14532D)))
                                        else if (allergies.isEmpty)
                                          const Text(
                                              'No allergy records filed.',
                                              style: TextStyle(
                                                  color: Color(0xFF64748B)))
                                        else
                                          ...allergies.where((a) {
                                            final rawName = (a['allergen'] ??
                                                    a['name'] ??
                                                    '')
                                                .toString()
                                                .trim();
                                            return rawName.isNotEmpty &&
                                                rawName.toLowerCase() !=
                                                    'null' &&
                                                rawName.toLowerCase() !=
                                                    'undefined';
                                          }).map((a) {
                                            final allergen = (a['allergen'] ??
                                                    a['name'] ??
                                                    'Allergy')
                                                .toString()
                                                .toUpperCase();
                                            final severity =
                                                (a['severity'] ?? 'Severe')
                                                    .toString();
                                            final reaction =
                                                a['reaction_description'] ??
                                                    a['reaction'];
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 4),
                                              child: Text(
                                                '• $allergen ($severity${reaction != null && reaction.toString().isNotEmpty ? " - $reaction" : ""})',
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF991B1B)),
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
                                      border: Border.all(
                                          color: const Color(0xFF86EFAC)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Row(
                                          children: [
                                            Icon(Icons.medication_outlined,
                                                color: Color(0xFF16A34A),
                                                size: 20),
                                            SizedBox(width: 8),
                                            Text('ACTIVE MEDICATIONS',
                                                style: TextStyle(
                                                    color: Color(0xFF16A34A),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                    letterSpacing: 1)),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        if (medications.isEmpty)
                                          const Text(
                                              'No active medications recorded.',
                                              style: TextStyle(
                                                  color: Color(0xFF64748B)))
                                        else
                                          ...medications.map((m) {
                                            final mName =
                                                m['name'] ?? 'Medication';
                                            final dose = m['dose'] ?? '';
                                            final freq = m['frequency'] ?? '';
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 4),
                                              child: Text(
                                                '• $mName ${dose.toString().isNotEmpty ? dose : ""} ${freq.toString().isNotEmpty ? "($freq)" : ""}'
                                                    .trim(),
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF14532D)),
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
                                      border: Border.all(
                                          color: const Color(0xFFDDD6FE)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Row(
                                          children: [
                                            Icon(Icons.assignment_outlined,
                                                color: Color(0xFF7C3AED),
                                                size: 20),
                                            SizedBox(width: 8),
                                            Text('MEDICAL CONDITIONS',
                                                style: TextStyle(
                                                    color: Color(0xFF7C3AED),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                    letterSpacing: 1)),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        if (conditions.isEmpty)
                                          const Text(
                                              'No chronic conditions recorded.',
                                              style: TextStyle(
                                                  color: Color(0xFF64748B)))
                                        else
                                          ...conditions.map((c) {
                                            final cName =
                                                c['name'] ?? 'Condition';
                                            final cStatus =
                                                c['status'] ?? 'Active';
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 4),
                                              child: Text(
                                                '• $cName ($cStatus)',
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF5B21B6)),
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
                                      border: Border.all(
                                          color: const Color(0xFFFED7AA)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Row(
                                          children: [
                                            Icon(Icons.memory_outlined,
                                                color: Color(0xFFC2410C),
                                                size: 20),
                                            SizedBox(width: 8),
                                            Text(
                                                'IMPLANTED DEVICES / WEARABLES',
                                                style: TextStyle(
                                                    color: Color(0xFFC2410C),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                    letterSpacing: 1)),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        if (devices.isEmpty)
                                          const Text(
                                              'No medical devices or implants logged.',
                                              style: TextStyle(
                                                  color: Color(0xFF64748B)))
                                        else
                                          ...devices.map((d) {
                                            final devName = d['device_name'] ??
                                                d['name'] ??
                                                'Medical Device';
                                            final serial = d['serial_number'] ??
                                                d['serial'] ??
                                                '';
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 4),
                                              child: Text(
                                                '• $devName ${serial.toString().isNotEmpty ? "(SN: $serial)" : ""}'
                                                    .trim(),
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF9A3412)),
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
                                      border: Border.all(
                                          color: const Color(0xFFF5D0FE)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Row(
                                          children: [
                                            Icon(Icons.healing_outlined,
                                                color: Color(0xFFC026D3),
                                                size: 20),
                                            SizedBox(width: 8),
                                            Text('SURGERIES & PROCEDURES',
                                                style: TextStyle(
                                                    color: Color(0xFFC026D3),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                    letterSpacing: 1)),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        if (surgeries.isEmpty)
                                          const Text(
                                              'No prior surgeries or procedures recorded.',
                                              style: TextStyle(
                                                  color: Color(0xFF64748B)))
                                        else
                                          ...surgeries.map((s) {
                                            final procName =
                                                s['procedure_name'] ??
                                                    s['name'] ??
                                                    'Procedure';
                                            final hospital =
                                                s['hospital'] ?? '';
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 4),
                                              child: Text(
                                                '• $procName ${hospital.toString().isNotEmpty ? "($hospital)" : ""}'
                                                    .trim(),
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF86198F)),
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
                                      border: Border.all(
                                          color: const Color(0xFFBBF7D0)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Row(
                                          children: [
                                            Icon(Icons.favorite_outline,
                                                color: Color(0xFF15803D),
                                                size: 20),
                                            SizedBox(width: 8),
                                            Text('LAST RECORDED VITALS',
                                                style: TextStyle(
                                                    color: Color(0xFF15803D),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                    letterSpacing: 1)),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        if (vitals.isEmpty)
                                          const Text('No vital logs filed.',
                                              style: TextStyle(
                                                  color: Color(0xFF64748B)))
                                        else
                                          ...vitals.take(4).map((v) {
                                            final type =
                                                (v['vital_type'] ?? 'vital')
                                                    .toString()
                                                    .replaceAll('_', ' ')
                                                    .toUpperCase();
                                            final val = v['value'] ?? '';
                                            final unit = v['unit'] ?? '';
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 4),
                                              child: Text(
                                                '• $type: $val $unit'.trim(),
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF166534)),
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
                                      border: Border.all(
                                          color: const Color(0xFFBAE6FD)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Row(
                                          children: [
                                            Icon(Icons.phone_in_talk_outlined,
                                                color: Color(0xFF0284C7),
                                                size: 20),
                                            SizedBox(width: 8),
                                            Text('EMERGENCY RELAY CONTACT',
                                                style: TextStyle(
                                                    color: Color(0xFF0284C7),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                    letterSpacing: 1)),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        if (contacts.isEmpty)
                                          const Text(
                                              'No primary emergency contact recorded.',
                                              style: TextStyle(
                                                  color: Color(0xFF64748B)))
                                        else
                                          ...contacts.map((c) {
                                            final cName =
                                                c['name'] ?? 'Primary Contact';
                                            final cRel =
                                                c['relationship'] ?? 'Family';
                                            final cPhone = c['phone_number'] ??
                                                c['phone'] ??
                                                '';
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 4),
                                              child: Text(
                                                  '$cName ($cRel) • $cPhone',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          Color(0xFF0C4A6E))),
                                            );
                                          }),
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
      },
    );
  }

  Widget _buildEmergencySummaryCard(
      Map<String, dynamic>? data,
      String bloodGroup,
      String topAllergy,
      int medsCount,
      int conditionsCount) {
    final profile = data?['profile'];
    final healthSummary = data?['health_summary'];
    final bool noKnownAllergies = profile?['no_known_allergies'] == true ||
        (healthSummary?['allergies_count'] == 0 &&
            profile?['allergies_recorded'] == true);

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
              style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: Color(0xFFDC2626)),
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
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF166534)),
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
                style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    color: Color(0xFFC2410C)),
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
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Color(0xFF64748B)),
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
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    color: Color(0xFF94A3B8)),
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
                conditionsCount == 1
                    ? '1 Condition'
                    : '$conditionsCount Conditions',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Color(0xFF64748B)),
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
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xFF0F172A)),
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
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  if (widget.onNavigateTab != null)
                    widget.onNavigateTab!(1,
                        subTabIndex: 0, openAddModal: false);
                },
                child: const Text('Add Health Records',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
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
    if (HealthCacheManager.isDirty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && HealthCacheManager.isDirty) {
          _fetchDashboardData(force: true);
        }
      });
    }

    final profile = _dashboardData?['profile'];
    final healthSummary = _dashboardData?['health_summary'];

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
        child: RefreshIndicator(
          color: const Color(0xFF0D9488),
          onRefresh: () async {
            await _fetchDashboardData(force: true);
            _refreshContacts();
            _refreshInsurance();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
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
                              decoration: const BoxDecoration(
                                  color: Color(0xFF0D9488),
                                  shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Active',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0D9488)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Hello, ${_getUserFirstName()}',
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.5),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Profile verified & active',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: _copyPranaId,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
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
                            const Icon(Icons.copy_rounded,
                                size: 14, color: Color(0xFF64748B)),
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
                        BoxShadow(
                            color: Color(0x04000000),
                            blurRadius: 10,
                            offset: Offset(0, 2)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Emergency Profile Summary',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Color(0xFF0F172A))),
                            Text('View QR →',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0D9488))),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildEmergencySummaryCard(_dashboardData, bloodGroup,
                            topAllergy, medsCount, conditionsCount),
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
                        label: (healthSummary?['allergies_count'] ?? 0) > 0 ||
                                profile?['no_known_allergies'] == true
                            ? 'Manage Allergies'
                            : 'Add Allergy',
                        onTap: () {
                          if (widget.onNavigateTab != null)
                            widget.onNavigateTab!(1,
                                subTabIndex: 1, openAddModal: false);
                        },
                      ),
                      _buildQuickActionButton(
                        icon: Icons.medication_outlined,
                        label: medsCount > 0 ? 'Manage Meds' : 'Add Med',
                        onTap: () {
                          if (widget.onNavigateTab != null)
                            widget.onNavigateTab!(1,
                                subTabIndex: 0, openAddModal: false);
                        },
                      ),
                      _buildQuickActionButton(
                        icon: Icons.camera_alt_outlined,
                        label: 'Scan RX',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const PrescriptionScannerScreen()),
                          );
                        },
                      ),
                      _buildQuickActionButton(
                        icon: Icons.favorite_outline,
                        label: 'Log Vitals',
                        onTap: () {
                          if (widget.onNavigateTab != null)
                            widget.onNavigateTab!(1,
                                subTabIndex: 3, openAddModal: false);
                        },
                      ),
                      _buildQuickActionButton(
                        icon: Icons.assignment_outlined,
                        label: conditionsCount > 0
                            ? 'Manage Conditions'
                            : 'Add Condition',
                        onTap: () {
                          if (widget.onNavigateTab != null)
                            widget.onNavigateTab!(1,
                                subTabIndex: 2, openAddModal: false);
                        },
                      ),
                    ],
                  ),
                ), // 6. Emergency Contacts Management Section (Add, Edit, Delete - Max 3)
                FutureBuilder<List<dynamic>>(
                  future: _contactsFuture ??=
                      _apiService.getEmergencyContacts(),
                  builder: (context, snapshot) {
                    final contacts = snapshot.data ?? [];
                    final bool limitReached = contacts.length >= 3;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'EMERGENCY CONTACTS',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: limitReached
                                        ? const Color(0xFFFEF2F2)
                                        : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: limitReached
                                            ? const Color(0xFFFCA5A5)
                                            : const Color(0xFFCBD5E1)),
                                  ),
                                  child: Text(
                                    '${contacts.length}/3',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: limitReached
                                          ? const Color(0xFFDC2626)
                                          : const Color(0xFF475569),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            TextButton.icon(
                              onPressed: () {
                                if (limitReached) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Maximum limit of 3 emergency contacts reached.'),
                                      backgroundColor: Color(0xFFDC2626),
                                    ),
                                  );
                                  return;
                                }
                                _showAddOrEditContactModal(context,
                                    currentCount: contacts.length);
                              },
                              icon: Icon(Icons.add,
                                  size: 16,
                                  color: limitReached
                                      ? Colors.grey
                                      : const Color(0xFF0D9488)),
                              label: Text(
                                'Add Contact',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: limitReached
                                      ? Colors.grey
                                      : const Color(0xFF0D9488),
                                ),
                              ),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (snapshot.connectionState ==
                                ConnectionState.waiting &&
                            contacts.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border:
                                  Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Color(0xFF0D9488)),
                              ),
                            ),
                          )
                        else if (contacts.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border:
                                  Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.contact_phone_outlined,
                                    color: Color(0xFF94A3B8), size: 24),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'No emergency contacts added',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: Color(0xFF334155)),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Add up to 3 trusted contacts to notify automatically in emergencies.',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF64748B)),
                                      ),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => _showAddOrEditContactModal(
                                      context,
                                      currentCount: contacts.length),
                                  child: const Text('Add',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0D9488))),
                                ),
                              ],
                            ),
                          )
                        else
                          Column(
                            children: contacts.map((c) {
                              final String name =
                                  c['name'] ?? 'Emergency Contact';
                              final String rel = c['relationship'] ?? 'Family';
                              final String contactId =
                                  c['id']?.toString() ?? '';

                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color: const Color(0xFFE2E8F0)),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFCCFBF1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.person,
                                          color: Color(0xFF0D9488), size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: Color(0xFF0F172A)),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            rel,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF64748B)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined,
                                          color: Color(0xFF0D9488), size: 20),
                                      onPressed: () =>
                                          _showAddOrEditContactModal(context,
                                              contact: c,
                                              currentCount: contacts.length),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                          Icons.delete_outline_rounded,
                                          color: Color(0xFFEF4444),
                                          size: 20),
                                      onPressed: () {
                                        if (contactId.isNotEmpty) {
                                          _confirmDeleteDialog(
                                            title: 'Delete Emergency Contact',
                                            message:
                                                'Are you sure you want to delete "$name"?',
                                            onConfirm: () async {
                                              await _apiService
                                                  .deleteEmergencyContact(
                                                      contactId);
                                              _refreshContacts();
                                            },
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

                // 7. Health Insurance Management Section
                FutureBuilder<Map<String, dynamic>?>(
                  future: _insuranceFuture ??= _apiService.getInsurance(),
                  builder: (context, snapshot) {
                    final ins = snapshot.data;
                    final bool hasIns = ins != null &&
                        ins.isNotEmpty &&
                        (ins['provider_name'] ?? '').toString().isNotEmpty;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'HEALTH INSURANCE',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => _showAddOrEditInsuranceModal(
                                  context,
                                  existing: ins),
                              icon: Icon(
                                  hasIns ? Icons.edit_outlined : Icons.add,
                                  size: 16,
                                  color: const Color(0xFF0D9488)),
                              label: Text(
                                hasIns ? 'Edit Policy' : 'Add Insurance',
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0D9488)),
                              ),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (snapshot.connectionState ==
                                ConnectionState.waiting &&
                            ins == null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border:
                                  Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Color(0xFF0D9488)),
                              ),
                            ),
                          )
                        else if (!hasIns)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border:
                                  Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.verified_user_outlined,
                                    color: Color(0xFF94A3B8), size: 24),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'No health insurance added',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: Color(0xFF334155)),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Add your TPA policy & helpline for instant cashless claims in emergencies.',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF64748B)),
                                      ),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => _showAddOrEditInsuranceModal(
                                      context,
                                      existing: ins),
                                  child: const Text('Add',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0D9488))),
                                ),
                              ],
                            ),
                          )
                        else ...[
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF0D9488)
                                                .withValues(alpha: 0.2),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.shield,
                                              color: Color(0xFF2DD4BF),
                                              size: 20),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          ins['provider_name'] ??
                                              'Health Insurance',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0D9488)
                                            .withValues(alpha: 0.25),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                            color: const Color(0xFF2DD4BF)
                                                .withValues(alpha: 0.4)),
                                      ),
                                      child: Text(
                                        ins['coverage_type'] ?? 'Comprehensive',
                                        style: const TextStyle(
                                            color: Color(0xFF2DD4BF),
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'POLICY NUMBER',
                                            style: TextStyle(
                                                color: Colors.white54,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.8),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            ins['policy_number'] ?? 'N/A',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'monospace',
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if ((ins['group_number'] ?? '')
                                        .toString()
                                        .isNotEmpty)
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'GROUP / TPA ID',
                                              style: TextStyle(
                                                  color: Colors.white54,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 0.8),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              ins['group_number'],
                                              style: const TextStyle(
                                                  color: Colors.white70,
                                                  fontFamily: 'monospace',
                                                  fontSize: 13),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                                if ((ins['helpline_phone'] ?? '')
                                    .toString()
                                    .isNotEmpty) ...[
                                  const SizedBox(height: 14),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.headset_mic_outlined,
                                            color: Color(0xFF38BDF8), size: 16),
                                        const SizedBox(width: 8),
                                        Text(
                                          '24/7 Helpline: ${ins['helpline_phone']}',
                                          style: const TextStyle(
                                              color: Color(0xFFE2E8F0),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined,
                                          color: Colors.white70, size: 18),
                                      onPressed: () =>
                                          _showAddOrEditInsuranceModal(context,
                                              existing: ins),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                          Icons.delete_outline_rounded,
                                          color: Color(0xFFFCA5A5),
                                          size: 18),
                                      onPressed: () {
                                        _confirmDeleteDialog(
                                          title: 'Delete Insurance Policy',
                                          message:
                                              'Are you sure you want to remove your health insurance details?',
                                          onConfirm: () async {
                                            await _apiService.deleteInsurance();
                                            _refreshInsurance();
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
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
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF0F172A), size: 20),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 70,
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddOrEditContactModal(BuildContext context,
      {Map<String, dynamic>? contact, int currentCount = 0}) {
    if (contact == null && currentCount >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum limit of 3 emergency contacts reached.'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    final nameController = TextEditingController(text: contact?['name'] ?? '');
    final phoneController =
        TextEditingController(text: contact?['phone'] ?? '');

    const relationshipOptions = [
      'Spouse / Family',
      'Parent',
      'Sibling',
      'Child',
      'Doctor',
      'Friend / Other',
    ];

    String initialRel =
        contact?['relationship'] ?? contact?['rel'] ?? 'Spouse / Family';
    if (!relationshipOptions.contains(initialRel)) {
      initialRel = 'Spouse / Family';
    }
    String selectedRelationship = initialRel;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        contact == null
                            ? 'Add Emergency Contact (Max 3)'
                            : 'Edit Emergency Contact',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Contact Name',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedRelationship,
                    decoration: InputDecoration(
                      labelText: 'Relationship',
                      prefixIcon: const Icon(Icons.people_outline),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    items: relationshipOptions.map((rel) {
                      return DropdownMenuItem<String>(
                        value: rel,
                        child: Text(rel),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() {
                          selectedRelationship = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Phone Number (+91...)',
                      prefixIcon: const Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D9488),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        if (nameController.text.trim().isEmpty ||
                            phoneController.text.trim().isEmpty) return;
                        try {
                          final payload = {
                            'name': nameController.text.trim(),
                            'relationship': selectedRelationship,
                            'phone': phoneController.text.trim(),
                            'is_primary': true,
                          };
                          if (contact != null && contact['id'] != null) {
                            await _apiService.updateEmergencyContact(
                                contact['id'].toString(), payload);
                          } else {
                            await _apiService.addEmergencyContact(payload);
                          }
                          _cachedEmergencyModalPayload = null;
                          HealthCacheManager.isDirty = true;
                          if (context.mounted) {
                            Navigator.pop(ctx);
                            _refreshContacts();
                          }
                        } catch (_) {
                          if (context.mounted) Navigator.pop(ctx);
                        }
                      },
                      child: Text(
                        contact == null
                            ? 'Save Emergency Contact'
                            : 'Update Emergency Contact',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
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

  void _showAddOrEditInsuranceModal(BuildContext context,
      {Map<String, dynamic>? existing}) {
    final providerController =
        TextEditingController(text: existing?['provider_name'] ?? '');
    final policyController =
        TextEditingController(text: existing?['policy_number'] ?? '');
    final groupController =
        TextEditingController(text: existing?['group_number'] ?? '');
    final helplineController =
        TextEditingController(text: existing?['helpline_phone'] ?? '');

    const coverageOptions = [
      'Comprehensive Cashless',
      'Basic Hospitalization',
      'Corporate Group Cover',
      'Personal Family Floater',
    ];

    String selectedCoverage =
        existing?['coverage_type'] ?? 'Comprehensive Cashless';
    if (!coverageOptions.contains(selectedCoverage)) {
      selectedCoverage = 'Comprehensive Cashless';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        existing == null
                            ? 'Add Health Insurance'
                            : 'Edit Health Insurance',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: providerController,
                    decoration: InputDecoration(
                      labelText:
                          'Insurance Provider (e.g. Star Health, HDFC ERGO)',
                      prefixIcon: const Icon(Icons.shield_outlined),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: policyController,
                    decoration: InputDecoration(
                      labelText: 'Policy Number',
                      prefixIcon: const Icon(Icons.badge_outlined),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: groupController,
                    decoration: InputDecoration(
                      labelText: 'Group / TPA ID (Optional)',
                      prefixIcon: const Icon(Icons.groups_outlined),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: helplineController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: '24/7 TPA Helpline Phone Number',
                      prefixIcon: const Icon(Icons.phone_in_talk_outlined),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCoverage,
                    decoration: InputDecoration(
                      labelText: 'Coverage Type',
                      prefixIcon: const Icon(Icons.verified_outlined),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    items: coverageOptions.map((cov) {
                      return DropdownMenuItem<String>(
                        value: cov,
                        child: Text(cov),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() {
                          selectedCoverage = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D9488),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        if (providerController.text.trim().isEmpty ||
                            policyController.text.trim().isEmpty) return;
                        try {
                          final payload = {
                            'provider_name': providerController.text.trim(),
                            'policy_number': policyController.text.trim(),
                            'group_number': groupController.text.trim(),
                            'helpline_phone': helplineController.text.trim(),
                            'coverage_type': selectedCoverage,
                          };
                          await _apiService.saveInsurance(payload);
                          if (context.mounted) {
                            Navigator.pop(ctx);
                            _refreshInsurance();
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(e
                                      .toString()
                                      .replaceAll('Exception:', ''))),
                            );
                          }
                        }
                      },
                      child: Text(
                        existing == null
                            ? 'Save Health Insurance'
                            : 'Update Health Insurance',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
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
}
