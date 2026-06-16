import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/api_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/error_utils.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../doctor/services/doctor_service.dart';

class EditDoctorProfileScreen extends StatefulWidget {
  const EditDoctorProfileScreen({super.key});

  @override
  State<EditDoctorProfileScreen> createState() => _EditDoctorProfileScreenState();
}

class _EditDoctorProfileScreenState extends State<EditDoctorProfileScreen> {
  final _service = DoctorService();
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _specializationController = TextEditingController();
  final _subSpecialtyController = TextEditingController();
  final _experienceController = TextEditingController();
  final _feeController = TextEditingController();
  final _bioController = TextEditingController();
  final _degreeController = TextEditingController();
  final _universityController = TextEditingController();
  final _graduationYearController = TextEditingController();
  final _boardCertController = TextEditingController();
  final _languagesController = TextEditingController();

  bool _isLoading = false;
  bool _isSaving = false;
  bool _isUploading = false;
  String? _profileImageUrl;

  final List<String> _specializations = AppConstants.specializations;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final profile = await _service.getProfile();
      _nameController.text = profile.fullName;
      _phoneController.text = profile.phoneNumber;
      _emailController.text = profile.email ?? '';
      _specializationController.text = profile.specialization;
      _subSpecialtyController.text = profile.subSpecialty ?? '';
      _experienceController.text = profile.yearsOfExperience?.toString() ?? '';
      _feeController.text = profile.consultationFee.toString();
      _bioController.text = profile.bio ?? '';
      _degreeController.text = profile.degree ?? '';
      _universityController.text = profile.university ?? '';
      _graduationYearController.text = profile.graduationYear?.toString() ?? '';
      _boardCertController.text = profile.boardCertification ?? '';
      _languagesController.text = profile.languages.join(', ');
      _profileImageUrl = profile.profileImageUrl;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(kEnableDebugTools
                ? 'Failed to load profile: ${errorMessage(e)}'
                : 'Failed to load profile. Please try again.'),
          ),
        );
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final data = {
      'fullName': _nameController.text,
      'phoneNumber': _phoneController.text,
      'email': _emailController.text.isEmpty ? null : _emailController.text,
      'specialization': _specializationController.text,
      'subSpecialty': _subSpecialtyController.text.isEmpty ? null : _subSpecialtyController.text,
      'yearsOfExperience': int.tryParse(_experienceController.text),
      'consultationFee': double.tryParse(_feeController.text),
      'bio': _bioController.text.isEmpty ? null : _bioController.text,
      'degree': _degreeController.text.isEmpty ? null : _degreeController.text,
      'university': _universityController.text.isEmpty ? null : _universityController.text,
      'graduationYear': int.tryParse(_graduationYearController.text),
      'boardCertification': _boardCertController.text.isEmpty ? null : _boardCertController.text,
      'languages': _languagesController.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
      'profileImageUrl': _profileImageUrl,
    };

    try {
      await _service.updateProfile(data);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(kEnableDebugTools
                ? 'Failed to update profile: ${errorMessage(e)}'
                : 'Failed to update profile. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
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
          SnackBar(
            content: Text(kEnableDebugTools
                ? 'Upload error: ${errorMessage(e)}'
                : 'Upload failed. Please try again.'),
          ),
        );
      }
    }
  }

  void _showSpecializationPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Select Specialization', style: AppTextStyles.heading2),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: _specializations.length,
                itemBuilder: (context, index) {
                  final spec = _specializations[index];
                  return ListTile(
                    title: Text(spec, style: AppTextStyles.bodyLarge),
                    trailing: _specializationController.text == spec
                        ? const Icon(Icons.check, color: AppColors.primary)
                        : null,
                    onTap: () {
                      setState(() => _specializationController.text = spec);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _specializationController.dispose();
    _subSpecialtyController.dispose();
    _experienceController.dispose();
    _feeController.dispose();
    _bioController.dispose();
    _degreeController.dispose();
    _universityController.dispose();
    _graduationYearController.dispose();
    _boardCertController.dispose();
    _languagesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: GestureDetector(
                          onTap: _isUploading ? null : _pickAndUploadPhoto,
                          child: Stack(
                            children: [
                              Container(
                                height: 100,
                                width: 100,
                                decoration: BoxDecoration(
                                  color: AppColors.primary50,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.primary200, width: 2),
                                ),
                                child: _profileImageUrl != null
                                    ? ClipOval(
                                        child: Image.network(
                                          _profileImageUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => const Icon(
                                            Icons.person,
                                            size: 40,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      )
                                    : const Icon(Icons.person, size: 40, color: AppColors.primary),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  height: 32,
                                  width: 32,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: _isUploading
                                      ? const Center(child: CircularProgressIndicator(color: AppColors.textOnPrimary, strokeWidth: 2))
                                      : const Icon(
                                          Icons.camera_alt,
                                          color: AppColors.textOnPrimary,
                                          size: 16,
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Credentials',
                        style: AppTextStyles.heading4.copyWith(color: AppColors.primaryDark),
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        label: 'Full Name',
                        controller: _nameController,
                        validator: (v) => v?.isEmpty == true ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        label: 'Degree',
                        controller: _degreeController,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        label: 'University',
                        controller: _universityController,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        label: 'Experience (Years)',
                        controller: _experienceController,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        label: 'Graduation Year',
                        controller: _graduationYearController,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        label: 'Board Certification',
                        controller: _boardCertController,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Specialization',
                        style: AppTextStyles.heading4.copyWith(color: AppColors.primaryDark),
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        label: 'Specialization',
                        controller: _specializationController,
                        readOnly: true,
                        onTap: _showSpecializationPicker,
                        suffixIcon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        label: 'Sub-Specialty',
                        controller: _subSpecialtyController,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Contact Info',
                        style: AppTextStyles.heading4.copyWith(color: AppColors.primaryDark),
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        label: 'Phone Number',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        label: 'Email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Professional',
                        style: AppTextStyles.heading4.copyWith(color: AppColors.primaryDark),
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        label: 'Consultation Fee',
                        controller: _feeController,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        label: 'Languages (comma separated)',
                        controller: _languagesController,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        label: 'Professional Bio',
                        hint: 'Write your professional biography here...',
                        controller: _bioController,
                        maxLines: 5,
                      ),
                      const SizedBox(height: 24),
                      AppButton(
                        text: 'Save Changes',
                        isLoading: _isSaving,
                        onPressed: _saveProfile,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
