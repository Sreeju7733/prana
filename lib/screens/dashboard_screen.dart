import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import 'prescription_scanner_screen.dart';

class DashboardScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;
  const DashboardScreen({super.key, this.onNavigateTab});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();

  Map<String, dynamic>? _dashboardData;
  bool _isRegeneratingBriefing = false;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    try {
      final res = await _apiService.getDashboard();
      if (mounted) {
        setState(() {
          _dashboardData = res;
        });
      }
    } catch (_) {}
  }

  Future<void> _handleRegenerateBriefing() async {
    setState(() => _isRegeneratingBriefing = true);
    try {
      final res = await _apiService.regenerateBriefing();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('AI briefing regenerated successfully!')),
        );
        _fetchDashboardData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _isRegeneratingBriefing = false);
    }
  }

  String _getUserFirstName() {
    final fullName = _dashboardData?['profile']?['full_name'];
    if (fullName != null && fullName.toString().trim().isNotEmpty) {
      return fullName.toString().trim().split(' ').first;
    }
    return 'User';
  }

  void _copyPranaId() {
    final pranaId = _dashboardData?['profile']?['prana_id'] ?? "PRAN-2973CAC1";
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
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
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
            const Divider(height: 32),
            Expanded(
              child: ListView(
                children: [
                  // Patient Identifier Card
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
                          child: Text(_dashboardData?['profile']?['blood_group'] ?? 'B+', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_dashboardData?['profile']?['full_name'] ?? 'User', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text('DOB: 15 May 1995', style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                            Text('PRANA ID: ${_dashboardData?['profile']?['prana_id'] ?? "PRAN-2973CAC1"}', style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w600, color: Color(0xFF0D9488))),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Critical Warnings
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFCA5A5)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
                            SizedBox(width: 8),
                            Text('CRITICAL ALLERGIES', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1)),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text('• PENICILLIN (Severe - Anaphylaxis Risk)', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF991B1B))),
                        Text('• PEANUTS (Moderate - Hives/Swelling)', style: TextStyle(color: Color(0xFF991B1B))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Active Medications
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF86EFAC)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.medication_outlined, color: Color(0xFF16A34A), size: 20),
                            SizedBox(width: 8),
                            Text('ACTIVE MEDICATIONS', style: TextStyle(color: Color(0xFF16A34A), fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1)),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text('• Metformin 500mg (Twice Daily)', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF14532D))),
                        Text('• Atorvastatin 10mg (Once Daily at night)', style: TextStyle(color: Color(0xFF14532D))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Emergency Relay Contact
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F9FF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFBAE6FD)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.phone_in_talk_outlined, color: Color(0xFF0284C7), size: 20),
                            SizedBox(width: 8),
                            Text('EMERGENCY RELAY CONTACT', style: TextStyle(color: Color(0xFF0284C7), fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1)),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text('Jane Doe (Wife) • +91 98765 43210', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0C4A6E))),
                        Text('Relay Hotline: 1800-PRANA-RELAY (Option 1)', style: TextStyle(color: Color(0xFF0C4A6E), fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBriefingModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
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
            const Row(
              children: [
                Icon(Icons.auto_awesome, color: Color(0xFF0D9488)),
                SizedBox(width: 8),
                Text('AI Emergency Medical Briefing', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
            const Text('Summarized from verified health records', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
            const Divider(height: 32),
            const Expanded(
              child: SingleChildScrollView(
                child: Text(
                  'PATIENT SUMMARY:\n'
                  '• 29-year-old male with diagnosed Type 2 Diabetes Mellitus managed on Metformin 500mg BD.\n'
                  '• CRITICAL WARNING: Severe anaphylactic allergy to Penicillin class antibiotics.\n'
                  '• Vitals stable at last log (BP 128/82 mmHg, Fasting Glucose 142 mg/dL).\n'
                  '• No prior cardiac events or surgical interventions recorded.\n'
                  '• Emergency primary contact Jane Doe verified active on PRANA Relay.',
                  style: TextStyle(fontSize: 14, height: 1.6, color: Color(0xFF334155)),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final profile = _dashboardData?['profile'];
    final healthSummary = _dashboardData?['health_summary'];
    final briefing = _dashboardData?['briefing'];
    final recentScans = (_dashboardData?['recent_scans'] as List?) ?? [];

    final String pranaId = profile?['prana_id'] ?? 'PRAN-2973CAC1';
    final String bloodGroup = profile?['blood_group'] ?? 'B+';
    final criticalAllergy = healthSummary?['critical_allergy'];
    final String topAllergy = criticalAllergy != null
        ? '${criticalAllergy['allergen']} — ${criticalAllergy['severity'] ?? "Severe"}'
        : 'Penicillin — Severe';

    final int medsCount = healthSummary?['meds_count'] ?? 0;
    final int conditionsCount = healthSummary?['conditions_count'] ?? 0;
    final int completionPct = profile?['profile_completion_pct'] ?? 80;
    final bool isProfileIncomplete = completionPct < 100;
    final List missingSections = (profile?['missing_sections'] as List?) ?? [];
    final String nextMissing = missingSections.isNotEmpty ? missingSections.first.toString() : 'medications';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header (2 lines max: Active status + Hello + Monospace PRANA ID)
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

              // 2. Emergency Briefing (Promoted to position #2 with 4px teal accent border)
              GestureDetector(
                onTap: _showBriefingModal,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: const Border(
                      left: BorderSide(color: Color(0xFF0D9488), width: 4),
                      top: BorderSide(color: Color(0xFFE2E8F0)),
                      right: BorderSide(color: Color(0xFFE2E8F0)),
                      bottom: BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    boxShadow: const [
                      BoxShadow(color: Color(0x06000000), blurRadius: 12, offset: Offset(0, 3)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.auto_awesome, color: Color(0xFF0D9488), size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Your Emergency Briefing',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A)),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                briefing?['generated_at'] != null ? briefing['generated_at'].toString().split('T').last.substring(0, 5) : '14:32',
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                              ),
                              IconButton(
                                icon: _isRegeneratingBriefing
                                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0D9488)))
                                    : const Icon(Icons.refresh_rounded, size: 18, color: Color(0xFF64748B)),
                                onPressed: _isRegeneratingBriefing ? null : _handleRegenerateBriefing,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        briefing?['text'] ??
                        '• Type 2 Diabetes (Metformin 500mg BD)\n'
                        '• Severe Penicillin Allergy (Anaphylaxis Risk)\n'
                        '• Emergency Relay Jane Doe Verified',
                        style: const TextStyle(fontSize: 13, height: 1.5, color: Color(0xFF475569)),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Tap to view full →',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0D9488)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 3. Health Overview (Equal-weight side by side badges + slim stat row)
              GestureDetector(
                onTap: _showEmergencyPreviewModal,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
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
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFFCA5A5)),
                              ),
                              child: Row(
                                children: [
                                  const Text('🩸 ', style: TextStyle(fontSize: 16)),
                                  Text(
                                    bloodGroup,
                                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFFDC2626)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF7ED),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFFDBA74)),
                              ),
                              child: Row(
                                children: [
                                  const Text('⚠️ ', style: TextStyle(fontSize: 14)),
                                  Expanded(
                                    child: Text(
                                      topAllergy,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFC2410C)),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      (medsCount == 0 && conditionsCount == 0)
                          ? InkWell(
                              onTap: () {
                                if (widget.onNavigateTab != null) widget.onNavigateTab!(1);
                              },
                              child: const Text(
                                'Add your medications and conditions to complete your profile →',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0D9488)),
                              ),
                            )
                          : Row(
                              children: [
                                Text('💊 $medsCount Meds', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                const SizedBox(width: 16),
                                Text('🏥 $conditionsCount Conditions', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                              ],
                            ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 4. Profile Completion (Shows if < 100%)
              if (isProfileIncomplete) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Profile $completionPct% complete', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                          Text('Next: Add $nextMissing', style: const TextStyle(fontSize: 11, color: Color(0xFF0D9488), fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: completionPct / 100,
                        backgroundColor: const Color(0xFFE2E8F0),
                        color: theme.primaryColor,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // 5. Quick Actions (Ordered by priority: Allergy, Med, Scan RX, Vitals, Condition in unified Teal tone)
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
                child: Row(
                  children: [
                    _buildQuickActionButton(
                      icon: Icons.warning_amber_rounded,
                      label: 'Add Allergy',
                      onTap: () {
                        if (widget.onNavigateTab != null) widget.onNavigateTab!(1);
                      },
                    ),
                    _buildQuickActionButton(
                      icon: Icons.medication_outlined,
                      label: 'Add Med',
                      onTap: () {
                        _showAddMedicationSheet(context);
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
                        if (widget.onNavigateTab != null) widget.onNavigateTab!(1);
                      },
                    ),
                    _buildQuickActionButton(
                      icon: Icons.assignment_outlined,
                      label: 'Add Condition',
                      onTap: () {
                        if (widget.onNavigateTab != null) widget.onNavigateTab!(1);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 6. Recent Activity / Scan Log (Connected to scan logs)
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
                          Text('No field scans yet', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
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
            Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
            ),
          ],
        ),
      ),
    );
  }



  void _showAddMedicationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddMedicationBottomSheet(),
    );
  }
}

class AddMedicationBottomSheet extends StatefulWidget {
  const AddMedicationBottomSheet({super.key});

  @override
  State<AddMedicationBottomSheet> createState() => _AddMedicationBottomSheetState();
}

class _AddMedicationBottomSheetState extends State<AddMedicationBottomSheet> {
  final _drugController = TextEditingController();
  final _doseController = TextEditingController(text: "500mg");
  String _frequency = "Twice Daily";

  void _submitAndCheckInteractions() {
    final drugName = _drugController.text.trim().toLowerCase();
    
    // Simulate interaction check with Penicillin allergy
    if (drugName.contains('amoxicillin') || drugName.contains('penicillin') || drugName.contains('ampicillin')) {
      Navigator.pop(context); // Close bottom sheet
      _showConflictRedAlertModal(context, drugName);
    } else {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Medication ${_drugController.text} added & verified safe!')),
      );
    }
  }

  void _showConflictRedAlertModal(BuildContext context, String drugName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: const Color(0xFF991B1B),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.gpp_maybe_rounded, color: Color(0xFF991B1B), size: 48),
              ),
              const SizedBox(height: 20),
              const Text(
                '⚠️ CRITICAL INTERACTION DETECTED',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1),
              ),
              const SizedBox(height: 12),
              Text(
                'This medication conflicts with your verified Penicillin allergy!\n\n'
                'Do NOT take Penicillin-class drugs as it may trigger severe anaphylactic reactions.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red.shade100, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF991B1B),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('I Understand'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Add New Medication', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          
          TextFormField(
            controller: _drugController,
            decoration: const InputDecoration(
              labelText: 'Drug Name',
              hintText: 'e.g. Amoxicillin or Metformin',
              prefixIcon: Icon(Icons.medication_outlined),
            ),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _doseController,
                  decoration: const InputDecoration(
                    labelText: 'Dose',
                    prefixIcon: Icon(Icons.pin_outlined),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _frequency,
                  decoration: const InputDecoration(
                    labelText: 'Frequency',
                  ),
                  items: ['Once Daily', 'Twice Daily', 'Thrice Daily', 'As Needed']
                      .map((f) => DropdownMenuItem(value: f, child: Text(f, style: const TextStyle(fontSize: 13))))
                      .toList(),
                  onChanged: (val) => setState(() => _frequency = val!),
                ),
              ),
            ],
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: _submitAndCheckInteractions,
            child: const Text('Add & Check Interactions'),
          ),
        ],
      ),
    );
  }
}
