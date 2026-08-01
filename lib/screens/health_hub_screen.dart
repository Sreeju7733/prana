import 'package:flutter/material.dart';
import '../services/api_service.dart';

class HealthHubScreen extends StatefulWidget {
  const HealthHubScreen({super.key});

  @override
  State<HealthHubScreen> createState() => _HealthHubScreenState();
}

class _HealthHubScreenState extends State<HealthHubScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  List<dynamic> _medications = [];
  List<dynamic> _allergies = [];
  List<dynamic> _conditions = [];
  List<dynamic> _vitals = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadHubData();
  }

  Future<void> _loadHubData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _apiService.getMedications().catchError((_) => []),
        _apiService.getAllergies().catchError((_) => []),
        _apiService.getConditions().catchError((_) => []),
        _apiService.getVitals().catchError((_) => []),
      ]);

      if (mounted) {
        setState(() {
          _medications = results[0];
          _allergies = results[1];
          _conditions = results[2];
          _vitals = results[3];
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: theme.primaryColor))
          : Column(
              children: [
                const SizedBox(height: 16),
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
    if (_medications.isEmpty) {
      return _buildEmptyView('No active medications logged.');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _medications.length,
      itemBuilder: (context, index) {
        final med = _medications[index];
        final name = med['name'] ?? 'Medication';
        final dose = med['dose'] ?? '';
        final freq = med['frequency'] ?? '';
        final prescribedBy = med['prescribed_by'] ?? '';

        return Card(
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
            title: Text('$name $dose'.trim(), style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('$freq ${prescribedBy.isNotEmpty ? "• $prescribedBy" : ""}'.trim()),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('Active', style: TextStyle(color: Color(0xFF15803D), fontWeight: FontWeight.bold, fontSize: 11)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAllergiesTab() {
    if (_allergies.isEmpty) {
      return _buildEmptyView('No allergies recorded.');
    }

    final critical = _allergies.where((a) => a['is_critical'] == true || a['severity'] == 'severe').toList();
    final nonCritical = _allergies.where((a) => !(a['is_critical'] == true || a['severity'] == 'severe')).toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (critical.isNotEmpty) ...[
          const Text('CRITICAL ALLERGIES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red, letterSpacing: 1)),
          const SizedBox(height: 8),
          ...critical.map((item) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: const BoxDecoration(border: Border(left: BorderSide(color: Colors.red, width: 4))),
                child: Card(
                  child: ListTile(
                    title: Text('${item['allergen'] ?? 'Allergy'} — SEVERE', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF991B1B))),
                    subtitle: Text(item['reaction_description'] ?? 'Anaphylaxis Risk'),
                    trailing: const Chip(label: Text('Critical', style: TextStyle(color: Colors.white, fontSize: 11)), backgroundColor: Colors.red),
                  ),
                ),
              )),
          const SizedBox(height: 16),
        ],
        if (nonCritical.isNotEmpty) ...[
          const Text('OTHER ALLERGIES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amber, letterSpacing: 1)),
          const SizedBox(height: 8),
          ...nonCritical.map((item) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: const BoxDecoration(border: Border(left: BorderSide(color: Colors.amber, width: 4))),
                child: Card(
                  child: ListTile(
                    title: Text(item['allergen'] ?? 'Allergy', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(item['reaction_description'] ?? 'Mild reaction'),
                    trailing: const Chip(label: Text('Moderate'), backgroundColor: Color(0xFFFEF08A)),
                  ),
                ),
              )),
        ],
      ],
    );
  }

  Widget _buildConditionsTab() {
    if (_conditions.isEmpty) {
      return _buildEmptyView('No medical conditions recorded.');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _conditions.length,
      itemBuilder: (context, index) {
        final cond = _conditions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: const Icon(Icons.calendar_today_outlined, color: Color(0xFF8B5CF6), size: 32),
            title: Text(cond['name'] ?? 'Condition', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${cond['status'] ?? 'Diagnosed'} ${cond['treating_doctor'] != null ? "• ${cond['treating_doctor']}" : ""}'.trim()),
          ),
        );
      },
    );
  }

  Widget _buildVitalsTab() {
    if (_vitals.isEmpty) {
      return _buildEmptyView('No vitals logged yet.');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _vitals.length,
      itemBuilder: (context, index) {
        final v = _vitals[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: const Icon(Icons.favorite, color: Colors.pink),
            title: Text('${v['vital_type']?.toString().toUpperCase() ?? 'VITAL'}: ${v['value']} ${v['unit'] ?? ''}'),
            subtitle: Text('Recorded ${v['created_at'] != null ? v['created_at'].toString().split('T').first : "recently"}'),
          ),
        );
      },
    );
  }

  Widget _buildEmptyView(String text) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.folder_open_rounded, size: 48, color: Color(0xFF94A3B8)),
          const SizedBox(height: 12),
          Text(text, style: const TextStyle(color: Color(0xFF64748B), fontSize: 14)),
        ],
      ),
    );
  }
}
