import 'package:flutter/material.dart';

class MyCardScreen extends StatefulWidget {
  const MyCardScreen({super.key});

  @override
  State<MyCardScreen> createState() => _MyCardScreenState();
}

class _MyCardScreenState extends State<MyCardScreen> {
  bool _cardActive = true;

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
            // Digital Card Preview
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
                  const SizedBox(height: 20),
                  // Centered QR Code
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => Dialog(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.qr_code_2, size: 220),
                                const SizedBox(height: 12),
                                const Text('PRAN-7843-2910', style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 18)),
                                const SizedBox(height: 16),
                                ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
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
                      child: const Icon(Icons.qr_code_2, size: 140, color: Color(0xFF0F172A)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Tap to enlarge', style: TextStyle(color: Colors.white54, fontSize: 11)),
                  const SizedBox(height: 16),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('John Doe', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('Last updated: Today 14:32', style: TextStyle(color: Colors.white54, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Card Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Generating WhatsApp card PDF...')));
                    },
                    icon: const Icon(Icons.share_outlined, size: 18),
                    label: const Text('Share Card', style: TextStyle(fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      _showOrderCardModal(context);
                    },
                    icon: const Icon(Icons.credit_card_outlined, size: 18),
                    label: const Text('Order Card (₹20)', style: TextStyle(fontSize: 13)),
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
                    subtitle: Text(_cardActive ? 'Active & Scannable' : 'Suspended', style: TextStyle(fontSize: 12, color: _cardActive ? Colors.green : Colors.red)),
                    value: _cardActive,
                    activeColor: theme.primaryColor,
                    onChanged: (val) => setState(() => _cardActive = val),
                  ),
                  const Divider(height: 1),
                  const ListTile(
                    leading: Icon(Icons.speed_outlined, color: Color(0xFF0284C7)),
                    title: Text('Daily Scan Quota'),
                    subtitle: Text('2/10 scans used today'),
                  ),
                  const Divider(height: 1),
                  const ListTile(
                    leading: Icon(Icons.location_on_outlined, color: Color(0xFF8B5CF6)),
                    title: Text('Geo-Restrictions'),
                    subtitle: Text('India Only (Tap to change)'),
                    trailing: Icon(Icons.chevron_right),
                  ),
                  const Divider(height: 1),
                  const ListTile(
                    leading: Icon(Icons.access_time_outlined, color: Color(0xFFEC4899)),
                    title: Text('Active Hours'),
                    subtitle: Text('24/7 Enabled'),
                    trailing: Icon(Icons.chevron_right),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.report_problem_outlined, color: Colors.red),
                    title: const Text('Report Lost / Stolen', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Requires biometric verification'),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please authenticate biometrics to report lost card.')));
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Scan History
            Text(
              'SCAN HISTORY',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(backgroundColor: Color(0xFFDCFCE7), child: Icon(Icons.medical_services, color: Color(0xFF16A34A), size: 18)),
                    title: Text('AIIMS Emergency (Paramedic)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: Text('28 Jul, 18:45 • Delhi, IN'),
                    trailing: Icon(Icons.map_outlined, color: Color(0xFF0284C7)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderCardModal(BuildContext context) {
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
            const Text('Order Physical PRANA Card', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Waterproof NFC + QR physical card delivered to your doorstep for ₹20.', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
            const SizedBox(height: 20),
            TextFormField(decoration: const InputDecoration(labelText: 'Delivery Address')),
            const SizedBox(height: 12),
            TextFormField(decoration: const InputDecoration(labelText: 'Pincode')),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order placed successfully! Card will arrive in 3-5 days.')));
              },
              child: const Text('Pay ₹20 & Order'),
            ),
          ],
        ),
      ),
    );
  }
}
