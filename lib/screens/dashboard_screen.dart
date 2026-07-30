import 'package:flutter/material.dart';
import '../theme/colors.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome back,', style: TextStyle(color: PranaColors.textGray)),
                      Text('User', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  CircleAvatar(
                    backgroundColor: PranaColors.slateCard,
                    child: const Icon(Icons.person, color: PranaColors.pranaTeal),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [PranaColors.pranaTeal, PranaColors.emergencyCyan],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Emergency QR', style: TextStyle(color: PranaColors.midnightNavy, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('Show this to medical professionals in case of emergency.', style: TextStyle(color: PranaColors.midnightNavy, fontSize: 12)),
                    SizedBox(height: 16),
                    Center(child: Icon(Icons.qr_code_2, size: 100, color: PranaColors.midnightNavy)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text('Medical History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: 3,
                  itemBuilder: (context, index) => Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: const Icon(Icons.history, color: PranaColors.emergencyCyan),
                      title: Text('Record #${index + 1}'),
                      subtitle: const Text('Last updated 2 days ago'),
                      trailing: const Icon(Icons.chevron_right),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: PranaColors.midnightNavy,
        selectedItemColor: PranaColors.pranaTeal,
        unselectedItemColor: PranaColors.textGray,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.medical_information), label: 'Records'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
