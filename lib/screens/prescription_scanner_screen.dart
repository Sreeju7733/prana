import 'package:flutter/material.dart';

class PrescriptionScannerScreen extends StatefulWidget {
  const PrescriptionScannerScreen({super.key});

  @override
  State<PrescriptionScannerScreen> createState() => _PrescriptionScannerScreenState();
}

class _PrescriptionScannerScreenState extends State<PrescriptionScannerScreen> {
  int _step = 0; // 0: Camera Overlay, 1: Processing, 2: Results

  void _startScan() async {
    setState(() => _step = 1);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _step = 2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Prescription Scanner', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_step == 0) {
      return Stack(
        children: [
          // Camera View Simulation
          Container(
            color: Colors.grey.shade900,
            child: const Center(
              child: Icon(Icons.camera_alt_outlined, size: 80, color: Colors.white38),
            ),
          ),
          // Overlay Frame
          Center(
            child: Container(
              width: 280,
              height: 380,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF0D9488), width: 3),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: const Text(
              'Align prescription within frame',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: _startScan,
                  icon: const Icon(Icons.camera_rounded),
                  label: const Text('Capture Prescription'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white54)),
                  onPressed: _startScan,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Upload from Gallery'),
                ),
              ],
            ),
          ),
        ],
      );
    } else if (_step == 1) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF0D9488)),
            SizedBox(height: 24),
            Text('Extracting prescription text...', style: TextStyle(color: Colors.white, fontSize: 16)),
            SizedBox(height: 8),
            Text('Checking drug interactions...', style: TextStyle(color: Colors.white54, fontSize: 13)),
          ],
        ),
      );
    } else {
      return Container(
        color: const Color(0xFFF8FAFC),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Scan Results', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            const SizedBox(height: 16),
            
            // Extracted Text Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Extracted Prescription Data:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF64748B))),
                  SizedBox(height: 8),
                  Text('• Amoxicillin 500mg (Thrice daily for 5 days)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Interaction Check Result
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.gpp_maybe_rounded, color: Colors.red, size: 32),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('🛑 DO NOT TAKE — CONFLICT DETECTED', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13)),
                        SizedBox(height: 4),
                        Text('Amoxicillin is a Penicillin-class drug and conflicts with your severe allergy.', style: TextStyle(color: Color(0xFF991B1B), fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _step = 0),
                    child: const Text('Retake Photo'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel Add'),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }
}
