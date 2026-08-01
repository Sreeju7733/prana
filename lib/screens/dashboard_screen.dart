import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'prescription_scanner_screen.dart';

class DashboardScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;
  const DashboardScreen({super.key, this.onNavigateTab});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final bool _hasCriticalAllergy = true; // Set to true to show allergy card / toggle banner

  void _copyPranaId() {
    Clipboard.setData(const ClipboardData(text: "PRAN-7843-2910"));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('PRANA ID copied to clipboard!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showCardStatusDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF10B981)),
            SizedBox(width: 8),
            Text('Card Status: Active'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Last scanned: 2 days ago by AIIMS Delhi Emergency'),
            SizedBox(height: 8),
            Text('• Security level: GREEN (Public basic view enabled)'),
            SizedBox(height: 8),
            Text('• Geo-restriction: India only'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
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
                    child: const Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Color(0xFF0D9488),
                          child: Text('B+', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                        ),
                        SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('John Doe', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text('Male • 29 yrs (DOB: 15 May 1995)', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                            Text('PRANA ID: PRAN-7843-2910', style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w600, color: Color(0xFF0D9488))),
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

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top User Greeting & Header Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Hello, John', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A), letterSpacing: -0.5)),
                          const SizedBox(width: 6),
                          const Text('👋', style: TextStyle(fontSize: 18)),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text('Your Medical Identity is Active', style: TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  Row(
                    children: [
                      // PRANA ID Badge
                      GestureDetector(
                        onTap: _copyPranaId,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: const [
                              BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.badge_outlined, size: 16, color: theme.primaryColor),
                              const SizedBox(width: 4),
                              const Text(
                                'PRAN-7843',
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.copy_rounded, size: 12, color: Color(0xFF94A3B8)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Card Status Badge
                      GestureDetector(
                        onTap: _showCardStatusDialog,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFA7F3D0)),
                          ),
                          child: const CircleAvatar(radius: 4, backgroundColor: Color(0xFF10B981)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Emergency Banner (shown if warning toggle is simulated)
              if (!_hasCriticalAllergy)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFDBA74)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Color(0xFFEA580C), size: 24),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '⚠️ Add your critical allergies for emergency safety',
                          style: TextStyle(
                            color: Color(0xFFC2410C),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Health Summary Hero Card
              GestureDetector(
                onTap: _showEmergencyPreviewModal,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0F000000),
                        blurRadius: 16,
                        offset: Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                  ),
                  child: Row(
                    children: [
                      // Left: Huge Blood Group Circle
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                          border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3), width: 2),
                        ),
                        child: const Center(
                          child: Text(
                            'B+',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFDC2626),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),

                      // Right: 3 Mini Stats
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Health Overview', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                                Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFF94A3B8)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildMiniStat('💊 2', 'Meds'),
                                _buildMiniStat('⚠️ 1', 'Allergy'),
                                _buildMiniStat('🏥 1', 'Condition'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Quick Actions Row (Horizontal Scroll)
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
                      icon: Icons.camera_alt_outlined,
                      label: 'Scan RX',
                      color: const Color(0xFF0D9488),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PrescriptionScannerScreen()),
                        );
                      },
                    ),
                    _buildQuickActionButton(
                      icon: Icons.medication_outlined,
                      label: 'Add Med',
                      color: const Color(0xFF0284C7),
                      onTap: () {
                        _showAddMedicationSheet(context);
                      },
                    ),
                    _buildQuickActionButton(
                      icon: Icons.warning_amber_rounded,
                      label: 'Add Allergy',
                      color: const Color(0xFFEF4444),
                      onTap: () {
                        if (widget.onNavigateTab != null) widget.onNavigateTab!(1);
                      },
                    ),
                    _buildQuickActionButton(
                      icon: Icons.assignment_outlined,
                      label: 'Add Condition',
                      color: const Color(0xFF8B5CF6),
                      onTap: () {
                        if (widget.onNavigateTab != null) widget.onNavigateTab!(1);
                      },
                    ),
                    _buildQuickActionButton(
                      icon: Icons.favorite_outline,
                      label: 'Log Vitals',
                      color: const Color(0xFFEC4899),
                      onTap: () {
                        if (widget.onNavigateTab != null) widget.onNavigateTab!(1);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Medical Briefing Card
              GestureDetector(
                onTap: _showBriefingModal,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: const [
                      BoxShadow(color: Color(0x05000000), blurRadius: 10, offset: Offset(0, 2)),
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
                          IconButton(
                            icon: const Icon(Icons.refresh_rounded, size: 20, color: Color(0xFF64748B)),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Regenerating AI briefing...')),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        '• Type 2 Diabetes (Metformin 500mg BD)\n'
                        '• Severe Penicillin Allergy (Anaphylaxis Risk)\n'
                        '• Emergency Relay Jane Doe Verified',
                        style: TextStyle(fontSize: 13, height: 1.5, color: Color(0xFF475569)),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Generated today at 14:32', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                          const Text('Tap to view full >', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0D9488))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Recent Activity Timeline
              Text(
                'LAST 7 DAYS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _buildTimelineItem(
                      title: 'Added Metformin 500mg',
                      subtitle: 'Yesterday • Prescription auto-scan',
                      icon: Icons.medication_outlined,
                      color: const Color(0xFF0284C7),
                      isFirst: true,
                    ),
                    _buildTimelineItem(
                      title: 'BP Logged: 128/82 mmHg',
                      subtitle: '3 days ago • Vital Tracker',
                      icon: Icons.favorite_outline,
                      color: const Color(0xFFEC4899),
                    ),
                    _buildTimelineItem(
                      title: 'Card Scanned by EMD-4521',
                      subtitle: '5 days ago • AIIMS Delhi',
                      icon: Icons.qr_code_scanner,
                      color: const Color(0xFF10B981),
                      isLast: true,
                    ),
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

  Widget _buildMiniStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.1),
                border: Border.all(color: color.withValues(alpha: 0.2)),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 32,
                color: const Color(0xFFE2E8F0),
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              const SizedBox(height: 14),
            ],
          ),
        ),
      ],
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
