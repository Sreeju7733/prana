import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../main_navigation_screen.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  final bool isEditMode;
  const ProfileScreen({super.key, this.isEditMode = false});

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
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  String? _avatarUrl;
  bool _isUploadingAvatar = false;
  String _selectedGender = 'M';
  String _selectedBloodGroup = 'O+';
  final List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-'
  ];

  @override
  void initState() {
    super.initState();
    final cached = HealthCacheManager.dashboardData?['profile'] as Map<String, dynamic>?;
    if (cached != null) {
      _populateProfileMap(cached);
    }
    _loadExistingData();
  }

  void _populateProfileMap(Map<String, dynamic> profile) {
    if (profile['full_name'] != null &&
        profile['full_name'].toString().trim().isNotEmpty &&
        profile['full_name'].toString().trim() != 'undefined') {
      _nameController.text = profile['full_name'].toString().trim();
    }
    if (profile['date_of_birth'] != null &&
        profile['date_of_birth'].toString().trim().isNotEmpty &&
        profile['date_of_birth'].toString().trim() != 'undefined') {
      final rawDob = profile['date_of_birth'].toString().trim().split('T').first;
      _dobController.text = rawDob;
    }
    if (profile['gender'] != null) {
      final g = profile['gender'].toString().trim().toUpperCase();
      _selectedGender = (g == 'MALE' || g == 'M')
          ? 'M'
          : ((g == 'FEMALE' || g == 'F') ? 'F' : 'O');
    }
    if (profile['blood_group'] != null &&
        _bloodGroups.contains(profile['blood_group'].toString().trim())) {
      _selectedBloodGroup = profile['blood_group'].toString().trim();
    }
    if (profile['weight'] != null && profile['weight'].toString().trim().isNotEmpty) {
      _weightController.text = profile['weight'].toString().trim();
    } else if (profile['weight_kg'] != null && profile['weight_kg'].toString().trim().isNotEmpty) {
      _weightController.text = profile['weight_kg'].toString().trim();
    }
    if (profile['height'] != null && profile['height'].toString().trim().isNotEmpty) {
      _heightController.text = profile['height'].toString().trim();
    } else if (profile['height_cm'] != null && profile['height_cm'].toString().trim().isNotEmpty) {
      _heightController.text = profile['height_cm'].toString().trim();
    }
    if (profile['avatar_url'] != null &&
        profile['avatar_url'].toString().trim().isNotEmpty &&
        profile['avatar_url'].toString().trim() != 'undefined') {
      _avatarUrl = profile['avatar_url'].toString().trim();
    }
  }

  Future<void> _pickAvatarImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Choose Profile Photo',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined, color: Color(0xFF0D9488)),
                  title: const Text('Choose from Gallery'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _selectAndUploadImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined, color: Color(0xFF0D9488)),
                  title: const Text('Take a Photo'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _selectAndUploadImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectAndUploadImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() => _isUploadingAvatar = true);
        final bytes = await pickedFile.readAsBytes();
        final base64Str = 'data:image/jpeg;base64,${base64Encode(bytes)}';

        final uploadedUrl = await _apiService.uploadAvatarBase64(base64Str);
        if (mounted) {
          setState(() {
            _avatarUrl = uploadedUrl;
            _isUploadingAvatar = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile photo uploaded and saved!'),
              backgroundColor: Color(0xFF0D9488),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingAvatar = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload photo: ${e.toString().replaceAll("Exception: ", "")}')),
        );
      }
    }
  }

  Future<void> _loadExistingData() async {
    try {
      final dashboard = await _apiService.getDashboard();
      final profile = dashboard['profile'] as Map<String, dynamic>?;
      if (profile != null && mounted) {
        setState(() {
          _populateProfileMap(profile);
        });
      }

      if (widget.isEditMode) return;

      final results = await Future.wait([
        _apiService.getAllergies(),
        _apiService.getMedications(),
        _apiService.getEmergencyContacts(),
      ]);

      final allergies = results[0];
      final meds = results[1];
      final contacts = results[2];

      if (mounted) {
        setState(() {
          if (allergies.isNotEmpty) {
            _hasKnownAllergies = true;
            _allergiesList.clear();
            for (var a in allergies) {
              final String sev = a['severity']?.toString() ?? 'Severe';
              final String capitalizedSev = sev.isEmpty ? 'Severe' : (sev[0].toUpperCase() + sev.substring(1).toLowerCase());
              _allergiesList.add({
                'name': a['allergen']?.toString() ?? '',
                'severity': capitalizedSev,
                'reaction': a['reaction_description']?.toString() ?? '',
              });
            }
          }
          if (meds.isNotEmpty) {
            _takesMedications = true;
            _medicationsList.clear();
            for (var m in meds) {
              _medicationsList.add({
                'name': m['name']?.toString() ?? '',
                'dose_value': m['dose_value']?.toString() ?? '',
                'dose_unit': m['dose_unit']?.toString() ?? 'mg',
                'dose': m['dose']?.toString() ?? '',
                'frequency': m['frequency']?.toString() ?? 'Twice daily',
                'reason': m['reason']?.toString() ?? '',
              });
            }
          }
          if (contacts.isNotEmpty) {
            final c = contacts.first;
            _contactNameController.text = c['name']?.toString() ?? '';
            _contactPhoneController.text = c['phone']?.toString() ?? c['phone_number']?.toString() ?? '';
            if (c['relationship'] != null) {
              _contactRelationship = c['relationship'].toString();
            }
          }
        });
      }
    } catch (_) {}
  }

  // Step 2: Critical Allergies
  bool _hasKnownAllergies = false;
  final _allergyController = TextEditingController();
  String _selectedReaction = '';
  String _allergySeverity = 'Severe';
  int? _editingAllergyIndex;
  final List<Map<String, String>> _allergiesList = [];

  final List<String> _quickAddAllergies = [
    'Penicillin',
    'Peanuts',
    'Shellfish',
    'Eggs',
    'Milk',
    'Latex',
    'Bee Sting',
    'Dust',
  ];

  final List<String> _commonAllergies = [
    'Penicillin',
    'Amoxicillin',
    'Ampicillin',
    'Peanuts',
    'Shellfish',
    'Eggs',
    'Milk',
    'Latex',
    'Bee Sting',
    'Dust',
    'Sulfa Drugs',
    'Aspirin',
    'Ibuprofen',
    'Contrast Dye',
  ];

  final List<String> _commonReactions = [
    'Rash',
    'Hives',
    'Swelling',
    'Anaphylaxis',
    'Trouble breathing',
    'Vomiting',
    'Sneezing',
    'Itchy eyes',
    'Loss of consciousness',
  ];

  // Step 3: Medications
  bool _takesMedications = false;
  final _medNameController = TextEditingController();
  final _medDoseValueController = TextEditingController();
  String _selectedDoseUnit = 'mg';
  String _selectedFrequency = 'Twice daily';
  final _medReasonController = TextEditingController();
  int? _editingMedicationIndex;
  final List<Map<String, String>> _medicationsList = [];

  final List<String> _doseUnits = [
    'mg',
    'mcg',
    'g',
    'mL',
    'IU',
    'Tablet(s)',
    'Capsule(s)',
    'Puff(s)',
    'Drop(s)',
    'Other',
  ];

  final List<String> _frequencies = [
    'Once daily',
    'Twice daily',
    'Three times daily',
    'Every morning',
    'Every night',
    'As needed (PRN)',
    'Weekly',
    'Monthly',
    'Other...',
  ];

  final List<String> _suggestedMedications = [
    'Metformin',
    'Paracetamol',
    'Aspirin',
    'Insulin',
    'Levothyroxine',
    'Amlodipine',
    'Losartan',
    'Atorvastatin',
    'Omeprazole',
    'Salbutamol Inhaler',
  ];

  void _saveOrAddMedication() {
    final name = _medNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a medication name')),
      );
      return;
    }

    final doseVal = _medDoseValueController.text.trim();
    final doseCombined =
        doseVal.isNotEmpty ? '$doseVal $_selectedDoseUnit' : _selectedDoseUnit;

    if (_editingMedicationIndex == null &&
        _medicationsList.any((m) =>
            m['name']?.toLowerCase() == name.toLowerCase() &&
            m['dose'] == doseCombined)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Medication "$name" ($doseCombined) is already added.')),
      );
      return;
    }

    final medData = {
      'name': name,
      'dose_value': doseVal,
      'dose_unit': _selectedDoseUnit,
      'dose': doseCombined,
      'frequency': _selectedFrequency,
      'reason': _medReasonController.text.trim(),
    };

    setState(() {
      if (_editingMedicationIndex != null &&
          _editingMedicationIndex! < _medicationsList.length) {
        _medicationsList[_editingMedicationIndex!] = medData;
        _editingMedicationIndex = null;
      } else {
        _medicationsList.add(medData);
      }
      _medNameController.clear();
      _medDoseValueController.clear();
      _medReasonController.clear();
      _selectedDoseUnit = 'mg';
      _selectedFrequency = 'Twice daily';
    });
  }

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
    } else if (_currentStep == 1) {
      if (_hasKnownAllergies && _allergiesList.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add at least one allergy or select "No Known Allergies"'),
          ),
        );
        return;
      }
    } else if (_currentStep == 2) {
      if (_takesMedications && _medicationsList.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add at least one medication or select "I don\'t take any medications"'),
          ),
        );
        return;
      }
    } else if (_currentStep == 3) {
      if (_contactNameController.text.trim().isEmpty ||
          _contactPhoneController.text.trim().length != 10) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid emergency contact name and 10-digit phone number'),
          ),
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

  void _saveOrAddAllergy() {
    final name = _allergyController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an allergy name')),
      );
      return;
    }

    final allergyData = {
      'name': name,
      'severity': _allergySeverity,
      'reaction': _selectedReaction,
    };

    setState(() {
      if (_editingAllergyIndex != null &&
          _editingAllergyIndex! < _allergiesList.length) {
        _allergiesList[_editingAllergyIndex!] = allergyData;
        _editingAllergyIndex = null;
      } else {
        _allergiesList.add(allergyData);
      }
      _allergyController.clear();
      _selectedReaction = '';
      _allergySeverity = 'Severe';
    });
  }

  void _submitProfileWizard() async {
    setState(() => _isLoading = true);
    try {
      // 1. Update Profile
      await _apiService.updateProfile(
        fullName: _nameController.text.trim(),
        gender: _selectedGender,
        dateOfBirth:
            _dobController.text.isNotEmpty ? _dobController.text.trim() : null,
        bloodGroup: _selectedBloodGroup,
        weightKg: double.tryParse(_weightController.text.trim()),
        heightCm: double.tryParse(_heightController.text.trim()),
      );

      // 2. Post Allergies
      if (_hasKnownAllergies) {
        for (var a in _allergiesList) {
          final severityLower = (a['severity'] ?? 'Severe').toLowerCase();
          await _apiService.addAllergy({
            'allergen': a['name'] ?? '',
            'severity': severityLower,
            'reaction_description':
                a['reaction']?.isNotEmpty == true ? a['reaction'] : null,
            'is_critical': severityLower == 'severe',
          }).catchError((_) => <String, dynamic>{});
        }
      }

      // 3. Post Medications
      if (_takesMedications) {
        // Auto-save pending medication text input if user forgot to click Add Medication button
        final pendingName = _medNameController.text.trim();
        if (pendingName.isNotEmpty) {
          final doseVal = _medDoseValueController.text.trim();
          final doseCombined = doseVal.isNotEmpty ? '$doseVal $_selectedDoseUnit' : _selectedDoseUnit;
          if (!_medicationsList.any((m) => m['name']?.toLowerCase() == pendingName.toLowerCase())) {
            _medicationsList.add({
              'name': pendingName,
              'dose_value': doseVal,
              'dose_unit': _selectedDoseUnit,
              'dose': doseCombined,
              'frequency': _selectedFrequency,
              'reason': _medReasonController.text.trim(),
            });
          }
        }

        for (var m in _medicationsList) {
          final doseStr = (m['dose'] != null && m['dose'].toString().trim().isNotEmpty)
              ? m['dose'].toString().trim()
              : (m['dose_value'] != null && m['dose_value'].toString().trim().isNotEmpty)
                  ? '${m['dose_value']} ${m['dose_unit'] ?? 'mg'}'
                  : 'As prescribed';

          await _apiService.addMedication({
            'name': m['name'],
            'dose': doseStr,
            'dose_value': m['dose_value'],
            'dose_unit': m['dose_unit'],
            'frequency': m['frequency'] ?? 'Daily',
            'reason': m['reason']?.isNotEmpty == true ? m['reason'] : null,
            'is_active': true,
          }).catchError((_) => <String, dynamic>{});
        }
      }

      // 4. Post Primary Emergency Contact
      if (_contactNameController.text.trim().isNotEmpty && _contactPhoneController.text.trim().isNotEmpty) {
        await _apiService.addEmergencyContact({
          'name': _contactNameController.text.trim(),
          'relationship': _contactRelationship,
          'phone': _contactPhoneController.text.trim(),
          'is_primary': true,
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

  void _saveProfileOnly() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your full name')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _apiService.updateProfile(
        fullName: _nameController.text.trim(),
        gender: _selectedGender,
        dateOfBirth: _dobController.text.isNotEmpty ? _dobController.text.trim() : null,
        bloodGroup: _selectedBloodGroup,
        weightKg: double.tryParse(_weightController.text.trim()),
        heightCm: double.tryParse(_heightController.text.trim()),
      );

      HealthCacheManager.invalidate();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Color(0xFF0D9488),
          ),
        );
        Navigator.pop(context, true);
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

    if (widget.isEditMode) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text('Edit Profile',
              style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF0F172A), size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(child: _buildStep1BasicInfo()),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: _isLoading ? null : _saveProfileOnly,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Save Profile',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    const totalSteps = 4;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Step ${_currentStep + 1} of $totalSteps',
            style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Color(0xFF0F172A), size: 18),
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

            // Sticky Bottom Navigation Control (Only for Step 1 & Step 4)
            if (_currentStep == 0 || _currentStep == 3)
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: _isLoading ? null : _nextStep,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Text(_currentStep == 3 ? 'Complete Setup 🎉' : 'Continue',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateOfBirth(BuildContext context) async {
    DateTime initialDate = DateTime(2000, 1, 1);
    if (_dobController.text.isNotEmpty) {
      try {
        initialDate = DateTime.parse(_dobController.text.trim());
      } catch (_) {}
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              onSurface: const Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formatted =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      setState(() {
        _dobController.text = formatted;
      });
    }
  }

  // --- STEP 1: BASIC INFO & BLOOD GROUP GRID ---
  Widget _buildStep1BasicInfo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Basic Medical Info',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A))),
          const SizedBox(height: 6),
          const Text('Your blood group is the #1 scanned field by paramedics.',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
          const SizedBox(height: 24),

          // Profile Avatar Upload Header
          Center(
            child: GestureDetector(
              onTap: _isUploadingAvatar ? null : _pickAvatarImage,
              child: Stack(
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFCCFBF1),
                      border: Border.all(color: const Color(0xFF0D9488), width: 2.5),
                    ),
                    child: _isUploadingAvatar
                        ? const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Color(0xFF0D9488),
                            ),
                          )
                        : ClipOval(
                            child: (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                                ? (_avatarUrl!.startsWith('data:image')
                                    ? Image.memory(
                                        base64Decode(_avatarUrl!.split(',').last),
                                        fit: BoxFit.cover,
                                        width: 96,
                                        height: 96,
                                      )
                                    : Image.network(
                                        _avatarUrl!,
                                        fit: BoxFit.cover,
                                        width: 96,
                                        height: 96,
                                        errorBuilder: (_, __, ___) => const Icon(
                                          Icons.person,
                                          size: 50,
                                          color: Color(0xFF0D9488),
                                        ),
                                      ))
                                : const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Color(0xFF0D9488),
                                  ),
                          ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D9488),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

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
                  readOnly: true,
                  onTap: () => _selectDateOfBirth(context),
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
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Gender'),
                  items: const [
                    DropdownMenuItem(
                        value: 'M',
                        child: Text('Male', overflow: TextOverflow.ellipsis)),
                    DropdownMenuItem(
                        value: 'F',
                        child: Text('Female', overflow: TextOverflow.ellipsis)),
                    DropdownMenuItem(
                        value: 'Other',
                        child: Text('Other', overflow: TextOverflow.ellipsis)),
                    DropdownMenuItem(
                        value: 'Prefer not to say',
                        child: Text('Prefer not to say',
                            overflow: TextOverflow.ellipsis)),
                  ],
                  onChanged: (val) => setState(() => _selectedGender = val!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Weight (kg) & Height (cm)
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _weightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Weight (kg)',
                    hintText: 'e.g. 68',
                    prefixIcon: Icon(Icons.monitor_weight_outlined),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: TextFormField(
                  controller: _heightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Height (cm)',
                    hintText: 'e.g. 175',
                    prefixIcon: Icon(Icons.height_outlined),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Blood Group 8-Chip Grid
          const Text('Select Blood Group',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A))),
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
                      color: isSelected
                          ? const Color(0xFFDC2626)
                          : const Color(0xFFE2E8F0),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                                color: const Color(0xFFEF4444)
                                    .withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4))
                          ]
                        : [],
                  ),
                  child: Center(
                    child: Text(
                      bg,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color:
                            isSelected ? Colors.white : const Color(0xFF0F172A),
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
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          const Row(
            children: [
              Icon(Icons.shield_outlined, color: Color(0xFF0F172A), size: 28),
              SizedBox(width: 8),
              Text('Critical Allergies',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A))),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
              'Flag any severe reactions (Penicillin, Peanuts, Latex, etc.)',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
          const SizedBox(height: 24),

          // Selection Radio Toggle Cards: No Known Allergies vs I Have Allergies
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _hasKnownAllergies = false),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 12),
                    decoration: BoxDecoration(
                      color: !_hasKnownAllergies
                          ? const Color(0xFFF0FDF4)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: !_hasKnownAllergies
                            ? const Color(0xFF22C55E)
                            : const Color(0xFFE2E8F0),
                        width: !_hasKnownAllergies ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          !_hasKnownAllergies
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: !_hasKnownAllergies
                              ? const Color(0xFF16A34A)
                              : const Color(0xFF94A3B8),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'No Known Allergies',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Color(0xFF0F172A)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _hasKnownAllergies = true),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 12),
                    decoration: BoxDecoration(
                      color: _hasKnownAllergies
                          ? theme.primaryColor.withValues(alpha: 0.08)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _hasKnownAllergies
                            ? theme.primaryColor
                            : const Color(0xFFE2E8F0),
                        width: _hasKnownAllergies ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _hasKnownAllergies
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: _hasKnownAllergies
                              ? theme.primaryColor
                              : const Color(0xFF94A3B8),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'I Have Allergies',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Color(0xFF0F172A)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // -------------------------------------------------------------
          // STATE 1: If "No Known Allergies" is selected -> HIDE FORM ENTIRELY
          // -------------------------------------------------------------
          if (!_hasKnownAllergies) ...[
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: const Row(
                children: [
                  Text('✅ ', style: TextStyle(fontSize: 20)),
                  Expanded(
                    child: Text(
                      'No known allergies recorded.',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF15803D),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // -------------------------------------------------------------
            // STATE 2: If "I Have Allergies" is selected -> SHOW INPUT FORM
            // -------------------------------------------------------------
            const SizedBox(height: 24),
            const Text(
              'Common quick-add chips',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickAddAllergies.map((allergy) {
                return ActionChip(
                  avatar: Text('+',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor)),
                  label: Text(allergy,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                  backgroundColor: Colors.white,
                  side: BorderSide(
                      color: theme.primaryColor.withValues(alpha: 0.3)),
                  onPressed: () {
                    setState(() {
                      _allergyController.text = allergy;
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 20),
            const Text('Allergy Name',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A))),
            const SizedBox(height: 6),
            TextFormField(
              controller: _allergyController,
              decoration: InputDecoration(
                hintText: 'e.g. Penicillin or Peanuts',
                prefixIcon:
                    Icon(Icons.shield_outlined, color: theme.primaryColor),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (_) => setState(() {}),
            ),

            // Autocomplete Suggestions
            if (_allergyController.text.isNotEmpty &&
                _commonAllergies.any((a) =>
                    a
                        .toLowerCase()
                        .startsWith(_allergyController.text.toLowerCase()) &&
                    a.toLowerCase() !=
                        _allergyController.text.toLowerCase())) ...[
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: Column(
                  children: _commonAllergies
                      .where((a) =>
                          a.toLowerCase().startsWith(
                              _allergyController.text.toLowerCase()) &&
                          a.toLowerCase() !=
                              _allergyController.text.toLowerCase())
                      .take(4)
                      .map((suggestion) => ListTile(
                            dense: true,
                            title: Text(suggestion,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13)),
                            onTap: () {
                              setState(() {
                                _allergyController.text = suggestion;
                              });
                            },
                          ))
                      .toList(),
                ),
              ),
            ],

            const SizedBox(height: 16),
            const Text('Reaction (Optional)',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A))),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _selectedReaction,
              isExpanded: true,
              decoration: const InputDecoration(
                hintText: 'Rash, Swelling, Anaphylaxis...',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(Icons.medical_information_outlined,
                    color: Color(0xFF64748B)),
              ),
              items: [
                const DropdownMenuItem(
                    value: '',
                    child: Text('None / Unspecified',
                        style: TextStyle(color: Colors.grey))),
                ..._commonReactions.map((r) => DropdownMenuItem(
                    value: r, child: Text(r, overflow: TextOverflow.ellipsis))),
              ],
              onChanged: (val) => setState(() => _selectedReaction = val ?? ''),
            ),

            const SizedBox(height: 20),
            const Text('Severity',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A))),
            const SizedBox(height: 10),

            // 3-Level Severity Selector Cards (Yellow -> Orange -> Red)
            Row(
              children: [
                // 🟡 Mild (Amber/Yellow)
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _allergySeverity = 'Mild'),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 8),
                      decoration: BoxDecoration(
                        color: _allergySeverity == 'Mild'
                            ? const Color(0xFFFEF3C7)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _allergySeverity == 'Mild'
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFFE2E8F0),
                          width: _allergySeverity == 'Mild' ? 2 : 1,
                        ),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('🟡', style: TextStyle(fontSize: 14)),
                              SizedBox(width: 4),
                              Text('Mild',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Color(0xFFB45309))),
                            ],
                          ),
                          SizedBox(height: 6),
                          Text(
                            '• Sneezing\n• Itchy eyes\n• Mild rash',
                            style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF475569),
                                height: 1.3),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // 🟠 Moderate (Orange)
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _allergySeverity = 'Moderate'),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 8),
                      decoration: BoxDecoration(
                        color: _allergySeverity == 'Moderate'
                            ? const Color(0xFFFFEDD5)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _allergySeverity == 'Moderate'
                              ? const Color(0xFFEA580C)
                              : const Color(0xFFE2E8F0),
                          width: _allergySeverity == 'Moderate' ? 2 : 1,
                        ),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('🟠', style: TextStyle(fontSize: 14)),
                              SizedBox(width: 4),
                              Text('Moderate',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Color(0xFF9A3412))),
                            ],
                          ),
                          SizedBox(height: 6),
                          Text(
                            '• Hives\n• Vomiting\n• Swelling',
                            style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF475569),
                                height: 1.3),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // 🔴 Severe (Red)
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _allergySeverity = 'Severe'),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 8),
                      decoration: BoxDecoration(
                        color: _allergySeverity == 'Severe'
                            ? const Color(0xFFFEF2F2)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _allergySeverity == 'Severe'
                              ? const Color(0xFFDC2626)
                              : const Color(0xFFE2E8F0),
                          width: _allergySeverity == 'Severe' ? 2 : 1,
                        ),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('🔴', style: TextStyle(fontSize: 14)),
                              SizedBox(width: 4),
                              Text('Severe',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Color(0xFF991B1B))),
                            ],
                          ),
                          SizedBox(height: 6),
                          Text(
                            '• Breathing issue\n• Anaphylaxis\n• Unconscious',
                            style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF475569),
                                height: 1.3),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            // Outlined Secondary Action for "Add Allergy" (Single plus icon)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: theme.primaryColor, width: 1.5),
                  foregroundColor: theme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _saveOrAddAllergy,
                icon: Icon(
                    _editingAllergyIndex != null ? Icons.check : Icons.add,
                    color: theme.primaryColor),
                label: Text(
                  _editingAllergyIndex != null
                      ? 'Update Allergy Entry'
                      : 'Add Allergy',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: theme.primaryColor),
                ),
              ),
            ),

            // Added Allergies List with Edit & Delete Actions
            if (_allergiesList.isNotEmpty) ...[
              const SizedBox(height: 28),
              Row(
                children: [
                  const Text('ADDED ALLERGIES',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF64748B),
                          letterSpacing: 0.5)),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                        color: theme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10)),
                    child: Text('${_allergiesList.length}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: theme.primaryColor)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ..._allergiesList.asMap().entries.map((entry) {
                final index = entry.key;
                final a = entry.value;
                final severity = a['severity'] ?? 'Severe';
                final reaction = a['reaction'];
                final isSevere = severity.toLowerCase() == 'severe';
                final isModerate = severity.toLowerCase() == 'moderate';

                final dotEmoji = isSevere ? '🔴' : (isModerate ? '🟠' : '🟡');
                final cardBg = isSevere
                    ? const Color(0xFFFEF2F2)
                    : (isModerate
                        ? const Color(0xFFFFF7ED)
                        : const Color(0xFFFEF3C7));
                final borderColor = isSevere
                    ? const Color(0xFFFCA5A5)
                    : (isModerate
                        ? const Color(0xFFFDBA74)
                        : const Color(0xFFFCD34D));

                final subtitleText = (reaction != null && reaction.isNotEmpty)
                    ? '$severity • $reaction'
                    : severity;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      Text(dotEmoji, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              a['name'] ?? '',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  color: Color(0xFF0F172A)),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subtitleText,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: Color(0xFF475569)),
                            ),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: Icon(Icons.edit_outlined,
                            size: 16, color: theme.primaryColor),
                        label: Text('Edit',
                            style: TextStyle(
                                fontSize: 12,
                                color: theme.primaryColor,
                                fontWeight: FontWeight.bold)),
                        onPressed: () {
                          setState(() {
                            _editingAllergyIndex = index;
                            _allergyController.text = a['name'] ?? '';
                            _selectedReaction = a['reaction'] ?? '';
                            _allergySeverity = a['severity'] ?? 'Severe';
                          });
                        },
                      ),
                      const SizedBox(width: 4),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: const Icon(Icons.delete_outline_rounded,
                            size: 16, color: Color(0xFFEF4444)),
                        label: const Text('Delete',
                            style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFFEF4444),
                                fontWeight: FontWeight.bold)),
                        onPressed: () {
                          setState(() {
                            _allergiesList.removeAt(index);
                            if (_editingAllergyIndex == index) {
                              _editingAllergyIndex = null;
                              _allergyController.clear();
                              _selectedReaction = '';
                              _allergySeverity = 'Severe';
                            }
                          });
                        },
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
          // Non-sticky inline Continue button at bottom of Step 2 content
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: (!_hasKnownAllergies || _allergiesList.isNotEmpty) && !_isLoading ? _nextStep : null,
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Continue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // --- STEP 3: ACTIVE MEDICATIONS ---
  Widget _buildStep3Medications() {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          const Row(
            children: [
              Icon(Icons.medication_liquid_outlined,
                  color: Color(0xFF0F172A), size: 28),
              SizedBox(width: 8),
              Text('Active Medications',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A))),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Add medicines you currently take.\nThis is optional and can be updated later.',
            style:
                TextStyle(color: Color(0xFF64748B), fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 24),

          // Initial Choice Toggle Cards
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _takesMedications = false),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 12),
                    decoration: BoxDecoration(
                      color: !_takesMedications
                          ? const Color(0xFFF0FDF4)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: !_takesMedications
                            ? const Color(0xFF22C55E)
                            : const Color(0xFFE2E8F0),
                        width: !_takesMedications ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          !_takesMedications
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: !_takesMedications
                              ? const Color(0xFF16A34A)
                              : const Color(0xFF94A3B8),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            "I don't take any medications",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Color(0xFF0F172A)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _takesMedications = true),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 12),
                    decoration: BoxDecoration(
                      color: _takesMedications
                          ? theme.primaryColor.withValues(alpha: 0.08)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _takesMedications
                            ? theme.primaryColor
                            : const Color(0xFFE2E8F0),
                        width: _takesMedications ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _takesMedications
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: _takesMedications
                              ? theme.primaryColor
                              : const Color(0xFF94A3B8),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'I take one or more medications',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Color(0xFF0F172A)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // STATE 1: If "I don't take any medications" -> Show green banner
          if (!_takesMedications) ...[
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: const Row(
                children: [
                  Text('✅ ', style: TextStyle(fontSize: 20)),
                  Expanded(
                    child: Text(
                      'No active medications recorded.',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF15803D),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // STATE 2: If "I take medications" -> Show Medication Form
            const SizedBox(height: 24),

            // Suggested Medications Quick Chips
            const Text(
              'Suggested Medications',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _suggestedMedications.map((med) {
                return ActionChip(
                  avatar: Text('+',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor)),
                  label: Text(med,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                  backgroundColor: Colors.white,
                  side: BorderSide(
                      color: theme.primaryColor.withValues(alpha: 0.3)),
                  onPressed: () {
                    setState(() {
                      _medNameController.text = med;
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 20),
            const Text('Medication Name',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A))),
            const SizedBox(height: 6),
            TextFormField(
              controller: _medNameController,
              decoration: InputDecoration(
                hintText: 'Search medicines...',
                prefixIcon:
                    Icon(Icons.search_rounded, color: theme.primaryColor),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (_) => setState(() {}),
            ),

            // Autocomplete dropdown suggestions
            if (_medNameController.text.isNotEmpty &&
                _suggestedMedications.any((m) =>
                    m
                        .toLowerCase()
                        .startsWith(_medNameController.text.toLowerCase()) &&
                    m.toLowerCase() !=
                        _medNameController.text.toLowerCase())) ...[
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: Column(
                  children: _suggestedMedications
                      .where((m) =>
                          m.toLowerCase().startsWith(
                              _medNameController.text.toLowerCase()) &&
                          m.toLowerCase() !=
                              _medNameController.text.toLowerCase())
                      .take(4)
                      .map((suggestion) => ListTile(
                            dense: true,
                            title: Text(suggestion,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13)),
                            onTap: () {
                              setState(() {
                                _medNameController.text = suggestion;
                              });
                            },
                          ))
                      .toList(),
                ),
              ),
            ],

            const SizedBox(height: 16),
            // Split Dose Fields: [ Value ] [ Unit ▼ ]
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Dose',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A))),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _medDoseValueController,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                          hintText: '500',
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Unit',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A))),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedDoseUnit,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: _doseUnits
                            .map((u) => DropdownMenuItem(
                                value: u,
                                child:
                                    Text(u, overflow: TextOverflow.ellipsis)))
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedDoseUnit = val ?? 'mg'),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Text('Frequency',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A))),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _selectedFrequency,
              isExpanded: true,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,
                prefixIcon:
                    Icon(Icons.access_time_rounded, color: Color(0xFF64748B)),
              ),
              items: _frequencies
                  .map((f) => DropdownMenuItem(
                      value: f,
                      child: Text(f, overflow: TextOverflow.ellipsis)))
                  .toList(),
              onChanged: (val) =>
                  setState(() => _selectedFrequency = val ?? 'Twice daily'),
            ),

            const SizedBox(height: 16),
            const Text('Reason (Optional)',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A))),
            const SizedBox(height: 6),
            TextFormField(
              controller: _medReasonController,
              decoration: const InputDecoration(
                hintText: 'e.g. Type 2 Diabetes',
                filled: true,
                fillColor: Colors.white,
                prefixIcon:
                    Icon(Icons.info_outline_rounded, color: Color(0xFF64748B)),
              ),
            ),

            const SizedBox(height: 20),
            // Outlined Secondary Action Button for Add/Update Medication
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: theme.primaryColor, width: 1.5),
                  foregroundColor: theme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _saveOrAddMedication,
                icon: Icon(
                    _editingMedicationIndex != null ? Icons.check : Icons.add,
                    color: theme.primaryColor),
                label: Text(
                  _editingMedicationIndex != null
                      ? 'Update Medication Entry'
                      : 'Add Medication',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: theme.primaryColor),
                ),
              ),
            ),

            // Added Medications List with Edit & Delete Actions
            if (_medicationsList.isNotEmpty) ...[
              const SizedBox(height: 28),
              Row(
                children: [
                  const Text('YOUR MEDICATIONS',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF64748B),
                          letterSpacing: 0.5)),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                        color: theme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10)),
                    child: Text('${_medicationsList.length}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: theme.primaryColor)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ..._medicationsList.asMap().entries.map((entry) {
                final index = entry.key;
                final m = entry.value;
                final name = m['name'] ?? '';
                final dose = m['dose'] ?? '';
                final freq = m['frequency'] ?? '';
                final reason = m['reason'];

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2))
                    ],
                  ),
                  child: Row(
                    children: [
                      const Text('💊 ', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  color: Color(0xFF0F172A)),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$dose • $freq',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: Color(0xFF475569)),
                            ),
                            if (reason != null && reason.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                'For: $reason',
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 11,
                                    color: theme.primaryColor),
                              ),
                            ],
                          ],
                        ),
                      ),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: Icon(Icons.edit_outlined,
                            size: 16, color: theme.primaryColor),
                        label: Text('Edit',
                            style: TextStyle(
                                fontSize: 12,
                                color: theme.primaryColor,
                                fontWeight: FontWeight.bold)),
                        onPressed: () {
                          setState(() {
                            _editingMedicationIndex = index;
                            _medNameController.text = m['name'] ?? '';
                            _medDoseValueController.text =
                                m['dose_value'] ?? '';
                            _selectedDoseUnit = m['dose_unit'] ?? 'mg';
                            _selectedFrequency =
                                m['frequency'] ?? 'Twice daily';
                            _medReasonController.text = m['reason'] ?? '';
                          });
                        },
                      ),
                      const SizedBox(width: 4),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: const Icon(Icons.delete_outline_rounded,
                            size: 16, color: Color(0xFFEF4444)),
                        label: const Text('Delete',
                            style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFFEF4444),
                                fontWeight: FontWeight.bold)),
                        onPressed: () {
                          setState(() {
                            _medicationsList.removeAt(index);
                            if (_editingMedicationIndex == index) {
                              _editingMedicationIndex = null;
                              _medNameController.clear();
                              _medDoseValueController.clear();
                              _medReasonController.clear();
                              _selectedDoseUnit = 'mg';
                              _selectedFrequency = 'Twice daily';
                            }
                          });
                        },
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],

          // Non-sticky inline Continue button at bottom of Step 3 content
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: (!_takesMedications || _medicationsList.isNotEmpty) && !_isLoading ? _nextStep : null,
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Continue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 16),
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
          const Text('Emergency Contact',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A))),
          const SizedBox(height: 6),
          const Text(
              'At least one primary emergency contact is required for PRANA Relay SMS alerts.',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
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
              DropdownMenuItem(
                  value: 'Spouse / Family', child: Text('Spouse / Family')),
              DropdownMenuItem(value: 'Parent', child: Text('Parent')),
              DropdownMenuItem(value: 'Sibling', child: Text('Sibling')),
              DropdownMenuItem(
                  value: 'Friend / Other', child: Text('Friend / Other')),
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
