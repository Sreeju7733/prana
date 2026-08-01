import 'package:flutter/material.dart';

class HealthHubScreen extends StatefulWidget {
  const HealthHubScreen({super.key});

  @override
  State<HealthHubScreen> createState() => _HealthHubScreenState();
}

class _HealthHubScreenState extends State<HealthHubScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Health Hub'),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: theme.primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: const Color(0xFF64748B),
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: const [
                Tab(text: 'Meds'),
                Tab(text: 'Allergies'),
                Tab(text: 'Conditions'),
                Tab(text: 'Vitals'),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search health records...',
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Tab Bar View
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMedicationsTab(),
                _buildAllergiesTab(),
                _buildConditionsTab(),
                _buildVitalsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationsTab() {
    final meds = [
      {'name': 'Metformin 500mg', 'sub': 'Twice daily • Since Jan 2026', 'type': 'Diabetes', 'active': true},
      {'name': 'Atorvastatin 10mg', 'sub': 'Once daily at night • Since Mar 2025', 'type': 'Cholesterol', 'active': true},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: meds.length,
      itemBuilder: (context, index) {
        final med = meds[index];
        return Dismissible(
          key: Key(med['name'].toString()),
          background: Container(
            color: Colors.amber,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20),
            child: const Row(children: [Icon(Icons.pause, color: Colors.white), Text(' Mark Inactive', style: TextStyle(color: Colors.white))]),
          ),
          secondaryBackground: Container(
            color: Colors.blue,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Row(mainAxisAlignment: MainAxisAlignment.end, children: [Text('Edit ', style: TextStyle(color: Colors.white)), Icon(Icons.edit, color: Colors.white)]),
          ),
          child: Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0284C7).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.medication_outlined, color: Color(0xFF0284C7)),
              ),
              title: Text(med['name'].toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(med['sub'].toString()),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('Active', style: TextStyle(color: Color(0xFF15803D), fontWeight: FontWeight.bold, fontSize: 11)),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAllergiesTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Critical Section
        const Text('CRITICAL ALLERGIES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red, letterSpacing: 1)),
        const SizedBox(height: 8),
        Container(
          decoration: const BoxDecoration(
            border: Border(left: BorderSide(color: Colors.red, width: 4)),
          ),
          child: const Card(
            child: ListTile(
              title: Text('Penicillin — SEVERE', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF991B1B))),
              subtitle: Text('Anaphylaxis risk • Diagnosed 2021'),
              trailing: Chip(label: Text('Critical', style: TextStyle(color: Colors.white, fontSize: 11)), backgroundColor: Colors.red),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Non Critical Section
        const Text('OTHER ALLERGIES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amber, letterSpacing: 1)),
        const SizedBox(height: 8),
        Container(
          decoration: const BoxDecoration(
            border: Border(left: BorderSide(color: Colors.amber, width: 4)),
          ),
          child: const Card(
            child: ListTile(
              title: Text('Peanuts', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Reaction: Hives and facial swelling'),
              trailing: Chip(label: Text('Moderate'), backgroundColor: Color(0xFFFEF08A)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConditionsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: const ListTile(
            contentPadding: EdgeInsets.all(16),
            leading: Icon(Icons.calendar_today_outlined, color: Color(0xFF8B5CF6), size: 32),
            title: Text('Type 2 Diabetes Mellitus', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Diagnosed 2022 • Active\nTreating Doctor: Dr. Sharma (AIIMS Delhi)'),
          ),
        ),
      ],
    );
  }

  Widget _buildVitalsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Graph placeholder card
        Container(
          height: 160,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('BP Readings (Last 30 Days)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const Spacer(),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildBar(40, '120/80'),
                    _buildBar(65, '128/82'),
                    _buildBar(50, '124/80'),
                    _buildBar(80, '130/85'),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Card(
          child: ListTile(
            leading: Icon(Icons.favorite, color: Colors.pink),
            title: Text('BP: 128/82 mmHg'),
            subtitle: Text('Logged 2 days ago'),
          ),
        ),
        const Card(
          child: ListTile(
            leading: Icon(Icons.water_drop, color: Colors.blue),
            title: Text('Glucose: 142 mg/dL'),
            subtitle: Text('Logged 1 week ago'),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add),
          label: const Text('Log New Vital'),
        ),
      ],
    );
  }

  Widget _buildBar(double height, String label) {
    return Column(
      children: [
        Container(
          width: 16,
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFF0D9488),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFF64748B))),
      ],
    );
  }
}
