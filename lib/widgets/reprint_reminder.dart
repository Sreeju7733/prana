import 'package:flutter/material.dart';
import '../services/qr_service.dart';

/// Shows a reinstall/update banner when the local card data is out of sync
/// with what the server has. Used after sync to detect missing QR etc.
class ReprintReminderBanner extends StatefulWidget {
  final String pranaId;
  final VoidCallback onDismiss;
  final VoidCallback onReprint;

  const ReprintReminderBanner({
    super.key,
    required this.pranaId,
    required this.onDismiss,
    required this.onReprint,
  });

  @override
  State<ReprintReminderBanner> createState() => _ReprintReminderBannerState();
}

class _ReprintReminderBannerState extends State<ReprintReminderBanner> {
  bool _showReminder = false;
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _checkNeedReprint();
  }

  Future<void> _checkNeedReprint() async {
    try {
      final qrService = QrService();
      final hasQr = await qrService.getCachedQr();
      final isExpired = await qrService.isQrExpired();
      
      if (mounted) {
        setState(() {
          _showReminder = hasQr == null || isExpired;
          _checking = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking || !_showReminder) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFB74D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.print_outlined, color: Color(0xFFE65100), size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Printed card data is outdated. Reprint recommended.',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF424242)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: widget.onDismiss,
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: const Text('Dismiss', style: TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: widget.onReprint,
                icon: const Icon(Icons.refresh, size: 14),
                label: const Text('Reprint', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Computes a fingerprint hash for the printed card fields
class CardFingerprint {
  static String compute({
    required String name,
    required String bloodGroup,
    required List<String> criticalAllergies,
  }) {
    final parts = [
      name.trim().toLowerCase(),
      bloodGroup.trim().toUpperCase(),
      ...criticalAllergies.map((a) => a.trim().toLowerCase()),
    ].join('|');
    
    // Simple hash - in production use SHA-256
    int hash = 0;
    for (int i = 0; i < parts.length; i++) {
      hash = ((hash * 31) + parts.codeUnitAt(i)) & 0x7FFFFFFF;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }
}
