import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/bloc/auth_bloc.dart';
import '../../../core/utils/error_utils.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/auth_models.dart';
import '../../../core/services/api_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../widgets/auth_layout.dart';
import '../widgets/dashed_upload.dart';

class RegisterDoctorScreen extends StatefulWidget {
  const RegisterDoctorScreen({super.key});

  @override
  State<RegisterDoctorScreen> createState() => _RegisterDoctorScreenState();
}

class _RegisterDoctorScreenState extends State<RegisterDoctorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  String? _specialization;
  bool _obscure = true;
  bool _obscure2 = true;

  // New optional fields
  String? _gender;
  DateTime? _dateOfBirth;
  final _dateOfBirthController = TextEditingController();
  String? _profileImageUrl;
  bool _isUploadingPhoto = false;
  final _subSpecialtyController = TextEditingController();
  final _experienceController = TextEditingController();
  final _degreeController = TextEditingController();
  final _universityController = TextEditingController();
  final _graduationYearController = TextEditingController();
  final _boardCertController = TextEditingController();
  final _languagesController = TextEditingController();
  final _bioController = TextEditingController();

  final _specializations = AppConstants.specializations;

  String? _licenseFilePath;
  String? _licenseFileUrl;
  bool _isUploading = false;

  // ── Debug auto-fill ──
  int _debugPreset = 0;
  static const _debugPresets = [
    {'name': 'Dr. Ahmed Hassan', 'phone': '01012345678', 'email': 'ahmed.hassan@test.com', 'gender': 'Male', 'dob': '1985-03-12', 'specialization': 'Cardiology', 'sub': 'Interventional Cardiology', 'exp': '12', 'degree': 'M.D.', 'university': 'Cairo University', 'grad': '2010', 'board': 'Egyptian Board', 'lang': 'Arabic, English', 'bio': 'Senior consultant with over 12 years of experience in cardiovascular medicine.'},
    {'name': 'Dr. Sara Mohamed', 'phone': '01198765432', 'email': 'sara.mohamed@test.com', 'gender': 'Female', 'dob': '1990-07-25', 'specialization': 'Dermatology', 'sub': 'Cosmetic Dermatology', 'exp': '8', 'degree': 'M.Sc.', 'university': 'Ain Shams University', 'grad': '2014', 'board': 'Arab Board', 'lang': 'Arabic, English, French', 'bio': 'Specialized in cosmetic and medical dermatology with a focus on laser treatments.'},
    {'name': 'Dr. Omar Khaled', 'phone': '01234567890', 'email': 'omar.khaled@test.com', 'gender': 'Male', 'dob': '1978-11-03', 'specialization': 'Orthopedics', 'sub': 'Sports Medicine', 'exp': '15', 'degree': 'Ph.D.', 'university': 'Alexandria University', 'grad': '2007', 'board': 'Egyptian Board', 'lang': 'Arabic, English', 'bio': 'Expert in sports injuries and joint replacement surgery.'},
    {'name': 'Dr. Laila Nabil', 'phone': '01011112222', 'email': 'laila.nabil@test.com', 'gender': 'Female', 'dob': '1993-01-18', 'specialization': 'Pediatrics', 'sub': 'Neonatology', 'exp': '5', 'degree': 'M.B.B.Ch.', 'university': 'Mansoura University', 'grad': '2017', 'board': 'Egyptian Board', 'lang': 'Arabic', 'bio': 'Dedicated pediatrician with special interest in newborn care and development.'},
  ];

  void _fillDebugFields() {
    final p = _debugPresets[_debugPreset % _debugPresets.length];
    _debugPreset++;
    setState(() {
      _nameController.text = p['name'] as String;
      _phoneController.text = p['phone'] as String;
      _emailController.text = p['email'] as String;
      _gender = p['gender'] as String;
      _dateOfBirth = DateTime.tryParse(p['dob'] as String);
      _dateOfBirthController.text = p['dob'] as String;
      _specialization = p['specialization'] as String;
      _subSpecialtyController.text = p['sub'] as String;
      _experienceController.text = p['exp'] as String;
      _degreeController.text = p['degree'] as String;
      _universityController.text = p['university'] as String;
      _graduationYearController.text = p['grad'] as String;
      _boardCertController.text = p['board'] as String;
      _languagesController.text = p['lang'] as String;
      _bioController.text = p['bio'] as String;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _dateOfBirthController.dispose();
    _subSpecialtyController.dispose();
    _experienceController.dispose();
    _degreeController.dispose();
    _universityController.dispose();
    _graduationYearController.dispose();
    _boardCertController.dispose();
    _languagesController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_licenseFileUrl == null || _licenseFileUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload your doctor license')),
      );
      return;
    }

    context.read<AuthBloc>().add(
          AuthRegisterDoctorRequested(
            RegisterDoctorRequest(
              name: _nameController.text.trim(),
              phone: _phoneController.text.trim(),
              email: _emailController.text.trim().isNotEmpty
                  ? _emailController.text.trim()
                  : null,
              password: _passwordController.text,
              confirmPassword: _confirmController.text,
              specialization: _specialization ?? '',
              licenseFileUrl: _licenseFileUrl!,
              gender: _gender != null ? (_gender == 'Male' ? 1 : 2) : null,
              dateOfBirth: _dateOfBirth,
              profileImageUrl: _profileImageUrl,
              subSpecialty: _subSpecialtyController.text.trim().isNotEmpty
                  ? _subSpecialtyController.text.trim()
                  : null,
              yearsOfExperience: int.tryParse(_experienceController.text.trim()),
              degree: _degreeController.text.trim().isNotEmpty
                  ? _degreeController.text.trim()
                  : null,
              university: _universityController.text.trim().isNotEmpty
                  ? _universityController.text.trim()
                  : null,
              graduationYear: int.tryParse(_graduationYearController.text.trim()),
              boardCertification: _boardCertController.text.trim().isNotEmpty
                  ? _boardCertController.text.trim()
                  : null,
              languages: _languagesController.text.trim().isNotEmpty
                  ? _languagesController.text.trim()
                  : null,
              bio: _bioController.text.trim().isNotEmpty
                  ? _bioController.text.trim()
                  : null,
            ),
          ),
        );
  }

  Future<void> _pickAndUploadLicense() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

      setState(() {
        _licenseFilePath = pickedFile.path;
        _isUploading = true;
      });

      final response = await ApiService().uploadFile(
        ApiEndpoints.uploadLicense,
        filePath: pickedFile.path,
        fieldName: 'file',
      );

      if (response.isSuccess && response.data != null) {
        final url = response.data!['url'] as String?;
        if (url != null && url.isNotEmpty) {
          setState(() {
            _licenseFileUrl = url;
            _isUploading = false;
          });
          return;
        }
      }

      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message.isNotEmpty ? response.message : 'Failed to upload license')),
        );
      }
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(kEnableDebugTools
                ? 'Upload error: ${errorMessage(e)}'
                : 'Failed to upload license. Please try again.'),
          ),
        );
      }
    }
  }

  Future<void> _pickAndUploadPhoto() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

      setState(() => _isUploadingPhoto = true);

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
            _isUploadingPhoto = false;
          });
          return;
        }
      }

      setState(() => _isUploadingPhoto = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message.isNotEmpty ? response.message : 'Failed to upload photo')),
        );
      }
    } catch (e) {
      setState(() => _isUploadingPhoto = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(kEnableDebugTools
                ? 'Upload error: ${errorMessage(e)}'
                : 'Failed to upload photo. Please try again.'),
          ),
        );
      }
    }
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? now.subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _dateOfBirth = picked;
        _dateOfBirthController.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      floatingActionButton: kEnableDebugTools
          ? FloatingActionButton.small(
              heroTag: 'fill_doctor',
              onPressed: _fillDebugFields,
              child: const Icon(Icons.auto_fix_high),
            )
          : null,
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (p, c) => c is AuthFailure,
        listener: (context, state) {
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Padding(
            padding: const EdgeInsets.only(top: 18, bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.textPrimary),
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(height: 6),
                Text('Sign Up', style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary)),
                const SizedBox(height: 14),
                Text('Create Account For Doctor', style: AppTextStyles.heading2),
                const SizedBox(height: 6),
                Text(
                  'Please enter your information and create your account',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 18),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // ── Profile Photo ──
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Profile Photo', style: AppTextStyles.labelLarge),
                          const SizedBox(height: 8),
                          Center(
                            child: GestureDetector(
                              onTap: _isUploadingPhoto ? null : _pickAndUploadPhoto,
                              child: Stack(
                                children: [
                                  Container(
                                    height: 90,
                                    width: 90,
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
                                      height: 30,
                                      width: 30,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: _isUploadingPhoto
                                          ? const Center(child: CircularProgressIndicator(color: AppColors.textOnPrimary, strokeWidth: 2))
                                          : const Icon(
                                              Icons.camera_alt,
                                              color: AppColors.textOnPrimary,
                                              size: 14,
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Name',
                        hint: 'Enter Your Name',
                        controller: _nameController,
                        textInputAction: TextInputAction.next,
                        validator: (v) {
                          final value = (v ?? '').trim();
                          if (value.isEmpty) return 'Name is required';
                          if (value.length < 2) return 'Enter a valid name';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Phone',
                        hint: 'Enter Your Phone number',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        validator: (v) {
                          final value = (v ?? '').trim();
                          if (value.isEmpty) return 'Phone is required';
                          if (value.length < 8) return 'Enter a valid phone number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Email',
                        hint: 'Enter Your Email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 14),
                      // Gender
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Gender', style: AppTextStyles.labelLarge),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 12,
                            children: ['Male', 'Female'].map((g) => ChoiceChip(
                              label: Text(g),
                              selected: _gender == g,
                              onSelected: (sel) => setState(() => _gender = sel ? g : null),
                              selectedColor: AppColors.primary100,
                              labelStyle: TextStyle(
                                color: _gender == g ? AppColors.primary : AppColors.textSecondary,
                              ),
                            )).toList(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Date of Birth
                      AppTextField(
                        label: 'Date of Birth',
                        hint: 'Select date of birth',
                        controller: _dateOfBirthController,
                        readOnly: true,
                        onTap: _pickDateOfBirth,
                        suffixIcon: const Icon(Icons.calendar_today, size: 18, color: AppColors.textTertiary),
                      ),
                      const SizedBox(height: 20),
                      // ── Professional Details ──
                      Text('Professional Details', style: AppTextStyles.heading4.copyWith(color: AppColors.primaryDark)),
                      const SizedBox(height: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Specializations', style: AppTextStyles.labelLarge),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _specialization,
                            items: _specializations
                                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                .toList(),
                            onChanged: (v) => setState(() => _specialization = v),
                            validator: (v) => (v == null || v.isEmpty) ? 'Specialization is required' : null,
                            decoration: const InputDecoration(
                              hintText: 'Select Specializations',
                            ),
                            icon: const Icon(Icons.keyboard_arrow_down_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Sub-Specialty',
                        hint: 'Enter sub-specialty',
                        controller: _subSpecialtyController,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Years of Experience',
                        hint: 'Enter years of experience',
                        controller: _experienceController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Degree',
                        hint: 'Enter your degree',
                        controller: _degreeController,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'University',
                        hint: 'Enter university name',
                        controller: _universityController,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Graduation Year',
                        hint: 'Enter graduation year',
                        controller: _graduationYearController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Board Certification',
                        hint: 'Enter board certification',
                        controller: _boardCertController,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Languages',
                        hint: 'Arabic, English',
                        controller: _languagesController,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Professional Bio',
                        hint: 'Write your professional biography here...',
                        controller: _bioController,
                        maxLines: 5,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                      ),
                      const SizedBox(height: 20),
                      DashedUploadPlaceholder(
                        title: 'Upload doctor license',
                        subtitle: 'Tap to upload',
                        fileName: _licenseFilePath != null
                            ? File(_licenseFilePath!).path.split(Platform.pathSeparator).last
                            : null,
                        isLoading: _isUploading,
                        onTap: _pickAndUploadLicense,
                      ),
                      const SizedBox(height: 20),
                      // ── Account Security ──
                      Text('Account Security', style: AppTextStyles.heading4.copyWith(color: AppColors.primaryDark)),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Password',
                        hint: 'Enter Your Password',
                        controller: _passwordController,
                        obscureText: _obscure,
                        textInputAction: TextInputAction.next,
                        validator: (v) {
                          final value = (v ?? '');
                          if (value.isEmpty) return 'Password is required';
                          if (value.length < 6) return 'Password must be at least 6 characters';
                          return null;
                        },
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _obscure = !_obscure),
                          icon: Icon(
                            _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Confirm Password',
                        hint: 'Confirm Your Password',
                        controller: _confirmController,
                        obscureText: _obscure2,
                        textInputAction: TextInputAction.next,
                        validator: (v) {
                          final value = (v ?? '');
                          if (value.isEmpty) return 'Confirm password is required';
                          if (value != _passwordController.text) return 'Passwords do not match';
                          return null;
                        },
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _obscure2 = !_obscure2),
                          icon: Icon(
                            _obscure2 ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          final loading = state is AuthLoading;
                          return AppButton(
                            text: 'Sign Up',
                            isLoading: loading,
                            onPressed: loading ? null : _submit,
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Have an account? ', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                          GestureDetector(
                            onTap: () => context.go(AppRoutes.login),
                            child: Text('Login', style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
