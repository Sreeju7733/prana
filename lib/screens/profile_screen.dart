import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main_navigation_screen.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final PageController _pageController = PageController();
  final ApiService _apiService = ApiService();
  int _currentStep = 0;
  bool _isLoading = false;

  // Step 1: Basic Info
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  String _selectedGender = 'M';
  String _selectedBloodGroup = 'O+';
  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  // Step 2: Critical Allergies
  final _allergyController = TextEditingController();
  String _allergySeverity = 'severe';
  final List<Map<String, String>> _allergiesList = [];

  // Step 3: Medications
  final _medNameController = TextEditingController();
  final _medDoseController = TextEditingController();
  final List<Map<String, String>> _medicationsList = [];

  // Step 4: Emergency Contact
  final _contactNameController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  String _contactRelationship = 'Spouse / Family';

  void _nextStep() {
    if (_currentStep == 0) {
      if (_nameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your full name')),
        );
        return;
      }
    } else if (_currentStep == 3) {
      if (_contactNameController.text.trim().isEmpty || _contactPhoneController.text.trim().length != 10) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid emergency contact name and 10-digit phone number')),
        );
        return;
      }
      _submitProfileWizard();
      return;
    }

    FocusScope.of(context).unfocus();
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _prevStep() {
    FocusScope.of(context).unfocus();
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _submitProfileWizard() async {
    setState(() => _isLoading = true);
    try {
      // 1. Update Profile
      await _apiService.updateProfile(
        fullName: _nameController.text.trim(),
        gender: _selectedGender,
        dateOfBirth: _dobController.text.isNotEmpty ? _dobController.text.trim() : null,
        bloodGroup: _selectedBloodGroup,
      );

      // 2. Post Allergies
      for (var a in _allergiesList) {
        await _apiService.addAllergy({
          'allergen': a['allergen'],
          'severity': a['severity'],
          'is_critical': a['severity'] == 'severe',
        }).catchError((_) => <String, dynamic>{});
      }

      // 3. Post Medications
      for (var m in _medicationsList) {
        await _apiService.addMedication({
          'name': m['name'],
          'dose': m['dose'],
          'frequency': 'Daily',
          'is_active': true,
        }).catchError((_) => <String, dynamic>{});
      }

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const totalSteps = 4;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Step ${_currentStep + 1} of $totalSteps', style: const TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 18),
                onPressed: _prevStep,
              )
            : null,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24),
          child: Column(
            children: [
              // Step Dots Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(totalSteps, (index) {
                  final isActive = index == _currentStep;
                  final isDone = index < _currentStep;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive
                          ? theme.primaryColor
                          : isDone
                              ? theme.primaryColor.withValues(alpha: 0.5)
                              : const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: LinearProgressIndicator(
                  value: (_currentStep + 1) / totalSteps,
                  backgroundColor: const Color(0xFFE2E8F0),
                  color: theme.primaryColor,
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentStep = index),
                children: [
                  _buildStep1BasicInfo(),
                  _buildStep2CriticalAllergies(),
                  _buildStep3Medications(),
                  _buildStep4EmergencyContact(),
                ],
              ),
            ),

            // Bottom Navigation Controls
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  if (_currentStep == 2)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: _nextStep,
                          child: const Text('Skip for now', style: TextStyle(color: Color(0xFF64748B))),
                        ),
                      ),
                    ),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: _isLoading ? null : _nextStep,
                      child: _isLoading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(_currentStep == 3 ? 'Complete Setup 🎉' : 'Continue'),
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

  // --- STEP 1: BASIC INFO & BLOOD GROUP GRID ---
  Widget _buildStep1BasicInfo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Basic Medical Info', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
          const SizedBox(height: 6),
          const Text('Your blood group is the #1 scanned field by paramedics.', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
          const SizedBox(height: 24),

          // Full Name
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Full Name *',
              hintText: 'e.g. Sreeju',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 16),

          // Date of Birth & Gender
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _dobController,
                  decoration: const InputDecoration(
                    labelText: 'Date of Birth',
                    hintText: 'YYYY-MM-DD',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedGender,
                  decoration: const InputDecoration(labelText: 'Gender'),
                  items: const [
                    DropdownMenuItem(value: 'M', child: Text('Male')),
                    DropdownMenuItem(value: 'F', child: Text('Female')),
                    DropdownMenuItem(value: 'Other', child: Text('Other')),
                  ],
                  onChanged: (val) => setState(() => _selectedGender = val!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Blood Group 8-Chip Grid
          const Text('Select Blood Group', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: _bloodGroups.length,
            itemBuilder: (context, index) {
              final bg = _bloodGroups[index];
              final isSelected = _selectedBloodGroup == bg;
              return GestureDetector(
                onTap: () => setState(() => _selectedBloodGroup = bg),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFEF4444) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? const Color(0xFFDC2626) : const Color(0xFFE2E8F0),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [BoxShadow(color: const Color(0xFFEF4444).withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))]
                        : [],
                  ),
                  child: Center(
                    child: Text(
                      bg,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: isSelected ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- STEP 2: CRITICAL ALLERGIES ---
  Widget _buildStep2CriticalAllergies() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
              SizedBox(width: 8),
              Text('Critical Allergies', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
            ],
          ),
          const SizedBox(height: 6),
          const Text('Flag any severe reactions (Penicillin, Peanuts, Latex, etc.)', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
          const SizedBox(height: 24),

          // Red-Flagged Allergy Input Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFCA5A5)),
            ),
            child: Column(
              children: [
                TextFormField(
                  controller: _allergyController,
                  decoration: const InputDecoration(
                    labelText: 'Allergen Name',
                    hintText: 'e.g. Penicillin or Peanuts',
                    fillColor: Colors.white,
                    filled: true,
                    prefixIcon: Icon(Icons.shield_outlined, color: Colors.red),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Severity: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const Spacer(),
                    ChoiceChip(
                      label: const Text('Severe'),
                      selected: _allergySeverity == 'severe',
                      selectedColor: Colors.red,
                      labelStyle: TextStyle(color: _allergySeverity == 'severe' ? Colors.white : Colors.black),
                      onSelected: (val) => setState(() => _allergySeverity = 'severe'),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Moderate'),
                      selected: _allergySeverity == 'moderate',
                      selectedColor: Colors.amber,
                      labelStyle: TextStyle(color: _allergySeverity == 'moderate' ? Colors.white : Colors.black),
                      onSelected: (val) => setState(() => _allergySeverity = 'moderate'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white),
                  onPressed: () {
                    final text = _allergyController.text.trim();
                    if (text.isNotEmpty) {
                      setState(() {
                        _allergiesList.add({'allergen': text, 'severity': _allergySeverity});
                        _allergyController.clear();
                      });
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Allergy Chip'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Added Allergy Chips
          if (_allergiesList.isNotEmpty) ...[
            const Text('ADDED ALLERGIES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _allergiesList
                  .map(
                    (a) => Chip(
                      backgroundColor: a['severity'] == 'severe' ? const Color(0xFFFEE2E2) : const Color(0xFFFEF3C7),
                      side: BorderSide(color: a['severity'] == 'severe' ? Colors.red : Colors.amber),
                      avatar: Icon(Icons.warning_rounded, size: 16, color: a['severity'] == 'severe' ? Colors.red : Colors.amber.shade800),
                      label: Text('${a['allergen']} (${a['severity']})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      onDeleted: () => setState(() => _allergiesList.remove(a)),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  // --- STEP 3: MEDICATIONS (OPTIONAL) ---
  Widget _buildStep3Medications() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Active Medications', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
          const SizedBox(height: 6),
          const Text('Add prescriptions you take daily (Optional & Skippable)', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _medNameController,
                  decoration: const InputDecoration(labelText: 'Medication Name', hintText: 'e.g. Metformin'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _medDoseController,
                  decoration: const InputDecoration(labelText: 'Dose', hintText: '500mg'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () {
              final name = _medNameController.text.trim();
              if (name.isNotEmpty) {
                setState(() {
                  _medicationsList.add({'name': name, 'dose': _medDoseController.text.trim()});
                  _medNameController.clear();
                  _medDoseController.clear();
                });
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Medication'),
          ),
          const SizedBox(height: 24),

          if (_medicationsList.isNotEmpty) ...[
            const Text('ADDED MEDICATIONS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 12),
            ..._medicationsList.map(
              (m) => Card(
                child: ListTile(
                  leading: const Icon(Icons.medication_outlined, color: Color(0xFF0284C7)),
                  title: Text(m['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(m['dose'] ?? ''),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, size: 18, color: Colors.red),
                    onPressed: () => setState(() => _medicationsList.remove(m)),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // --- STEP 4: EMERGENCY CONTACT ---
  Widget _buildStep4EmergencyContact() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Emergency Contact', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
          const SizedBox(height: 6),
          const Text('At least one primary emergency contact is required for PRANA Relay SMS alerts.', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
          const SizedBox(height: 24),

          TextFormField(
            controller: _contactNameController,
            decoration: const InputDecoration(
              labelText: 'Contact Name *',
              hintText: 'e.g. Jane Doe',
              prefixIcon: Icon(Icons.person_pin_outlined),
            ),
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            initialValue: _contactRelationship,
            decoration: const InputDecoration(labelText: 'Relationship *'),
            items: const [
              DropdownMenuItem(value: 'Spouse / Family', child: Text('Spouse / Family')),
              DropdownMenuItem(value: 'Parent', child: Text('Parent')),
              DropdownMenuItem(value: 'Sibling', child: Text('Sibling')),
              DropdownMenuItem(value: 'Friend / Other', child: Text('Friend / Other')),
            ],
            onChanged: (val) => setState(() => _contactRelationship = val!),
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _contactPhoneController,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: '10-Digit Phone Number *',
              hintText: '9876543210',
              prefixIcon: Icon(Icons.phone_outlined),
              counterText: '',
            ),
          ),
        ],
      ),
    );
  }
}
