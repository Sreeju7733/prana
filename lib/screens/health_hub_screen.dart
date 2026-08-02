import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'prescription_scanner_screen.dart';

class HealthHubScreen extends StatefulWidget {
  final int initialSubTabIndex;
  final bool autoOpenAdd;
  const HealthHubScreen({
    super.key,
    this.initialSubTabIndex = 0,
    this.autoOpenAdd = false,
  });

  @override
  State<HealthHubScreen> createState() => _HealthHubScreenState();
}

class _HealthHubScreenState extends State<HealthHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService();

  // Static in-memory caches preserved across tab switches
  static List<dynamic>? _cachedMedications;
  static List<dynamic>? _cachedAllergies;
  static List<dynamic>? _cachedConditions;
  static List<dynamic>? _cachedSurgeries;
  static List<dynamic>? _cachedDevices;
  static List<dynamic>? _cachedVitals;

  bool _isLoading = true;
  List<dynamic> _medications = [];
  List<dynamic> _allergies = [];
  List<dynamic> _conditions = [];
  List<dynamic> _surgeries = [];
  List<dynamic> _devices = [];
  List<dynamic> _vitals = [];

  // Active subview when opening from More menu
  String? _activeMoreSubView; // 'surgeries', 'devices', 'vitals' or null

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialSubTabIndex.clamp(0, 3),
    );
    if (widget.initialSubTabIndex == 3) {
      _activeMoreSubView = 'vitals';
    }

    // Instant cache read - zero loading spinner on Health Hub visits
    if (_cachedMedications != null) {
      _medications = _cachedMedications!;
      _allergies = _cachedAllergies ?? [];
      _conditions = _cachedConditions ?? [];
      _surgeries = _cachedSurgeries ?? [];
      _devices = _cachedDevices ?? [];
      _vitals = _cachedVitals ?? [];
      _isLoading = false;
    }

    _loadHubData();

    if (widget.autoOpenAdd) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showAddItemModal();
      });
    }
  }

  Future<void> _loadHubData({bool forceSpinner = false}) async {
    // ZERO API CALLS when cache is clean
    if (!forceSpinner && !HealthCacheManager.isDirty && _cachedMedications != null) {
      if (_isLoading && mounted) {
        setState(() => _isLoading = false);
      }
      return;
    }
    if (_cachedMedications == null || forceSpinner) {
      setState(() => _isLoading = true);
    }
    try {
      final results = await Future.wait([
        _apiService.getMedications().catchError((_) => []),
        _apiService.getAllergies().catchError((_) => []),
        _apiService.getConditions().catchError((_) => []),
        _apiService.getSurgeries().catchError((_) => []),
        _apiService.getDevices().catchError((_) => []),
        _apiService.getVitals().catchError((_) => []),
      ]);

      if (mounted) {
        final newJson = jsonEncode(results);
        final oldJson = jsonEncode([
          _cachedMedications,
          _cachedAllergies,
          _cachedConditions,
          _cachedSurgeries,
          _cachedDevices,
          _cachedVitals,
        ]);

        // Update state and cache ONLY if data changed or initial cache load
        if (_cachedMedications == null || forceSpinner || newJson != oldJson) {
          _cachedMedications = results[0];
          _cachedAllergies = results[1];
          _cachedConditions = results[2];
          _cachedSurgeries = results[3];
          _cachedDevices = results[4];
          _cachedVitals = results[5];

          setState(() {
            _medications = results[0];
            _allergies = results[1];
            _conditions = results[2];
            _surgeries = results[3];
            _devices = results[4];
            _vitals = results[5];
            _isLoading = false;
          });
        } else if (_isLoading) {
          setState(() => _isLoading = false);
        }
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmDeleteDialog({
    required String title,
    required String message,
    required Future<void> Function() onConfirm,
  }) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Text(message,
            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await onConfirm();
      _loadHubData();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_activeMoreSubView != null) {
      String subTitle = 'Surgeries & Procedures';
      Widget subBody = _buildSurgeriesTab();
      VoidCallback onAdd = _showAddSurgerySheet;
      String addLabel = 'Add Surgery';

      if (_activeMoreSubView == 'devices') {
        subTitle = 'Implanted Devices';
        subBody = _buildDevicesTab();
        onAdd = _showAddDeviceSheet;
        addLabel = 'Add Device';
      } else if (_activeMoreSubView == 'vitals') {
        subTitle = 'Vitals Log';
        subBody = _buildVitalsTab();
        onAdd = _showAddVitalSheet;
        addLabel = 'Log Vital';
      }

      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            setState(() => _activeMoreSubView = null);
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            title: Text(
              subTitle,
              style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
              onPressed: () => setState(() => _activeMoreSubView = null),
            ),
            backgroundColor: Colors.white,
            elevation: 0.5,
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF0D9488)))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Search $subTitle...',
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
                    Expanded(child: subBody),
                  ],
                ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: FloatingActionButton.extended(
              onPressed: onAdd,
              backgroundColor: const Color(0xFF0D9488),
              elevation: 4,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: Text(addLabel, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Health Hub',
          style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 22,
              color: Color(0xFF0F172A),
              letterSpacing: -0.5),
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
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            height: 44,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(14),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: false,
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
                Tab(text: 'More'),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0D9488)))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
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
                const SizedBox(height: 8),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildMedicationsTab(),
                      _buildAllergiesTab(),
                      _buildConditionsTab(),
                      _buildMoreTabContent(),
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

  void _showAddMedicationSheet() {
    final nameCtrl = TextEditingController();
    final doseValCtrl = TextEditingController();
    final reasonCtrl = TextEditingController();
    String selectedUnit = 'mg';
    String selectedFrequency = 'Twice daily';
    bool isSubmitting = false;

    final suggestedMeds = [
      'Metformin',
      'Paracetamol',
      'Amlodipine',
      'Losartan',
      'Atorvastatin',
      'Insulin',
    ];

    final commonMeds = [
      'Metformin',
      'Paracetamol',
      'Amlodipine',
      'Losartan',
      'Atorvastatin',
      'Insulin',
      'Omeprazole',
      'Levothyroxine',
      'Aspirin',
      'Amoxicillin',
      'Metoprolol',
      'Albuterol',
      'Gabapentin',
      'Hydrochlorothiazide',
      'Lisinopril',
    ];

    final units = [
      'mg',
      'mcg',
      'g',
      'mL',
      'IU',
      'Tablet(s)',
      'Puff(s)',
      'Sachet(s)'
    ];
    final frequencies = [
      'Once daily',
      'Twice daily',
      'Three times daily',
      'Every 8 hours',
      'As needed'
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.88,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Padding(
              padding:
                  EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Add Active Medication',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Add medicines you currently take to guide emergency responders.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 16),

                    // Quick Add Chips from Onboarding
                    const Text('Common quick-add chips',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF64748B))),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: suggestedMeds.map((med) {
                        final isSelected =
                            nameCtrl.text.toLowerCase() == med.toLowerCase();
                        return ActionChip(
                          avatar: Text('+',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF0D9488))),
                          label: Text(med,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF334155))),
                          backgroundColor: isSelected
                              ? const Color(0xFF0D9488)
                              : const Color(0xFFF1F5F9),
                          onPressed: () {
                            setModalState(() {
                              nameCtrl.text = isSelected ? '' : med;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    // Medication Name Input
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Medication Name *',
                        hintText: '🔍 Search medicines... (e.g. Metformin)',
                        prefixIcon: Icon(Icons.medication_outlined,
                            color: Color(0xFF0D9488)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onChanged: (_) => setModalState(() {}),
                    ),

                    // Live Autocomplete Suggestions Box
                    if (nameCtrl.text.isNotEmpty &&
                        commonMeds.any((m) =>
                            m
                                .toLowerCase()
                                .startsWith(nameCtrl.text.toLowerCase()) &&
                            m.toLowerCase() !=
                                nameCtrl.text.toLowerCase())) ...[
                      const SizedBox(height: 6),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: const [
                            BoxShadow(
                                color: Color(0x0D000000),
                                blurRadius: 8,
                                offset: Offset(0, 4)),
                          ],
                        ),
                        child: Column(
                          children: commonMeds
                              .where((m) =>
                                  m.toLowerCase().startsWith(
                                      nameCtrl.text.toLowerCase()) &&
                                  m.toLowerCase() !=
                                      nameCtrl.text.toLowerCase())
                              .take(4)
                              .map((suggestion) => ListTile(
                                    dense: true,
                                    title: Text(suggestion,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13)),
                                    onTap: () {
                                      setModalState(() {
                                        nameCtrl.text = suggestion;
                                      });
                                    },
                                  ))
                              .toList(),
                        ),
                      ),
                    ],

                    const SizedBox(height: 14),

                    // Split Dose Picker [ 500 ] [ mg ▼ ]
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: doseValCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Dose Amount',
                              hintText: 'e.g. 500',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: selectedUnit,
                            decoration:
                                const InputDecoration(labelText: 'Unit'),
                            items: units
                                .map((u) =>
                                    DropdownMenuItem(value: u, child: Text(u)))
                                .toList(),
                            onChanged: (val) =>
                                setModalState(() => selectedUnit = val ?? 'mg'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Frequency Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: selectedFrequency,
                      decoration: const InputDecoration(labelText: 'Frequency'),
                      items: frequencies
                          .map(
                              (f) => DropdownMenuItem(value: f, child: Text(f)))
                          .toList(),
                      onChanged: (val) => setModalState(
                          () => selectedFrequency = val ?? 'Twice daily'),
                    ),
                    const SizedBox(height: 12),

                    // Optional Reason / Condition
                    TextField(
                      controller: reasonCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Condition / Reason (Optional)',
                        hintText: 'e.g. Type 2 Diabetes, High Blood Pressure',
                        prefixIcon: Icon(Icons.assignment_outlined,
                            color: Color(0xFF0D9488)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                if (nameCtrl.text.trim().isNotEmpty) {
                                  setModalState(() => isSubmitting = true);
                                  try {
                                    final doseVal = doseValCtrl.text.trim();
                                    final doseCombined = doseVal.isNotEmpty
                                        ? '$doseVal $selectedUnit'
                                        : selectedUnit;
                                    await _apiService.addMedication({
                                      'name': nameCtrl.text.trim(),
                                      'dose': doseCombined,
                                      'dose_value': doseVal,
                                      'dose_unit': selectedUnit,
                                      'frequency': selectedFrequency,
                                      'reason':
                                          reasonCtrl.text.trim().isNotEmpty
                                              ? reasonCtrl.text.trim()
                                              : null,
                                      'is_active': true,
                                    });
                                    if (ctx.mounted) Navigator.pop(ctx);
                                    await _loadHubData();
                                  } catch (e) {
                                    setModalState(() => isSubmitting = false);
                                    if (ctx.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Failed to save medication: ${e.toString().replaceAll("Exception: ", "")}')),
                                      );
                                    }
                                  }
                                }
                              },
                        child: isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Text('Save Medication Record',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddAllergySheet() {
    final allergenCtrl = TextEditingController();
    String allergySeverity = 'Severe';
    String selectedReaction = '';
    bool isSubmitting = false;

    final suggestedAllergens = [
      'Penicillin',
      'Peanuts',
      'Sulfa',
      'Aspirin',
      'Latex',
      'Bee Sting',
      'Dairy',
    ];

    final commonAllergies = [
      'Penicillin',
      'Peanuts',
      'Sulfa Drugs',
      'Aspirin',
      'Latex',
      'Bee Sting',
      'Dairy / Lactose',
      'Shellfish',
      'Tree Nuts',
      'Eggs',
      'Soy',
      'Wheat / Gluten',
      'Ibuprofen',
      'Contrast Dye',
      'Codeine',
    ];

    final reactions = [
      'Anaphylaxis',
      'Hives / Swelling',
      'Difficulty Breathing',
      'Skin Rash',
      'Nausea / Vomiting',
      'Dizziness / Fainting',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.88,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Padding(
              padding:
                  EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Add Critical Allergy',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Emergency responders scan this first during life-threatening events.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 16),

                    // Quick Add Chips from Onboarding
                    const Text('Common quick-add chips',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF64748B))),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: suggestedAllergens.map((alg) {
                        final isSelected = allergenCtrl.text.toLowerCase() ==
                            alg.toLowerCase();
                        return ActionChip(
                          avatar: Text('+',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF0D9488))),
                          label: Text(alg,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF334155))),
                          backgroundColor: isSelected
                              ? const Color(0xFF0D9488)
                              : const Color(0xFFF1F5F9),
                          onPressed: () {
                            setModalState(() {
                              allergenCtrl.text = isSelected ? '' : alg;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    // Allergen Name Input
                    TextField(
                      controller: allergenCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Allergen Name *',
                        hintText: '🔍 Search allergies... (e.g. Penicillin)',
                        prefixIcon: Icon(Icons.shield_outlined,
                            color: Color(0xFF0D9488)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onChanged: (_) => setModalState(() {}),
                    ),

                    // Live Autocomplete Suggestions Box
                    if (allergenCtrl.text.isNotEmpty &&
                        commonAllergies.any((a) =>
                            a
                                .toLowerCase()
                                .startsWith(allergenCtrl.text.toLowerCase()) &&
                            a.toLowerCase() !=
                                allergenCtrl.text.toLowerCase())) ...[
                      const SizedBox(height: 6),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: const [
                            BoxShadow(
                                color: Color(0x0D000000),
                                blurRadius: 8,
                                offset: Offset(0, 4)),
                          ],
                        ),
                        child: Column(
                          children: commonAllergies
                              .where((a) =>
                                  a.toLowerCase().startsWith(
                                      allergenCtrl.text.toLowerCase()) &&
                                  a.toLowerCase() !=
                                      allergenCtrl.text.toLowerCase())
                              .take(4)
                              .map((suggestion) => ListTile(
                                    dense: true,
                                    title: Text(suggestion,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13)),
                                    onTap: () {
                                      setModalState(() {
                                        allergenCtrl.text = suggestion;
                                      });
                                    },
                                  ))
                              .toList(),
                        ),
                      ),
                    ],

                    const SizedBox(height: 14),

                    // Common Reaction Dropdown
                    DropdownButtonFormField<String>(
                      initialValue:
                          selectedReaction.isNotEmpty ? selectedReaction : null,
                      decoration: const InputDecoration(
                        labelText: 'Reaction (Optional)',
                        hintText: 'Rash, Swelling, Anaphylaxis...',
                        prefixIcon: Icon(Icons.medical_information_outlined,
                            color: Color(0xFF64748B)),
                      ),
                      items: [
                        const DropdownMenuItem(
                            value: '',
                            child: Text('None / Unspecified',
                                style: TextStyle(color: Colors.grey))),
                        ...reactions.map(
                            (r) => DropdownMenuItem(value: r, child: Text(r))),
                      ],
                      onChanged: (val) =>
                          setModalState(() => selectedReaction = val ?? ''),
                    ),
                    const SizedBox(height: 16),

                    // 3-Level Severity Selector Cards (Mild Yellow -> Moderate Orange -> Severe Red)
                    const Text('Severity Level *',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Color(0xFF334155))),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // 🟡 Mild
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setModalState(() => allergySeverity = 'Mild'),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: allergySeverity == 'Mild'
                                    ? const Color(0xFFFEF3C7)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: allergySeverity == 'Mild'
                                      ? const Color(0xFFF59E0B)
                                      : const Color(0xFFE2E8F0),
                                  width: 1.5,
                                ),
                              ),
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text('🟡',
                                          style: TextStyle(fontSize: 14)),
                                      SizedBox(width: 4),
                                      Text('Mild',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: Color(0xFF92400E))),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                      '• Rash / Itch\n• Discomfort\n• Self-resolves',
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: Color(0xFF475569),
                                          height: 1.3)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // 🟠 Moderate
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setModalState(
                                () => allergySeverity = 'Moderate'),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: allergySeverity == 'Moderate'
                                    ? const Color(0xFFFFEDD5)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: allergySeverity == 'Moderate'
                                      ? const Color(0xFFF97316)
                                      : const Color(0xFFE2E8F0),
                                  width: 1.5,
                                ),
                              ),
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text('🟠',
                                          style: TextStyle(fontSize: 14)),
                                      SizedBox(width: 4),
                                      Text('Moderate',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: Color(0xFF9A3412))),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Text('• Swelling\n• Vomiting\n• Needs Meds',
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: Color(0xFF475569),
                                          height: 1.3)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // 🔴 Severe
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setModalState(() => allergySeverity = 'Severe'),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: allergySeverity == 'Severe'
                                    ? const Color(0xFFFEE2E2)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: allergySeverity == 'Severe'
                                      ? const Color(0xFFEF4444)
                                      : const Color(0xFFE2E8F0),
                                  width: 1.5,
                                ),
                              ),
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text('🔴',
                                          style: TextStyle(fontSize: 14)),
                                      SizedBox(width: 4),
                                      Text('Severe',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: Color(0xFF991B1B))),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                      '• Breathing issue\n• Anaphylaxis\n• Emergency',
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: Color(0xFF475569),
                                          height: 1.3)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                if (allergenCtrl.text.trim().isNotEmpty) {
                                  setModalState(() => isSubmitting = true);
                                  try {
                                    final severityLower =
                                        allergySeverity.toLowerCase();
                                    await _apiService.addAllergy({
                                      'allergen': allergenCtrl.text.trim(),
                                      'severity': severityLower,
                                      'reaction_description':
                                          selectedReaction.isNotEmpty
                                              ? selectedReaction
                                              : null,
                                      'is_critical': severityLower == 'severe',
                                    });
                                    if (ctx.mounted) Navigator.pop(ctx);
                                    await _loadHubData();
                                  } catch (e) {
                                    setModalState(() => isSubmitting = false);
                                    if (ctx.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Failed to save allergy: ${e.toString().replaceAll("Exception: ", "")}')),
                                      );
                                    }
                                  }
                                }
                              },
                        child: isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Text('Save Allergy Record',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
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
      if (_activeMoreSubView == 'devices') {
        _showAddDeviceSheet();
      } else if (_activeMoreSubView == 'vitals') {
        _showAddVitalSheet();
      } else {
        _showAddSurgerySheet();
      }
    }
  }

  void _showAddConditionSheet() {
    final nameCtrl = TextEditingController();
    final doctorCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String selectedStatus = 'Active';
    bool isSubmitting = false;

    final suggestedConditions = [
      'Diabetes',
      'Hypertension',
      'Asthma',
      'Epilepsy',
      'Heart Disease',
      'Arthritis'
    ];
    final commonConditions = [
      'Type 2 Diabetes',
      'Hypertension',
      'Asthma',
      'Epilepsy',
      'Heart Disease',
      'Arthritis',
      'Migraine',
      'Depression',
      'Kidney Disease'
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          constraints:
              BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.88),
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: SafeArea(
            child: Padding(
              padding:
                  EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                        child: Container(
                            width: 36,
                            height: 4,
                            decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(2)))),
                    const SizedBox(height: 16),
                    const Text('Add Medical Condition',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A))),
                    const SizedBox(height: 16),
                    const Text('Quick-add chips',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF64748B))),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: suggestedConditions.map((c) {
                        final isSel =
                            nameCtrl.text.toLowerCase() == c.toLowerCase();
                        return ActionChip(
                          avatar: Text('+',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isSel
                                      ? Colors.white
                                      : const Color(0xFF0D9488))),
                          label: Text(c,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: isSel
                                      ? Colors.white
                                      : const Color(0xFF334155))),
                          backgroundColor: isSel
                              ? const Color(0xFF0D9488)
                              : const Color(0xFFF1F5F9),
                          onPressed: () => setModalState(
                              () => nameCtrl.text = isSel ? '' : c),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Condition Name *',
                          hintText: 'e.g. Type 2 Diabetes',
                          prefixIcon: Icon(Icons.assignment_outlined,
                              color: Color(0xFF0D9488))),
                      onChanged: (_) => setModalState(() {}),
                    ),
                    if (nameCtrl.text.isNotEmpty &&
                        commonConditions.any((c) =>
                            c
                                .toLowerCase()
                                .startsWith(nameCtrl.text.toLowerCase()) &&
                            c.toLowerCase() !=
                                nameCtrl.text.toLowerCase())) ...[
                      const SizedBox(height: 6),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0))),
                        child: Column(
                          children: commonConditions
                              .where((c) =>
                                  c.toLowerCase().startsWith(
                                      nameCtrl.text.toLowerCase()) &&
                                  c.toLowerCase() !=
                                      nameCtrl.text.toLowerCase())
                              .take(4)
                              .map((s) => ListTile(
                                  dense: true,
                                  title: Text(s,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13)),
                                  onTap: () =>
                                      setModalState(() => nameCtrl.text = s)))
                              .toList(),
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    const Text('Status *',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Color(0xFF334155))),
                    const SizedBox(height: 8),
                    Row(
                      children: ['Active', 'Chronic', 'Resolved'].map((st) {
                        final isSel = selectedStatus == st;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ChoiceChip(
                              label: Center(
                                  child: Text(st,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: isSel
                                              ? Colors.white
                                              : const Color(0xFF334155)))),
                              selected: isSel,
                              selectedColor: const Color(0xFF0D9488),
                              onSelected: (_) =>
                                  setModalState(() => selectedStatus = st),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                        controller: doctorCtrl,
                        decoration: const InputDecoration(
                            labelText:
                                'Treating Doctor / Hospital (Optional)')),
                    const SizedBox(height: 12),
                    TextField(
                        controller: notesCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Notes (Optional)')),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14))),
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                if (nameCtrl.text.trim().isNotEmpty) {
                                  setModalState(() => isSubmitting = true);
                                  try {
                                    await _apiService.addCondition({
                                      'name': nameCtrl.text.trim(),
                                      'status': selectedStatus.toLowerCase(),
                                      'treating_doctor':
                                          doctorCtrl.text.trim().isNotEmpty
                                              ? doctorCtrl.text.trim()
                                              : null,
                                      'notes': notesCtrl.text.trim().isNotEmpty
                                          ? notesCtrl.text.trim()
                                          : null,
                                    });
                                    if (ctx.mounted) Navigator.pop(ctx);
                                    await _loadHubData();
                                  } catch (e) {
                                    setModalState(() => isSubmitting = false);
                                  }
                                }
                              },
                        child: isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Text('Save Condition',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddSurgerySheet() {
    final nameCtrl = TextEditingController();
    final hospitalCtrl = TextEditingController();
    final surgeonCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    bool isSubmitting = false;

    final quickSurgeries = [
      'Appendectomy',
      'Cardiac Stent',
      'Gallbladder Removal',
      'Knee Replacement',
      'C-Section'
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          constraints:
              BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.88),
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: SafeArea(
            child: Padding(
              padding:
                  EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                        child: Container(
                            width: 36,
                            height: 4,
                            decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(2)))),
                    const SizedBox(height: 16),
                    const Text('Add Surgery / Procedure',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A))),
                    const SizedBox(height: 16),
                    const Text('Common procedures',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF64748B))),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: quickSurgeries.map((s) {
                        final isSel =
                            nameCtrl.text.toLowerCase() == s.toLowerCase();
                        return ActionChip(
                          avatar: Text('+',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isSel
                                      ? Colors.white
                                      : const Color(0xFF0D9488))),
                          label: Text(s,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: isSel
                                      ? Colors.white
                                      : const Color(0xFF334155))),
                          backgroundColor: isSel
                              ? const Color(0xFF0D9488)
                              : const Color(0xFFF1F5F9),
                          onPressed: () => setModalState(
                              () => nameCtrl.text = isSel ? '' : s),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Procedure Name *',
                            hintText: 'e.g. Appendectomy',
                            prefixIcon: Icon(Icons.local_hospital_outlined,
                                color: Color(0xFF0D9488)))),
                    const SizedBox(height: 12),
                    TextField(
                        controller: hospitalCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Hospital (Optional)')),
                    const SizedBox(height: 12),
                    TextField(
                        controller: surgeonCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Surgeon (Optional)')),
                    const SizedBox(height: 12),
                    TextField(
                        controller: notesCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Complications / Notes (Optional)',
                            hintText: 'e.g. Anesthesia sensitivity')),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14))),
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                if (nameCtrl.text.trim().isNotEmpty) {
                                  setModalState(() => isSubmitting = true);
                                  try {
                                    await _apiService.addSurgery({
                                      'procedure_name': nameCtrl.text.trim(),
                                      'hospital':
                                          hospitalCtrl.text.trim().isNotEmpty
                                              ? hospitalCtrl.text.trim()
                                              : null,
                                      'surgeon':
                                          surgeonCtrl.text.trim().isNotEmpty
                                              ? surgeonCtrl.text.trim()
                                              : null,
                                      'complications_notes':
                                          notesCtrl.text.trim().isNotEmpty
                                              ? notesCtrl.text.trim()
                                              : null,
                                    });
                                    if (ctx.mounted) Navigator.pop(ctx);
                                    await _loadHubData();
                                  } catch (e) {
                                    setModalState(() => isSubmitting = false);
                                  }
                                }
                              },
                        child: isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Text('Save Surgery Record',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddDeviceSheet() {
    final nameCtrl = TextEditingController();
    final modelCtrl = TextEditingController();
    final locationCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    bool isSubmitting = false;

    final quickDevices = [
      'Pacemaker',
      'Cardiac Stent',
      'Insulin Pump',
      'Cochlear Implant',
      'Joint Prosthesis'
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          constraints:
              BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.88),
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: SafeArea(
            child: Padding(
              padding:
                  EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                        child: Container(
                            width: 36,
                            height: 4,
                            decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(2)))),
                    const SizedBox(height: 16),
                    const Text('Add Implanted Device',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A))),
                    const SizedBox(height: 16),
                    const Text('Common implants',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF64748B))),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: quickDevices.map((d) {
                        final isSel =
                            nameCtrl.text.toLowerCase() == d.toLowerCase();
                        return ActionChip(
                          avatar: Text('+',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isSel
                                      ? Colors.white
                                      : const Color(0xFF0D9488))),
                          label: Text(d,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: isSel
                                      ? Colors.white
                                      : const Color(0xFF334155))),
                          backgroundColor: isSel
                              ? const Color(0xFF0D9488)
                              : const Color(0xFFF1F5F9),
                          onPressed: () => setModalState(
                              () => nameCtrl.text = isSel ? '' : d),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Device Name *',
                            hintText: 'e.g. Pacemaker',
                            prefixIcon: Icon(Icons.memory_outlined,
                                color: Color(0xFF0D9488)))),
                    const SizedBox(height: 12),
                    TextField(
                        controller: modelCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Model / Manufacturer (Optional)')),
                    const SizedBox(height: 12),
                    TextField(
                        controller: locationCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Location on Body (Optional)',
                            hintText: 'e.g. Chest (Left side)')),
                    const SizedBox(height: 12),
                    TextField(
                        controller: notesCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Notes (Optional)',
                            hintText: 'MRI Safety info, battery details')),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14))),
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                if (nameCtrl.text.trim().isNotEmpty) {
                                  setModalState(() => isSubmitting = true);
                                  try {
                                    await _apiService.addDevice({
                                      'device_name': nameCtrl.text.trim(),
                                      'model_manufacturer':
                                          modelCtrl.text.trim().isNotEmpty
                                              ? modelCtrl.text.trim()
                                              : null,
                                      'location_on_body':
                                          locationCtrl.text.trim().isNotEmpty
                                              ? locationCtrl.text.trim()
                                              : null,
                                      'notes': notesCtrl.text.trim().isNotEmpty
                                          ? notesCtrl.text.trim()
                                          : null,
                                    });
                                    if (ctx.mounted) Navigator.pop(ctx);
                                    await _loadHubData();
                                  } catch (e) {
                                    setModalState(() => isSubmitting = false);
                                  }
                                }
                              },
                        child: isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Text('Save Device Record',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddVitalSheet() {
    String selectedType = 'Blood Pressure';
    final sysCtrl = TextEditingController();
    final diaCtrl = TextEditingController();
    final valCtrl = TextEditingController();
    bool isSubmitting = false;

    final vitalTypes = [
      'Blood Pressure',
      'Heart Rate',
      'Temperature',
      'Blood Glucose',
      'SpO2',
      'Weight'
    ];

    String getAutoUnit(String type) {
      switch (type) {
        case 'Blood Pressure':
          return 'mmHg';
        case 'Heart Rate':
          return 'bpm';
        case 'Temperature':
          return '°F';
        case 'Blood Glucose':
          return 'mg/dL';
        case 'SpO2':
          return '%';
        case 'Weight':
          return 'kg';
        default:
          return '';
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final autoUnit = getAutoUnit(selectedType);

          return Container(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height * 0.88),
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(ctx).viewInsets.bottom),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                          child: Container(
                              width: 36,
                              height: 4,
                              decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(2)))),
                      const SizedBox(height: 16),
                      const Text('Log Vital Reading',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A))),
                      const SizedBox(height: 16),
                      const Text('Vital Type *',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Color(0xFF334155))),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: vitalTypes.map((vt) {
                          final isSel = selectedType == vt;
                          return ChoiceChip(
                            label: Text(vt,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: isSel
                                        ? Colors.white
                                        : const Color(0xFF334155))),
                            selected: isSel,
                            selectedColor: const Color(0xFF0D9488),
                            backgroundColor: const Color(0xFFF1F5F9),
                            onSelected: (_) =>
                                setModalState(() => selectedType = vt),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      if (selectedType == 'Blood Pressure') ...[
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: sysCtrl,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                    labelText: 'Systolic (Top)',
                                    hintText: '120'),
                              ),
                            ),
                            const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Text('/',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold))),
                            Expanded(
                              child: TextField(
                                controller: diaCtrl,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                    labelText: 'Diastolic (Bottom)',
                                    hintText: '80'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(autoUnit,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF64748B))),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          children: [
                            ActionChip(
                              label: const Text('Normal (120/80)', style: TextStyle(fontSize: 11)),
                              backgroundColor: const Color(0xFFF1F5F9),
                              onPressed: () {
                                sysCtrl.text = '120';
                                diaCtrl.text = '80';
                              },
                            ),
                            ActionChip(
                              label: const Text('Elevated (130/85)', style: TextStyle(fontSize: 11)),
                              backgroundColor: const Color(0xFFF1F5F9),
                              onPressed: () {
                                sysCtrl.text = '130';
                                diaCtrl.text = '85';
                              },
                            ),
                          ],
                        ),
                      ] else ...[
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: valCtrl,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                    labelText: 'Reading Value ($autoUnit)',
                                    hintText: 'e.g. 98'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(12)),
                              child: Text(autoUnit,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0D9488))),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (selectedType == 'Blood Glucose') ...[
                          Wrap(
                            spacing: 6,
                            children: [
                              ActionChip(
                                label: const Text('Fasting (95 mg/dL)', style: TextStyle(fontSize: 11)),
                                backgroundColor: const Color(0xFFCCFBF1),
                                onPressed: () => valCtrl.text = '95',
                              ),
                              ActionChip(
                                label: const Text('Post-Meal (140 mg/dL)', style: TextStyle(fontSize: 11)),
                                backgroundColor: const Color(0xFFFEF3C7),
                                onPressed: () => valCtrl.text = '140',
                              ),
                              ActionChip(
                                label: const Text('Random (110 mg/dL)', style: TextStyle(fontSize: 11)),
                                backgroundColor: const Color(0xFFF1F5F9),
                                onPressed: () => valCtrl.text = '110',
                              ),
                            ],
                          ),
                        ] else if (selectedType == 'Heart Rate') ...[
                          Wrap(
                            spacing: 6,
                            children: [
                              ActionChip(
                                label: const Text('Resting (72 bpm)', style: TextStyle(fontSize: 11)),
                                backgroundColor: const Color(0xFFF1F5F9),
                                onPressed: () => valCtrl.text = '72',
                              ),
                              ActionChip(
                                label: const Text('Active (110 bpm)', style: TextStyle(fontSize: 11)),
                                backgroundColor: const Color(0xFFF1F5F9),
                                onPressed: () => valCtrl.text = '110',
                              ),
                            ],
                          ),
                        ] else if (selectedType == 'SpO2') ...[
                          Wrap(
                            spacing: 6,
                            children: [
                              ActionChip(
                                label: const Text('Normal (98%)', style: TextStyle(fontSize: 11)),
                                backgroundColor: const Color(0xFFF1F5F9),
                                onPressed: () => valCtrl.text = '98',
                              ),
                              ActionChip(
                                label: const Text('95%', style: TextStyle(fontSize: 11)),
                                backgroundColor: const Color(0xFFF1F5F9),
                                onPressed: () => valCtrl.text = '95',
                              ),
                            ],
                          ),
                        ] else if (selectedType == 'Temperature') ...[
                          Wrap(
                            spacing: 6,
                            children: [
                              ActionChip(
                                label: const Text('Normal (98.6°F)', style: TextStyle(fontSize: 11)),
                                backgroundColor: const Color(0xFFF1F5F9),
                                onPressed: () => valCtrl.text = '98.6',
                              ),
                              ActionChip(
                                label: const Text('Fever (100.4°F)', style: TextStyle(fontSize: 11)),
                                backgroundColor: const Color(0xFFFEE2E2),
                                onPressed: () => valCtrl.text = '100.4',
                              ),
                            ],
                          ),
                        ],
                      ],
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14))),
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  if (selectedType == 'Blood Pressure') {
                                    if (sysCtrl.text.trim().isEmpty || diaCtrl.text.trim().isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Please enter both Systolic and Diastolic values')),
                                      );
                                      return;
                                    }
                                  } else {
                                    if (valCtrl.text.trim().isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Please enter a reading value')),
                                      );
                                      return;
                                    }
                                  }

                                  setModalState(() => isSubmitting = true);
                                  try {
                                    if (selectedType == 'Blood Pressure') {
                                      final sysVal = double.tryParse(sysCtrl.text.trim()) ?? 120;
                                      final diaVal = double.tryParse(diaCtrl.text.trim()) ?? 80;
                                      await _apiService.logVital({
                                        'vital_type': 'blood_pressure',
                                        'value': sysVal,
                                        'unit': '$sysVal/$diaVal mmHg',
                                        'source': 'manual',
                                      });
                                    } else {
                                      String typeKey = selectedType.toLowerCase().replaceAll(' ', '_');
                                      if (typeKey == 'blood_glucose') typeKey = 'glucose';
                                      final val = double.tryParse(valCtrl.text.trim()) ?? 0;
                                      await _apiService.logVital({
                                        'vital_type': typeKey,
                                        'value': val,
                                        'unit': autoUnit,
                                        'source': 'manual',
                                      });
                                    }
                                    if (ctx.mounted) Navigator.pop(ctx);
                                    await _loadHubData();
                                  } catch (e) {
                                    setModalState(() => isSubmitting = false);
                                    if (ctx.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Failed to log vital: ${e.toString().replaceAll("Exception: ", "")}')),
                                      );
                                    }
                                  }
                                },
                          child: isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Text('Log Vital Reading',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showEditMedicationSheet(Map<String, dynamic> med) {
    final id = med['id']?.toString() ?? '';
    final nameCtrl = TextEditingController(text: med['name'] ?? '');
    final doseCtrl = TextEditingController(text: med['dose'] ?? '');
    final reasonCtrl = TextEditingController(text: med['reason'] ?? '');
    String selectedFrequency = med['frequency'] ?? 'Twice daily';
    bool isSubmitting = false;

    final frequencies = [
      'Once daily',
      'Twice daily',
      'Three times daily',
      'Every 8 hours',
      'As needed'
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.88,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Padding(
              padding:
                  EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Edit Medication Record',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A))),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Medication Name *',
                          prefixIcon: Icon(Icons.medication_outlined,
                              color: Color(0xFF0D9488))),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: doseCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Dose (e.g. 500 mg)',
                          prefixIcon:
                              Icon(Icons.numbers, color: Color(0xFF0D9488))),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: frequencies.contains(selectedFrequency)
                          ? selectedFrequency
                          : 'Twice daily',
                      decoration: const InputDecoration(labelText: 'Frequency'),
                      items: frequencies
                          .map(
                              (f) => DropdownMenuItem(value: f, child: Text(f)))
                          .toList(),
                      onChanged: (val) => setModalState(
                          () => selectedFrequency = val ?? 'Twice daily'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: reasonCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Condition / Reason (Optional)',
                          prefixIcon: Icon(Icons.assignment_outlined,
                              color: Color(0xFF0D9488))),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14))),
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                if (nameCtrl.text.trim().isNotEmpty &&
                                    id.isNotEmpty) {
                                  setModalState(() => isSubmitting = true);
                                  try {
                                    await _apiService.updateMedication(id, {
                                      'name': nameCtrl.text.trim(),
                                      'dose': doseCtrl.text.trim(),
                                      'frequency': selectedFrequency,
                                      'reason':
                                          reasonCtrl.text.trim().isNotEmpty
                                              ? reasonCtrl.text.trim()
                                              : null,
                                    });
                                    if (ctx.mounted) Navigator.pop(ctx);
                                    await _loadHubData();
                                  } catch (e) {
                                    setModalState(() => isSubmitting = false);
                                    if (ctx.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text(
                                                  'Failed to update medication: ${e.toString().replaceAll("Exception: ", "")}')));
                                    }
                                  }
                                }
                              },
                        child: isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Text('Save Changes',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showEditAllergySheet(Map<String, dynamic> item) {
    final id = item['id']?.toString() ?? '';
    final allergenCtrl =
        TextEditingController(text: item['allergen'] ?? item['name'] ?? '');
    String allergySeverity = (item['severity'] ??
            (item['is_critical'] == true ? 'Severe' : 'Moderate'))
        .toString();
    if (allergySeverity.isEmpty) allergySeverity = 'Severe';
    allergySeverity = allergySeverity[0].toUpperCase() +
        allergySeverity.substring(1).toLowerCase();
    String selectedReaction =
        item['reaction_description'] ?? item['reaction'] ?? '';
    bool isSubmitting = false;

    final reactions = [
      'Anaphylaxis',
      'Hives / Swelling',
      'Difficulty Breathing',
      'Skin Rash',
      'Nausea / Vomiting',
      'Dizziness / Fainting'
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          constraints:
              BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.88),
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: SafeArea(
            child: Padding(
              padding:
                  EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                        child: Container(
                            width: 36,
                            height: 4,
                            decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(2)))),
                    const SizedBox(height: 16),
                    const Text('Edit Allergy Record',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A))),
                    const SizedBox(height: 16),
                    TextField(
                      controller: allergenCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Allergen Name *',
                          prefixIcon: Icon(Icons.shield_outlined,
                              color: Color(0xFF0D9488))),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: reactions.contains(selectedReaction)
                          ? selectedReaction
                          : null,
                      decoration: const InputDecoration(
                          labelText: 'Reaction (Optional)',
                          prefixIcon: Icon(Icons.medical_information_outlined,
                              color: Color(0xFF64748B))),
                      items: [
                        const DropdownMenuItem(
                            value: '',
                            child: Text('None / Unspecified',
                                style: TextStyle(color: Colors.grey))),
                        ...reactions.map(
                            (r) => DropdownMenuItem(value: r, child: Text(r))),
                      ],
                      onChanged: (val) =>
                          setModalState(() => selectedReaction = val ?? ''),
                    ),
                    const SizedBox(height: 16),
                    const Text('Severity Level *',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Color(0xFF334155))),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setModalState(() => allergySeverity = 'Mild'),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: allergySeverity == 'Mild'
                                      ? const Color(0xFFFEF3C7)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                      color: allergySeverity == 'Mild'
                                          ? const Color(0xFFF59E0B)
                                          : const Color(0xFFE2E8F0),
                                      width: 1.5)),
                              child: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(children: [
                                      Text('🟡',
                                          style: TextStyle(fontSize: 14)),
                                      SizedBox(width: 4),
                                      Text('Mild',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: Color(0xFF92400E)))
                                    ]),
                                    SizedBox(height: 4),
                                    Text('• Rash / Itch',
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: Color(0xFF475569)))
                                  ]),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setModalState(
                                () => allergySeverity = 'Moderate'),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: allergySeverity == 'Moderate'
                                      ? const Color(0xFFFFEDD5)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                      color: allergySeverity == 'Moderate'
                                          ? const Color(0xFFF97316)
                                          : const Color(0xFFE2E8F0),
                                      width: 1.5)),
                              child: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(children: [
                                      Text('🟠',
                                          style: TextStyle(fontSize: 14)),
                                      SizedBox(width: 4),
                                      Text('Moderate',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: Color(0xFF9A3412)))
                                    ]),
                                    SizedBox(height: 4),
                                    Text('• Swelling',
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: Color(0xFF475569)))
                                  ]),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setModalState(() => allergySeverity = 'Severe'),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: allergySeverity == 'Severe'
                                      ? const Color(0xFFFEE2E2)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                      color: allergySeverity == 'Severe'
                                          ? const Color(0xFFEF4444)
                                          : const Color(0xFFE2E8F0),
                                      width: 1.5)),
                              child: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(children: [
                                      Text('🔴',
                                          style: TextStyle(fontSize: 14)),
                                      SizedBox(width: 4),
                                      Text('Severe',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: Color(0xFF991B1B)))
                                    ]),
                                    SizedBox(height: 4),
                                    Text('• Breathing issue',
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: Color(0xFF475569)))
                                  ]),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14))),
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                if (allergenCtrl.text.trim().isNotEmpty &&
                                    id.isNotEmpty) {
                                  setModalState(() => isSubmitting = true);
                                  try {
                                    final severityLower =
                                        allergySeverity.toLowerCase();
                                    await _apiService.updateAllergy(id, {
                                      'allergen': allergenCtrl.text.trim(),
                                      'severity': severityLower,
                                      'reaction_description':
                                          selectedReaction.isNotEmpty
                                              ? selectedReaction
                                              : null,
                                      'is_critical': severityLower == 'severe',
                                    });
                                    if (ctx.mounted) Navigator.pop(ctx);
                                    await _loadHubData();
                                  } catch (e) {
                                    setModalState(() => isSubmitting = false);
                                    if (ctx.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text(
                                                  'Failed to update allergy: ${e.toString().replaceAll("Exception: ", "")}')));
                                    }
                                  }
                                }
                              },
                        child: isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Text('Save Changes',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showEditConditionSheet(Map<String, dynamic> cond) {
    final id = cond['id']?.toString() ?? '';
    final nameCtrl = TextEditingController(text: cond['name'] ?? '');
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              top: 20,
              left: 20,
              right: 20),
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Edit Condition',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                  controller: nameCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Condition Name')),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14)),
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (nameCtrl.text.trim().isNotEmpty &&
                              id.isNotEmpty) {
                            setModalState(() => isSubmitting = true);
                            try {
                              await _apiService.updateCondition(
                                  id, {'name': nameCtrl.text.trim()});
                              if (ctx.mounted) Navigator.pop(ctx);
                              await _loadHubData();
                            } catch (_) {
                              setModalState(() => isSubmitting = false);
                            }
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditVitalSheet(Map<String, dynamic> v) {
    final id = v['id']?.toString() ?? '';
    final valCtrl = TextEditingController(text: v['value']?.toString() ?? '');
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              top: 20,
              left: 20,
              right: 20),
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Edit Logged Vital',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                  controller: valCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Blood Glucose (mg/dL)')),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14)),
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (valCtrl.text.trim().isNotEmpty && id.isNotEmpty) {
                            setModalState(() => isSubmitting = true);
                            try {
                              await _apiService.updateVital(id, {
                                'value':
                                    double.tryParse(valCtrl.text.trim()) ?? 100
                              });
                              if (ctx.mounted) Navigator.pop(ctx);
                              await _loadHubData();
                            } catch (_) {
                              setModalState(() => isSubmitting = false);
                            }
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedicationsTab() {
    if (_medications.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDFA),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF99F6E4)),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('💊', style: TextStyle(fontSize: 36)),
              SizedBox(height: 12),
              Text('No Active Medications Recorded',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF0F172A))),
              SizedBox(height: 6),
              Text(
                  'Add daily prescriptions using the + Add Record button below to assist first responders.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      );
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
                child: const Icon(Icons.medication_outlined,
                    color: Color(0xFF0284C7)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$name ${dose.isNotEmpty ? "($dose)" : ""}'.trim(),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(
                        'Freq: $freq ${doctor.isNotEmpty ? "• Dr. $doctor" : ""}',
                        style: const TextStyle(
                            color: Color(0xFF64748B), fontSize: 12)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined,
                    color: Color(0xFF0D9488), size: 20),
                onPressed: () => _showEditMedicationSheet(med),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    color: Color(0xFFEF4444), size: 20),
                onPressed: () => _confirmDeleteDialog(
                  title: 'Delete Medication',
                  message: 'Are you sure you want to delete "$name"?',
                  onConfirm: () => _apiService.deleteMedication(id),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAllergiesTab() {
    if (_allergies.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFBBF7D0)),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('✅', style: TextStyle(fontSize: 36)),
              SizedBox(height: 12),
              Text('No Known Allergies Recorded',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF15803D))),
              SizedBox(height: 6),
              Text(
                  'Your emergency QR code will indicate no known drug or food allergies.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF166534)),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    final critical = _allergies
        .where((a) =>
            a['is_critical'] == true ||
            (a['severity'] ?? '').toString().toLowerCase() == 'severe')
        .toList();
    final nonCritical = _allergies
        .where((a) => !(a['is_critical'] == true ||
            (a['severity'] ?? '').toString().toLowerCase() == 'severe'))
        .toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (critical.isNotEmpty) ...[
          const Text('CRITICAL ALLERGIES',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                  letterSpacing: 1)),
          const SizedBox(height: 8),
          ...critical.map((item) {
            final id = item['id']?.toString() ?? '';
            final name = item['allergen'] ??
                item['name'] ??
                item['allergen_name'] ??
                'Allergy';
            final reaction = item['reaction_description'] ??
                item['reaction'] ??
                'Anaphylaxis Risk';

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Row(
                  children: [
                    Container(
                        width: 5, height: 60, color: const Color(0xFFDC2626)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$name — SEVERE',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF991B1B),
                                  fontSize: 14)),
                          const SizedBox(height: 2),
                          Text(reaction,
                              style: const TextStyle(
                                  color: Color(0xFF64748B), fontSize: 12)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined,
                          color: Color(0xFF0D9488), size: 20),
                      onPressed: () => _showEditAllergySheet(item),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded,
                          color: Color(0xFFEF4444), size: 20),
                      onPressed: () => _confirmDeleteDialog(
                        title: 'Delete Critical Allergy',
                        message: 'Are you sure you want to delete "$name"?',
                        onConfirm: () => _apiService.deleteAllergy(id),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
        ],
        if (nonCritical.isNotEmpty) ...[
          const Text('OTHER ALLERGIES',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                  letterSpacing: 1)),
          const SizedBox(height: 8),
          ...nonCritical.map((item) {
            final id = item['id']?.toString() ?? '';
            final name = item['allergen'] ??
                item['name'] ??
                item['allergen_name'] ??
                'Allergy';
            final reaction = item['reaction_description'] ??
                item['reaction'] ??
                'Mild reaction';
            final severityStr =
                (item['severity'] ?? 'Moderate').toString().toUpperCase();

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Row(
                  children: [
                    Container(
                        width: 5, height: 60, color: const Color(0xFFF59E0B)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$name — $severityStr',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Color(0xFF0F172A))),
                          const SizedBox(height: 2),
                          Text(reaction,
                              style: const TextStyle(
                                  color: Color(0xFF64748B), fontSize: 12)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined,
                          color: Color(0xFF0D9488), size: 20),
                      onPressed: () => _showEditAllergySheet(item),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded,
                          color: Color(0xFFEF4444), size: 20),
                      onPressed: () => _confirmDeleteDialog(
                        title: 'Delete Allergy',
                        message: 'Are you sure you want to delete "$name"?',
                        onConfirm: () => _apiService.deleteAllergy(id),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ],
    );
  }

  void _showEditSurgerySheet(Map<String, dynamic> surg) {
    final id = surg['id']?.toString() ?? '';
    final nameCtrl = TextEditingController(text: surg['procedure_name'] ?? '');
    final hospitalCtrl = TextEditingController(text: surg['hospital'] ?? '');
    final surgeonCtrl = TextEditingController(text: surg['surgeon'] ?? '');
    final notesCtrl = TextEditingController(
        text: surg['complications_notes'] ?? surg['notes'] ?? '');
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          constraints:
              BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.88),
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: SafeArea(
            child: Padding(
              padding:
                  EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                        child: Container(
                            width: 36,
                            height: 4,
                            decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(2)))),
                    const SizedBox(height: 16),
                    const Text('Edit Surgery / Procedure',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A))),
                    const SizedBox(height: 16),
                    TextField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Procedure Name *',
                            prefixIcon: Icon(Icons.local_hospital_outlined,
                                color: Color(0xFF0D9488)))),
                    const SizedBox(height: 12),
                    TextField(
                        controller: hospitalCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Hospital (Optional)')),
                    const SizedBox(height: 12),
                    TextField(
                        controller: surgeonCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Surgeon (Optional)')),
                    const SizedBox(height: 12),
                    TextField(
                        controller: notesCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Complications / Notes (Optional)')),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14))),
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                if (nameCtrl.text.trim().isNotEmpty &&
                                    id.isNotEmpty) {
                                  setModalState(() => isSubmitting = true);
                                  try {
                                    await _apiService.updateSurgery(id, {
                                      'procedure_name': nameCtrl.text.trim(),
                                      'hospital':
                                          hospitalCtrl.text.trim().isNotEmpty
                                              ? hospitalCtrl.text.trim()
                                              : null,
                                      'surgeon':
                                          surgeonCtrl.text.trim().isNotEmpty
                                              ? surgeonCtrl.text.trim()
                                              : null,
                                      'complications_notes':
                                          notesCtrl.text.trim().isNotEmpty
                                              ? notesCtrl.text.trim()
                                              : null,
                                    });
                                    if (ctx.mounted) Navigator.pop(ctx);
                                    await _loadHubData();
                                  } catch (e) {
                                    setModalState(() => isSubmitting = false);
                                  }
                                }
                              },
                        child: isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Text('Save Changes',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showEditDeviceSheet(Map<String, dynamic> dev) {
    final id = dev['id']?.toString() ?? '';
    final nameCtrl = TextEditingController(text: dev['device_name'] ?? '');
    final modelCtrl =
        TextEditingController(text: dev['model_manufacturer'] ?? '');
    final locationCtrl =
        TextEditingController(text: dev['location_on_body'] ?? '');
    final notesCtrl = TextEditingController(text: dev['notes'] ?? '');
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          constraints:
              BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.88),
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: SafeArea(
            child: Padding(
              padding:
                  EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                        child: Container(
                            width: 36,
                            height: 4,
                            decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(2)))),
                    const SizedBox(height: 16),
                    const Text('Edit Implanted Device',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A))),
                    const SizedBox(height: 16),
                    TextField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Device Name *',
                            prefixIcon: Icon(Icons.memory_outlined,
                                color: Color(0xFF0D9488)))),
                    const SizedBox(height: 12),
                    TextField(
                        controller: modelCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Model / Manufacturer (Optional)')),
                    const SizedBox(height: 12),
                    TextField(
                        controller: locationCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Location on Body (Optional)')),
                    const SizedBox(height: 12),
                    TextField(
                        controller: notesCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Notes (Optional)')),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14))),
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                if (nameCtrl.text.trim().isNotEmpty &&
                                    id.isNotEmpty) {
                                  setModalState(() => isSubmitting = true);
                                  try {
                                    await _apiService.updateDevice(id, {
                                      'device_name': nameCtrl.text.trim(),
                                      'model_manufacturer':
                                          modelCtrl.text.trim().isNotEmpty
                                              ? modelCtrl.text.trim()
                                              : null,
                                      'location_on_body':
                                          locationCtrl.text.trim().isNotEmpty
                                              ? locationCtrl.text.trim()
                                              : null,
                                      'notes': notesCtrl.text.trim().isNotEmpty
                                          ? notesCtrl.text.trim()
                                          : null,
                                    });
                                    if (ctx.mounted) Navigator.pop(ctx);
                                    await _loadHubData();
                                  } catch (e) {
                                    setModalState(() => isSubmitting = false);
                                  }
                                }
                              },
                        child: isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Text('Save Changes',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoreTabContent() {
    if (_activeMoreSubView == 'surgeries') {
      return _buildSurgeriesTab();
    } else if (_activeMoreSubView == 'devices') {
      return _buildDevicesTab();
    } else if (_activeMoreSubView == 'vitals') {
      return _buildVitalsTab();
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'More Health Records',
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
              letterSpacing: 0.5),
        ),
        const SizedBox(height: 12),
        _buildMenuItemTile(
          icon: Icons.local_hospital_outlined,
          iconBg: const Color(0xFFCCFBF1),
          iconColor: const Color(0xFF0D9488),
          title: 'Surgeries & Procedures',
          count: _surgeries.length,
          onTap: () => setState(() => _activeMoreSubView = 'surgeries'),
        ),
        const SizedBox(height: 10),
        _buildMenuItemTile(
          icon: Icons.memory_outlined,
          iconBg: const Color(0xFFCCFBF1),
          iconColor: const Color(0xFF0D9488),
          title: 'Implanted Devices',
          count: _devices.length,
          onTap: () => setState(() => _activeMoreSubView = 'devices'),
        ),
        const SizedBox(height: 10),
        _buildMenuItemTile(
          icon: Icons.favorite_border_rounded,
          iconBg: const Color(0xFFFCE7F3),
          iconColor: const Color(0xFFDB2777),
          title: 'Vitals Log',
          count: _vitals.length,
          onTap: () => setState(() => _activeMoreSubView = 'vitals'),
        ),
      ],
    );
  }

  Widget _buildMenuItemTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required int count,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color(0xFF0F172A))),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Color(0xFF475569)),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }

  Widget _buildSurgeriesTab() {
    if (_surgeries.isEmpty) {
      return _buildEmptyView(
        'No surgeries recorded — add past procedures to inform first responders of surgical history.',
        icon: Icons.local_hospital_outlined,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _surgeries.length,
      itemBuilder: (context, index) {
        final surg = _surgeries[index];
        final id = surg['id']?.toString() ?? '';
        final name = surg['procedure_name'] ?? 'Procedure';
        final datePerformed = surg['date_performed'] ??
            surg['created_at']?.toString().split('T').first ??
            'Date unspecified';
        final hospital = surg['hospital'] ?? '';
        final notes = (surg['complications_notes'] ?? surg['notes'] ?? '')
            .toString()
            .trim();

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
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                    color: Color(0xFFCCFBF1), shape: BoxShape.circle),
                child: const Icon(Icons.local_hospital_outlined,
                    color: Color(0xFF0D9488), size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF0F172A))),
                    const SizedBox(height: 2),
                    Text(
                        '$datePerformed${hospital.isNotEmpty ? " • $hospital" : ""}',
                        style: const TextStyle(
                            color: Color(0xFF64748B), fontSize: 12)),
                    if (notes.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text('Notes: $notes',
                          style: const TextStyle(
                              color: Color(0xFF0D9488),
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined,
                    color: Color(0xFF0D9488), size: 20),
                onPressed: () => _showEditSurgerySheet(surg),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    color: Color(0xFFEF4444), size: 20),
                onPressed: () => _confirmDeleteDialog(
                  title: 'Delete Surgery Record',
                  message: 'Are you sure you want to delete "$name"?',
                  onConfirm: () => _apiService.deleteSurgery(id),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDevicesTab() {
    if (_devices.isEmpty) {
      return _buildEmptyView(
        'No implanted devices recorded — add a pacemaker, stent, insulin pump, or similar if you have one.',
        icon: Icons.memory_outlined,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _devices.length,
      itemBuilder: (context, index) {
        final dev = _devices[index];
        final id = dev['id']?.toString() ?? '';
        final name = dev['device_name'] ?? 'Device';
        final model = dev['model_manufacturer'] ?? '';
        final location = dev['location_on_body'] ?? '';
        final notes = (dev['notes'] ?? '').toString().trim();

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
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                    color: Color(0xFFCCFBF1), shape: BoxShape.circle),
                child: const Icon(Icons.memory_outlined,
                    color: Color(0xFF0D9488), size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF0F172A))),
                    const SizedBox(height: 2),
                    Text(
                        '${location.isNotEmpty ? "Location: $location" : ""}${model.isNotEmpty ? " • Model: $model" : ""}',
                        style: const TextStyle(
                            color: Color(0xFF64748B), fontSize: 12)),
                    if (notes.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text('Notes: $notes',
                          style: const TextStyle(
                              color: Color(0xFF0D9488),
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined,
                    color: Color(0xFF0D9488), size: 20),
                onPressed: () => _showEditDeviceSheet(dev),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    color: Color(0xFFEF4444), size: 20),
                onPressed: () => _confirmDeleteDialog(
                  title: 'Delete Implanted Device',
                  message: 'Are you sure you want to delete "$name"?',
                  onConfirm: () => _apiService.deleteDevice(id),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildConditionsTab() {
    if (_conditions.isEmpty) {
      return _buildEmptyView(
        'No medical conditions recorded — add chronic conditions like Diabetes or Asthma.',
        icon: Icons.assignment_outlined,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _conditions.length,
      itemBuilder: (context, index) {
        final cond = _conditions[index];
        final id = cond['id']?.toString() ?? '';
        final name = cond['name'] ?? 'Condition';

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
              const Icon(Icons.assignment_outlined,
                  color: Color(0xFF8B5CF6), size: 28),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(cond['status'] ?? 'Active',
                        style: const TextStyle(
                            color: Color(0xFF64748B), fontSize: 12)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined,
                    color: Color(0xFF0D9488), size: 20),
                onPressed: () => _showEditConditionSheet(cond),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    color: Color(0xFFEF4444), size: 20),
                onPressed: () => _confirmDeleteDialog(
                  title: 'Delete Condition',
                  message: 'Are you sure you want to delete "$name"?',
                  onConfirm: () => _apiService.deleteCondition(id),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatVitalTypeLabel(String rawType) {
    final s = rawType.toLowerCase().replaceAll(' ', '_');
    if (s == 'glucose' || s == 'blood_glucose') return 'BLOOD GLUCOSE';
    if (s == 'bp_systolic') return 'BP (SYSTOLIC)';
    if (s == 'bp_diastolic') return 'BP (DIASTOLIC)';
    if (s == 'heart_rate') return 'HEART RATE';
    if (s == 'spo2') return 'BLOOD OXYGEN (SpO2)';
    if (s == 'temperature') return 'TEMPERATURE';
    if (s == 'weight') return 'WEIGHT';
    return s.replaceAll('_', ' ').toUpperCase();
  }

  Widget _buildVitalsTab() {
    if (_vitals.isEmpty) {
      return _buildEmptyView(
        'Log your BP, glucose, or heart rate — your last reading is included in emergency briefings.',
        icon: Icons.favorite_border_rounded,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _vitals.length,
      itemBuilder: (context, index) {
        final v = _vitals[index];
        final id = v['id']?.toString() ?? '';
        final type = _formatVitalTypeLabel(v['vital_type'] ?? 'VITAL');
        final val = v['value']?.toString() ?? '';
        final unit = v['unit'] ?? '';
        final source = v['source'] ?? 'manual';

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
                    Row(
                      children: [
                        Expanded(
                          child: Text('$type: $val $unit'.trim(),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                        if (index == 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(6)),
                            child: const Text('LATEST',
                                style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF15803D))),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                        'Source: $source • Recorded ${v['recorded_at'] != null ? v['recorded_at'].toString().split('T').first : "recently"}',
                        style: const TextStyle(
                            color: Color(0xFF64748B), fontSize: 12)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined,
                    color: Color(0xFF0D9488), size: 20),
                onPressed: () => _showEditVitalSheet(v),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    color: Color(0xFFEF4444), size: 20),
                onPressed: () async {
                  if (id.isNotEmpty) {
                    await _apiService.deleteVital(id).catchError((_) {});
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

  Widget _buildEmptyView(
    String text, {
    IconData icon = Icons.folder_open_rounded,
    Widget? actionButton,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: const Color(0xFF64748B)),
            ),
            const SizedBox(height: 16),
            Text(
              text,
              style: const TextStyle(
                  color: Color(0xFF475569), fontSize: 13, height: 1.4),
              textAlign: TextAlign.center,
            ),
            if (actionButton != null) ...[
              const SizedBox(height: 16),
              actionButton,
            ],
          ],
        ),
      ),
    );
  }
}
