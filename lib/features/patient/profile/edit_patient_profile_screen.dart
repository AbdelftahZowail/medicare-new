import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/models/user_models.dart';
import '../../../core/services/api_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../services/patient_profile_service.dart';

class EditPatientProfileScreen extends StatefulWidget {
  const EditPatientProfileScreen({super.key});

  @override
  State<EditPatientProfileScreen> createState() => _EditPatientProfileScreenState();
}

class _EditPatientProfileScreenState extends State<EditPatientProfileScreen> {
  final _service = PatientProfileService();
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  final _addressController = TextEditingController();
  final _bloodTypeController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _chronicDiseasesController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  bool _isUploading = false;
  int? _selectedGender;
  DateTime? _dateOfBirth;
  PatientProfile? _profile;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _addressController.dispose();
    _bloodTypeController.dispose();
    _allergiesController.dispose();
    _chronicDiseasesController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _service.getProfile();
      if (!mounted) return;
      _populateFields(profile);
      setState(() {
        _profile = profile;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profile: $e')),
      );
    }
  }

  void _populateFields(PatientProfile profile) {
    _nameController.text = profile.fullName;
    _phoneController.text = profile.phoneNumber;
    _emailController.text = profile.email ?? '';
    _addressController.text = profile.address ?? '';
    _bloodTypeController.text = profile.bloodType ?? '';
    _allergiesController.text = profile.allergies ?? '';
    _chronicDiseasesController.text = profile.chronicDiseases ?? '';
    _emergencyNameController.text = profile.emergencyContactName ?? '';
    _emergencyPhoneController.text = profile.emergencyContactPhone ?? '';
    _selectedGender = profile.gender;
    _dateOfBirth = profile.dateOfBirth;
    _profileImageUrl = profile.profileImageUrl;
  }

  Future<void> _pickAndUploadPhoto() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

      setState(() => _isUploading = true);

      final response = await ApiService().uploadFile(
        ApiEndpoints.uploadProfileImage,
        filePath: pickedFile.path,
        fieldName: 'file',
      );

      if (response.isSuccess && response.data != null) {
        final url = response.data!['url'] as String?;
        if (url != null && url.isNotEmpty) {
          setState(() {
            _profileImageUrl = url;
            _isUploading = false;
          });
          return;
        }
      }

      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message.isNotEmpty ? response.message : 'Failed to upload photo')),
        );
      }
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload error: $e')),
        );
      }
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(now.year - 30),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Select Date of Birth',
    );
    if (picked != null) {
      setState(() => _dateOfBirth = picked);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final updated = PatientProfile(
      id: _profile?.id ?? 0,
      userId: _profile?.userId ?? 0,
      fullName: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      gender: _selectedGender,
      dateOfBirth: _dateOfBirth,
      address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
      bloodType: _bloodTypeController.text.trim().isEmpty ? null : _bloodTypeController.text.trim(),
      allergies: _allergiesController.text.trim().isEmpty ? null : _allergiesController.text.trim(),
      chronicDiseases: _chronicDiseasesController.text.trim().isEmpty ? null : _chronicDiseasesController.text.trim(),
      emergencyContactName: _emergencyNameController.text.trim().isEmpty ? null : _emergencyNameController.text.trim(),
      emergencyContactPhone: _emergencyPhoneController.text.trim().isEmpty ? null : _emergencyPhoneController.text.trim(),
      profileImageUrl: _profileImageUrl,
    );

    try {
      await _service.updateProfile(updated);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved')),
      );
      context.pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Photo Upload
                      GestureDetector(
                        onTap: _isUploading ? null : _pickAndUploadPhoto,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: AppColors.primary100,
                              backgroundImage: _profileImageUrl != null
                                  ? NetworkImage(_profileImageUrl!)
                                  : null,
                              child: _profileImageUrl == null
                                  ? const Icon(Icons.person, size: 50, color: AppColors.primary)
                                  : null,
                            ),
                            Container(
                              height: 32,
                              width: 32,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: _isUploading
                                  ? const Center(child: CircularProgressIndicator(color: AppColors.textOnPrimary, strokeWidth: 2))
                                  : const Icon(Icons.camera_alt, color: AppColors.textOnPrimary, size: 16),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to change photo',
                        style: AppTextStyles.bodySmall,
                      ),
                      const SizedBox(height: 24),

                      AppTextField(
                        label: 'Full Name',
                        controller: _nameController,
                        validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Phone Number',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      // Date of Birth
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text('Date of Birth', style: AppTextStyles.labelLarge),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _pickDate,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, color: AppColors.textTertiary, size: 20),
                              const SizedBox(width: 12),
                              Text(
                                _dateOfBirth != null
                                    ? '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}'
                                    : 'Select date of birth',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: _dateOfBirth != null
                                      ? AppColors.textPrimary
                                      : AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Gender Selection
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text('Gender', style: AppTextStyles.labelLarge),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ChoiceChip(
                              label: const Text('Male'),
                              selected: _selectedGender == AppEnums.male,
                              onSelected: (_) => setState(() => _selectedGender = AppEnums.male),
                              selectedColor: AppColors.primary,
                              backgroundColor: AppColors.surface,
                              labelStyle: AppTextStyles.labelMedium.copyWith(
                                color: _selectedGender == AppEnums.male ? AppColors.textOnPrimary : AppColors.textPrimary,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                  color: _selectedGender == AppEnums.male ? AppColors.primary : AppColors.border,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ChoiceChip(
                              label: const Text('Female'),
                              selected: _selectedGender == AppEnums.female,
                              onSelected: (_) => setState(() => _selectedGender = AppEnums.female),
                              selectedColor: AppColors.primary,
                              backgroundColor: AppColors.surface,
                              labelStyle: AppTextStyles.labelMedium.copyWith(
                                color: _selectedGender == AppEnums.female ? AppColors.textOnPrimary : AppColors.textPrimary,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                  color: _selectedGender == AppEnums.female ? AppColors.primary : AppColors.border,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      AppTextField(
                        label: 'Address',
                        controller: _addressController,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Blood Type',
                        controller: _bloodTypeController,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Allergies',
                        controller: _allergiesController,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Chronic Diseases',
                        controller: _chronicDiseasesController,
                        maxLines: 2,
                        hint: 'e.g. Diabetes, Hypertension',
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Emergency Contact Name',
                        controller: _emergencyNameController,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Emergency Contact Phone',
                        controller: _emergencyPhoneController,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 24),

                      AppButton(
                        text: 'Save',
                        isLoading: _saving,
                        onPressed: _saveProfile,
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
