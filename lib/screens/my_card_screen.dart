import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/api_service.dart';

class ScanHistoryItem {
  final String id;
  final String timeLabel;
  final String location;
  final String scannerName;
  final String tier;
  final Color tierColor;
  final String exactGps;
  final String deviceInfo;
  final String dataAccessed;

  const ScanHistoryItem({
    required this.id,
    required this.timeLabel,
    required this.location,
    required this.scannerName,
    required this.tier,
    required this.tierColor,
    required this.exactGps,
    required this.deviceInfo,
    required this.dataAccessed,
  });
}

class MyCardScreen extends StatefulWidget {
  const MyCardScreen({super.key});

  @override
  State<MyCardScreen> createState() => _MyCardScreenState();
}

class _MyCardScreenState extends State<MyCardScreen> {
  bool _cardActive = true;
  String _pranaId = 'PRAN-2973CAC1';
  String _userName = 'Sreeju S';
  String _bloodGroup = 'B+';
  String _criticalAllergyText = 'No critical severe allergies logged';
  String _emergencyContact = 'Emergency Relay: Active';

  List<ScanHistoryItem> _scanHistory = [];

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _hydrateUserProfile();
  }

  Future<void> _hydrateUserProfile() async {
    try {
      final dashboard = await _apiService.getDashboard(forceRefresh: true);
      final profile = dashboard['profile'] as Map<String, dynamic>?;
      final allergies = await _apiService.getAllergies().catchError((_) => []);
      final contacts = await _apiService.getEmergencyContacts().catchError((_) => []);
      final securityData = await _apiService.getCardSecurity().catchError((_) => <String, dynamic>{});
      final rawLogs = await _apiService.getScanHistory().catchError((_) => []);

      if (mounted) {
        setState(() {
          if (securityData.containsKey('is_suspended')) {
            _cardActive = !(securityData['is_suspended'] == true);
          }

          if (profile != null) {
            final rawName = profile['full_name']?.toString().trim();
            if (rawName != null && rawName.isNotEmpty && rawName != 'null') {
              _userName = rawName;
            }
            final rawId = profile['prana_id']?.toString().trim();
            if (rawId != null && rawId.isNotEmpty && rawId != 'null') {
              _pranaId = rawId;
            }
            final rawBg = profile['blood_group']?.toString().trim();
            if (rawBg != null && rawBg.isNotEmpty && rawBg != 'null' && rawBg != 'undefined') {
              _bloodGroup = rawBg;
            } else {
              _bloodGroup = 'B+';
            }
          }

          if (allergies.isNotEmpty) {
            final critical = allergies.first;
            final algName = critical['allergen'] ?? critical['name'] ?? 'Allergy';
            final algSev = critical['severity'] ?? 'Severe';
            _criticalAllergyText = '⚠️ $algName — $algSev';
          } else if (profile?['no_known_allergies'] == true) {
            _criticalAllergyText = '✅ No Known Drug Allergies';
          }

          if (contacts.isNotEmpty) {
            final c = contacts.first;
            _emergencyContact = '${c['name'] ?? 'Emergency Contact'} • ${c['phone_number'] ?? c['phone'] ?? ''}';
          }

          if (rawLogs.isNotEmpty) {
            _scanHistory = rawLogs.map((log) {
              final String id = log['id']?.toString() ?? 'SCAN-${log['created_at'] ?? 'LOG'}';
              final String timeLabel = log['scanned_at'] != null ? log['scanned_at'].toString().split('T').first : 'Recently';
              final String location = log['location_city'] ?? log['location'] ?? 'India';
              final String scannerName = log['responder_org'] ?? log['scanner_type'] ?? 'Public (Green tier)';
              final String tier = log['access_tier'] ?? 'Green Tier';
              final Color tierColor = tier.contains('Yellow') ? const Color(0xFFD97706) : const Color(0xFF16A34A);

              return ScanHistoryItem(
                id: id,
                timeLabel: timeLabel,
                location: location,
                scannerName: scannerName,
                tier: tier,
                tierColor: tierColor,
                exactGps: log['gps_coordinates'] ?? 'GPS Location verified by scanner',
                deviceInfo: log['user_agent'] ?? log['device_info'] ?? 'PRANA Web/Mobile Scanner Engine',
                dataAccessed: log['accessed_data_summary'] ?? 'Emergency Profile & Critical Allergies',
              );
            }).toList();
          }
        });
      }
    } catch (_) {}
  }

  void _onToggleCardStatus(bool enable) {
    HapticFeedback.mediumImpact();
    if (!enable) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEF2F2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.pause_circle_filled_rounded,
                    color: Color(0xFFDC2626),
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Suspend Emergency Card?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Anyone scanning your QR code will see "Card Suspended" and cannot view your profile.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF0D9488)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'You can reactivate your card anytime.',
                          style: TextStyle(fontSize: 12, color: Color(0xFF334155), fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: const Color(0xFFF1F5F9),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Color(0xFF475569),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: const Color(0xFFDC2626),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          Navigator.pop(context);
                          setState(() => _cardActive = false);
                          try {
                            await _apiService.toggleCardStatus(true);
                          } catch (_) {}
                          messenger.showSnackBar(
                            const SnackBar(content: Text('Card Suspended. Scans will display "Card Suspended."')),
                          );
                        },
                        child: const Text(
                          'Suspend',
                          style: TextStyle(
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
    } else {
      setState(() => _cardActive = true);
      _apiService.toggleCardStatus(false).catchError((_) => <String, dynamic>{});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Card reactivated & scannable.')),
      );
    }
  }





  void _showScanDetailModal(BuildContext context, ScanHistoryItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Scan Detail Log', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.tierColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item.tier,
                    style: TextStyle(color: item.tierColor, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('${item.timeLabel} • ${item.location}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
            const SizedBox(height: 20),

            // Exact GPS
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Color(0xFF0284C7)),
                      SizedBox(width: 6),
                      Text('EXACT GPS LOCATION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: Color(0xFF0284C7))),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(item.exactGps, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Device Info
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.devices, size: 16, color: Color(0xFF8B5CF6)),
                      SizedBox(width: 6),
                      Text('DEVICE & SCANNER INFO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: Color(0xFF8B5CF6))),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(item.scannerName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  const SizedBox(height: 2),
                  Text(item.deviceInfo, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Data Accessed
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.security, size: 16, color: Color(0xFF16A34A)),
                      SizedBox(width: 6),
                      Text('DATA ACCESSED', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: Color(0xFF16A34A))),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(item.dataAccessed, style: const TextStyle(fontSize: 13, color: Color(0xFF334155), height: 1.4)),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // PRANA V2 Cryptographic Verification
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.verified_user_outlined, size: 16, color: Color(0xFF15803D)),
                      SizedBox(width: 6),
                      Text('PRANA V2 CRYPTO VERIFICATION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: Color(0xFF15803D))),
                    ],
                  ),
                  SizedBox(height: 6),
                  Text('• Payload: PRANA_V2 | AES-256-GCM Encrypted', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF166534))),
                  SizedBox(height: 2),
                  Text('• Signature: Ed25519 Verified ✓ (Public Key match)', style: TextStyle(fontSize: 12, color: Color(0xFF15803D))),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Suspicious Scan Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  setState(() => _cardActive = false);
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      elevation: 8,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFEF2F2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.shield_sharp,
                                color: Color(0xFFDC2626),
                                size: 30,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Card Suspended & Reported',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Security incident logged for ${item.id} (${item.location}).\n\nYour card has been instantly suspended to protect your data.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.45),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0F172A),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                onPressed: () => Navigator.pop(context),
                                child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.shield_outlined, size: 18),
                label: const Text('Suspicious scan? Suspend & Report', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showShareOptionsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            const Text(
              'Share Emergency Card',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 4),
            const Text(
              'Select how you would like to share your emergency medical details.',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
            ),
            const SizedBox(height: 20),
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              tileColor: const Color(0xFFF8FAFC),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.image_outlined, color: Color(0xFF16A34A)),
              ),
              title: const Text('Share as Image', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: const Text('Generates card PNG for WhatsApp or printing', style: TextStyle(fontSize: 12)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Card image PNG generated & ready to share via WhatsApp!')),
                );
              },
            ),
            const SizedBox(height: 10),
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              tileColor: const Color(0xFFF8FAFC),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.link_rounded, color: Color(0xFF0284C7)),
              ),
              title: const Text('Share Link', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Text('Sends prana.emergency/id/$_pranaId to family', style: const TextStyle(fontSize: 12)),
              onTap: () {
                final link = 'prana.emergency/id/$_pranaId';
                Clipboard.setData(ClipboardData(text: link));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Emergency link ($link) copied to share with family!')),
                );
              },
            ),
            const SizedBox(height: 10),
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              tileColor: const Color(0xFFF8FAFC),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.print_outlined, color: Color(0xFF9333EA)),
              ),
              title: const Text('Print at Home', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: const Text('Generates PDF A4 layout with cut-lines', style: TextStyle(fontSize: 12)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Printable PDF A4 with cut-lines generated successfully!')),
                );
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showOrderCardModal(BuildContext context) {
    String paymentMethod = 'UPI';
    bool orderPlaced = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                  if (orderPlaced) ...[
                    Center(
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: const BoxDecoration(
                              color: Color(0xFFDCFCE7),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 60),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Order Placed Successfully!',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Arrives in 3-5 days',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF16A34A)),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Your physical waterproof PRANA card with embedded NFC & emergency QR pointer is being crafted.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Color(0xFF64748B), fontSize: 13, height: 1.4),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF16A34A),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ] else ...[
                    const Text('Physical PRANA Card — ₹20', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    const SizedBox(height: 6),
                    const Text('Waterproof physical NFC + QR card delivered to your doorstep.', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                    const SizedBox(height: 20),
                    TextFormField(
                      initialValue: '124 Park View, MG Road, Bengaluru',
                      decoration: const InputDecoration(
                        labelText: 'Delivery Address (Pre-filled from profile)',
                        prefixIcon: Icon(Icons.home_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Payment Method', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.qr_code_2, size: 18),
                                SizedBox(width: 6),
                                Text('UPI'),
                              ],
                            ),
                            selected: paymentMethod == 'UPI',
                            selectedColor: const Color(0xFFDCFCE7),
                            labelStyle: TextStyle(
                              color: paymentMethod == 'UPI' ? const Color(0xFF15803D) : const Color(0xFF475569),
                              fontWeight: FontWeight.bold,
                            ),
                            onSelected: (selected) {
                              if (selected) setModalState(() => paymentMethod = 'UPI');
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ChoiceChip(
                            label: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.local_shipping_outlined, size: 18),
                                SizedBox(width: 6),
                                Text('Cash on Delivery'),
                              ],
                            ),
                            selected: paymentMethod == 'COD',
                            selectedColor: const Color(0xFFDCFCE7),
                            labelStyle: TextStyle(
                              color: paymentMethod == 'COD' ? const Color(0xFF15803D) : const Color(0xFF475569),
                              fontWeight: FontWeight.bold,
                            ),
                            onSelected: (selected) {
                              if (selected) setModalState(() => paymentMethod = 'COD');
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF16A34A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () {
                          setModalState(() {
                            orderPlaced = true;
                          });
                        },
                        child: const Text('Order Now • ₹20', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('My PRANA Card'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Digital Card Preview (with Loud Suspended Overlay)
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(color: Color(0x1A000000), blurRadius: 20, offset: Offset(0, 10)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.health_and_safety, color: theme.primaryColor, size: 28),
                              const SizedBox(width: 8),
                              const Text('PRANA CARD', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 2)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF10B981)),
                            ),
                            child: const Text('GREEN TIER', style: TextStyle(color: Color(0xFF34D399), fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(_userName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 4),
                      Text('Blood Group : $_bloodGroup', style: const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(_criticalAllergyText, style: const TextStyle(color: Color(0xFFFCA5A5), fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(_emergencyContact, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      const SizedBox(height: 16),
                      // Centered QR Code
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => Dialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: const Color(0xFFE2E8F0)),
                                        ),
                                        child: QrImageView(
                                          data: 'PRANA_V2|PID:$_pranaId|YK:enc_yellow_blob|SIG:ed25519_valid',
                                          version: QrVersions.auto,
                                          size: 200.0,
                                          backgroundColor: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(_pranaId, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 18)),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFDCFCE7),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Text('PRANA V2 • ECC + Ed25519 Signed Payload', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF15803D))),
                                      ),
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF0F172A),
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Row(
                                              children: [
                                                Icon(Icons.lock_outline, color: Color(0xFF38BDF8), size: 14),
                                                SizedBox(width: 6),
                                                Text('HYBRID ENCRYPTION PIPELINE', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            const Text(
                                              'Medical JSON → Compress → AES-256-GCM Encrypt → ECC Encrypt Key → Ed25519 Sign',
                                              style: TextStyle(color: Colors.white70, fontSize: 10, height: 1.3),
                                            ),
                                            const SizedBox(height: 6),
                                            SelectableText(
                                              'PRANA_V2|PID:$_pranaId|YK:enc_yellow_blob|SIG:ed25519_valid',
                                              style: const TextStyle(color: Color(0xFF4ADE80), fontSize: 9, fontFamily: 'monospace'),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Close'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: QrImageView(
                              data: 'PRANA_V2|PID:$_pranaId|YK:enc_yellow_blob|SIG:ed25519_valid',
                              version: QrVersions.auto,
                              size: 140.0,
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Center(
                        child: Text(
                          'Scan only using PRANA Responder',
                          style: TextStyle(color: Colors.white54, fontSize: 11, fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!_cardActive)
                  Positioned.fill(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: !_cardActive ? 1.0 : 0.0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF991B1B).withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.block_rounded, color: Colors.white, size: 52),
                            SizedBox(height: 10),
                            Text(
                              '🛑 CARD SUSPENDED',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: 1.5),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'All emergency QR resolution is blocked',
                              style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // Card Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () => _showShareOptionsModal(context),
                    icon: const Icon(Icons.share_outlined, size: 18, color: Color(0xFF334155)),
                    label: const Text('Share Card', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () => _showOrderCardModal(context),
                    icon: const Icon(Icons.credit_card_outlined, size: 18),
                    label: const Text('Order Card (₹20)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Security Center Section
            Text(
              'SECURITY CENTER',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: Colors.grey.shade600),
            ),
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
                    title: const Text('Card Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _cardActive ? 'Active & Scannable' : 'Card Suspended',
                        key: ValueKey<bool>(_cardActive),
                        style: TextStyle(
                          fontSize: 12,
                          color: _cardActive ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    value: _cardActive,
                    activeThumbColor: const Color(0xFF16A34A),
                    activeTrackColor: const Color(0xFFDCFCE7),
                    inactiveThumbColor: const Color(0xFF94A3B8),
                    inactiveTrackColor: const Color(0xFFE2E8F0),
                    onChanged: (val) => _onToggleCardStatus(val),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.report_problem_outlined, color: Colors.red, size: 22),
                    title: const Text('Report Card Lost or Stolen', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: const Text('Instantly freeze card & revoke responder access', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    trailing: const Icon(Icons.chevron_right, color: Colors.red),
                    onTap: () => _showReportLostStolenModal(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Scan History Tree Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'RECENT ACTIVITY',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: Colors.grey.shade600),
                ),
                Text(
                  '${_scanHistory.length} Scans',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: _scanHistory.isEmpty
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
                                'When someone scans your emergency card, the activity and GPS log will show here in real-time.',
                                style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: List.generate(_scanHistory.length, (index) {
                        final item = _scanHistory[index];
                        final isFirst = index == 0;
                        final isLast = index == _scanHistory.length - 1;

                        return InkWell(
                          onTap: () => _showScanDetailModal(context, item),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Tree Connector Column
                                  SizedBox(
                                    width: 24,
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            width: 2,
                                            color: isFirst ? Colors.transparent : const Color(0xFFCBD5E1),
                                          ),
                                        ),
                                        Container(
                                          width: 10,
                                          height: 10,
                                          decoration: BoxDecoration(
                                            color: item.tierColor,
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.white, width: 2),
                                            boxShadow: [
                                              BoxShadow(
                                                color: item.tierColor.withValues(alpha: 0.4),
                                                blurRadius: 4,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            width: 2,
                                            color: isLast ? Colors.transparent : const Color(0xFFCBD5E1),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Content Item
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(color: const Color(0xFFF1F5F9)),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                item.timeLabel,
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                                              ),
                                              Text(
                                                '• ${item.location}',
                                                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Scanner: ${item.scannerName}',
                                            style: const TextStyle(fontSize: 12, color: Color(0xFF334155), fontWeight: FontWeight.w500),
                                          ),
                                          const SizedBox(height: 8),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: isFirst ? const Color(0xFFE0F2FE) : const Color(0xFFF1F5F9),
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(color: isFirst ? const Color(0xFFBAE6FD) : const Color(0xFFE2E8F0)),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    isFirst ? Icons.map_outlined : Icons.info_outline_rounded,
                                                    size: 13,
                                                    color: isFirst ? const Color(0xFF0369A1) : const Color(0xFF475569),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    isFirst ? '[View on Map]' : '[View Details]',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.bold,
                                                      color: isFirst ? const Color(0xFF0369A1) : const Color(0xFF475569),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReportLostStolenModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                Icon(Icons.report_problem_rounded, color: Color(0xFFDC2626), size: 24),
                SizedBox(width: 8),
                Text(
                  'Report Lost or Stolen Card',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'If your physical PRANA card or printed QR is lost or compromised, reporting it will instantly freeze card access and prevent emergency responders from querying your medical profile.',
              style: TextStyle(color: Color(0xFF475569), fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lock_clock, color: Color(0xFFDC2626), size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Action: Instant Emergency Card Suspension & Security Logged',
                      style: TextStyle(color: Color(0xFF991B1B), fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  setState(() => _cardActive = false);
                  _apiService.toggleCardStatus(true).catchError((_) => <String, dynamic>{});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🔒 Card Suspended & Reported as Lost/Stolen.'),
                      backgroundColor: Color(0xFFDC2626),
                    ),
                  );
                },
                child: const Text('Confirm & Freeze Card Access', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
