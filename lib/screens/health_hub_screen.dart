import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'prescription_scanner_screen.dart';

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
        title: const Text(
          'Health Hub',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22, color: Color(0xFF0F172A), letterSpacing: -0.5),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.document_scanner_outlined, color: Color(0xFF0D9488)),
            tooltip: 'Scan RX',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PrescriptionScannerScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            height: 44,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(14),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: const Color(0xFF0D9488),
                borderRadius: BorderRadius.circular(11),
                boxShadow: const [
                  BoxShadow(color: Color(0x1F0D9488), blurRadius: 6, offset: Offset(0, 2)),
                ],
              ),
              labelColor: Colors.white,
              unselectedLabelColor: const Color(0xFF475569),
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
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
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search health records...',
                      prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      fillColor: Colors.white,
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFF0D9488), width: 1.5),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: FloatingActionButton.extended(
          onPressed: _showAddItemModal,
          backgroundColor: const Color(0xFF0D9488),
          elevation: 4,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: const Text('Add Record', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        ),
      ),
    );
  }

  void _showAddItemModal() {
    final currentTab = _tabController.index;
    if (currentTab == 0) {
      _showAddMedicationSheet();
    } else if (currentTab == 1) {
      _showAddAllergySheet();
    } else if (currentTab == 2) {
      _showAddConditionSheet();
    } else {
      _showAddVitalSheet();
    }
  }

  void _showAddMedicationSheet() {
    final nameCtrl = TextEditingController();
    final doseCtrl = TextEditingController();
    final freqCtrl = TextEditingController(text: 'Daily');
    final doctorCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20, top: 20, left: 20, right: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add Medication', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Medication Name (e.g. Metformin)')),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: TextField(controller: doseCtrl, decoration: const InputDecoration(labelText: 'Dose (e.g. 500mg)'))),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: freqCtrl, decoration: const InputDecoration(labelText: 'Frequency (e.g. BD / 2x Daily)'))),
              ],
            ),
            const SizedBox(height: 12),
            TextField(controller: doctorCtrl, decoration: const InputDecoration(labelText: 'Prescribed By (Optional Doctor Name)')),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: () async {
                  if (nameCtrl.text.trim().isNotEmpty) {
                    Navigator.pop(ctx);
                    await _apiService.addMedication({
                      'name': nameCtrl.text.trim(),
                      'dose': doseCtrl.text.trim(),
                      'frequency': freqCtrl.text.trim(),
                      'prescribed_by': doctorCtrl.text.trim(),
                      'is_active': true,
                    }).catchError((_) => <String, dynamic>{});
                    _loadHubData();
                  }
                },
                child: const Text('Save Medication'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddAllergySheet() {
    final allergenCtrl = TextEditingController();
    String severity = 'severe';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20, top: 20, left: 20, right: 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add Allergy', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(controller: allergenCtrl, decoration: const InputDecoration(labelText: 'Allergen Name (e.g. Penicillin)')),
              const SizedBox(height: 12),
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('Severe'),
                    selected: severity == 'severe',
                    selectedColor: const Color(0xFFFCA5A5),
                    onSelected: (sel) => setModalState(() => severity = 'severe'),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Moderate'),
                    selected: severity == 'moderate',
                    selectedColor: const Color(0xFFFEF08A),
                    onSelected: (sel) => setModalState(() => severity = 'moderate'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  onPressed: () async {
                    if (allergenCtrl.text.trim().isNotEmpty) {
                      Navigator.pop(ctx);
                      await _apiService.addAllergy({
                        'allergen': allergenCtrl.text.trim(),
                        'severity': severity,
                        'is_critical': severity == 'severe',
                      }).catchError((_) => <String, dynamic>{});
                      _loadHubData();
                    }
                  },
                  child: const Text('Save Allergy'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddConditionSheet() {
    final nameCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20, top: 20, left: 20, right: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add Condition', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Condition Name (e.g. Type 2 Diabetes)')),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: () async {
                  if (nameCtrl.text.trim().isNotEmpty) {
                    Navigator.pop(ctx);
                    await _apiService.addCondition({
                      'name': nameCtrl.text.trim(),
                      'status': 'chronic',
                    }).catchError((_) => <String, dynamic>{});
                    _loadHubData();
                  }
                },
                child: const Text('Save Condition'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddVitalSheet() {
    final valCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20, top: 20, left: 20, right: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Log Vital', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(controller: valCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Blood Glucose (mg/dL)')),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: () async {
                  if (valCtrl.text.trim().isNotEmpty) {
                    Navigator.pop(ctx);
                    await _apiService.logVital({
                      'vital_type': 'glucose',
                      'value': double.tryParse(valCtrl.text.trim()) ?? 100,
                      'unit': 'mg/dL',
                    }).catchError((_) => <String, dynamic>{});
                    _loadHubData();
                  }
                },
                child: const Text('Log Vital'),
              ),
            ),
          ],
        ),
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
        final id = med['id']?.toString() ?? '';
        final name = med['name'] ?? 'Medication';
        final dose = med['dose'] ?? '';
        final freq = med['frequency'] ?? 'Daily';
        final doctor = med['prescribed_by'] ?? '';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0284C7).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.medication_outlined, color: Color(0xFF0284C7)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$name ${dose.isNotEmpty ? "($dose)" : ""}'.trim(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text('Freq: $freq ${doctor.isNotEmpty ? "• Dr. $doctor" : ""}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 20),
                onPressed: () async {
                  if (id.isNotEmpty) {
                    await _apiService.deleteMedication(id).catchError((_) {});
                    _loadHubData();
                  }
                },
              ),
            ],
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
          ...critical.map((item) {
            final id = item['id']?.toString() ?? '';
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: const Border(left: BorderSide(color: Colors.red, width: 4), top: BorderSide(color: Color(0xFFE2E8F0)), right: BorderSide(color: Color(0xFFE2E8F0)), bottom: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${item['allergen'] ?? 'Allergy'} — SEVERE', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF991B1B), fontSize: 14)),
                        const SizedBox(height: 2),
                        Text(item['reaction_description'] ?? 'Anaphylaxis Risk', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 20),
                    onPressed: () async {
                      if (id.isNotEmpty) {
                        await _apiService.deleteAllergy(id).catchError((_) {});
                        _loadHubData();
                      }
                    },
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),
        ],
        if (nonCritical.isNotEmpty) ...[
          const Text('OTHER ALLERGIES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amber, letterSpacing: 1)),
          const SizedBox(height: 8),
          ...nonCritical.map((item) {
            final id = item['id']?.toString() ?? '';
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: const Border(left: BorderSide(color: Colors.amber, width: 4), top: BorderSide(color: Color(0xFFE2E8F0)), right: BorderSide(color: Color(0xFFE2E8F0)), bottom: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['allergen'] ?? 'Allergy', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 2),
                        Text(item['reaction_description'] ?? 'Mild reaction', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 20),
                    onPressed: () async {
                      if (id.isNotEmpty) {
                        await _apiService.deleteAllergy(id).catchError((_) {});
                        _loadHubData();
                      }
                    },
                  ),
                ],
              ),
            );
          }),
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
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              const Icon(Icons.assignment_outlined, color: Color(0xFF8B5CF6), size: 28),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cond['name'] ?? 'Condition', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(cond['status'] ?? 'Active', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                  ],
                ),
              ),
            ],
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
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              const Icon(Icons.favorite, color: Colors.pink, size: 24),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${v['vital_type']?.toString().toUpperCase() ?? 'VITAL'}: ${v['value']} ${v['unit'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text('Recorded ${v['created_at'] != null ? v['created_at'].toString().split('T').first : "recently"}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                  ],
                ),
              ),
            ],
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
