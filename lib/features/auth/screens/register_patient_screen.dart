import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/bloc/auth_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/auth_models.dart';
import '../../../core/services/api_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/error_utils.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../widgets/auth_layout.dart';

class RegisterPatientScreen extends StatefulWidget {
  const RegisterPatientScreen({super.key});

  @override
  State<RegisterPatientScreen> createState() => _RegisterPatientScreenState();
}

class _RegisterPatientScreenState extends State<RegisterPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _bloodTypeController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _chronicDiseasesController = TextEditingController();
  bool _obscure = true;
  bool _obscure2 = true;
  int? _selectedGender;
  DateTime? _dateOfBirth;
  String? _profileImageUrl;
  bool _isUploading = false;

  // ── Debug auto-fill ──
  int _debugPreset = 0;
  static const _debugPresets = [
    {'name': 'Ahmed Ali', 'phone': '01067179861', 'age': '28', 'email': 'ahmed@test.com', 'gender': 0, 'dob': '1998-05-15', 'address': '15 Tahrir St, Maadi', 'blood': 'B+', 'allergies': 'None', 'chronic': 'None'},
    {'name': 'Mona Samir', 'phone': '01123456789', 'age': '35', 'email': 'mona@test.com', 'gender': 1, 'dob': '1991-03-22', 'address': '22 Nile St, Dokki', 'blood': 'A+', 'allergies': 'Penicillin', 'chronic': 'Asthma'},
    {'name': 'Khaled Omar', 'phone': '01098765432', 'age': '42', 'email': 'khaled@test.com', 'gender': 0, 'dob': '1984-11-08', 'address': '8 Sea Rd, Alexandria', 'blood': 'O+', 'allergies': 'Dust, Pollen', 'chronic': 'Diabetes Type 2'},
    {'name': 'Nour Hassan', 'phone': '01555666777', 'age': '22', 'email': 'nour@test.com', 'gender': 1, 'dob': '2004-07-30', 'address': '3 Port St, Port Said', 'blood': 'AB+', 'allergies': 'None', 'chronic': 'None'},
  ];

  void _fillDebugFields() {
    final p = _debugPresets[_debugPreset % _debugPresets.length];
    _debugPreset++;
    setState(() {
      _nameController.text = p['name'] as String;
      _phoneController.text = p['phone'] as String;
      _ageController.text = p['age'] as String;
      _emailController.text = p['email'] as String;
      _selectedGender = p['gender'] as int?;
      _dateOfBirth = DateTime.tryParse(p['dob'] as String);
      _addressController.text = p['address'] as String;
      _bloodTypeController.text = p['blood'] as String;
      _allergiesController.text = p['allergies'] as String;
      _chronicDiseasesController.text = p['chronic'] as String;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _bloodTypeController.dispose();
    _allergiesController.dispose();
    _chronicDiseasesController.dispose();
    super.dispose();
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
                : 'Upload error. Please try again.'),
          ),
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

  int? _computeAge(DateTime? dateOfBirth) {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    var age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final age = int.tryParse(_ageController.text.trim());

    context.read<AuthBloc>().add(
          AuthRegisterPatientRequested(
            RegisterPatientRequest(
              name: _nameController.text.trim(),
              phone: _phoneController.text.trim(),
              age: age ?? _computeAge(_dateOfBirth),
              email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
              gender: _selectedGender,
              dateOfBirth: _dateOfBirth,
              profileImageUrl: _profileImageUrl,
              address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
              bloodType: _bloodTypeController.text.trim().isEmpty ? null : _bloodTypeController.text.trim(),
              allergies: _allergiesController.text.trim().isEmpty ? null : _allergiesController.text.trim(),
              chronicDiseases: _chronicDiseasesController.text.trim().isEmpty ? null : _chronicDiseasesController.text.trim(),
              password: _passwordController.text,
              confirmPassword: _confirmController.text,
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      floatingActionButton: kEnableDebugTools
          ? FloatingActionButton.small(
              heroTag: 'fill_patient',
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
                Text('Create Account For Patient', style: AppTextStyles.heading2),
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
                      // Profile Photo
                      Center(
                        child: GestureDetector(
                          onTap: _isUploading ? null : _pickAndUploadPhoto,
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              CircleAvatar(
                                radius: 46,
                                backgroundColor: AppColors.primary100,
                                backgroundImage: _profileImageUrl != null
                                    ? NetworkImage(_profileImageUrl!)
                                    : null,
                                child: _profileImageUrl == null
                                    ? const Icon(Icons.person, size: 46, color: AppColors.primary)
                                    : null,
                              ),
                              Container(
                                height: 30,
                                width: 30,
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
                      ),
                      const SizedBox(height: 6),
                      Center(
                        child: Text(
                          'Tap to add profile photo',
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary),
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Full Name
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
                      // Phone Number
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
                      // Email
                      AppTextField(
                        label: 'Email',
                        hint: 'Enter Your Email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 14),
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
                      const SizedBox(height: 14),
                      // Age
                      AppTextField(
                        label: 'Your Age',
                        hint: 'Enter Your Age',
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        validator: (v) {
                          final value = (v ?? '').trim();
                          if (value.isEmpty) return 'Age is required';
                          final age = int.tryParse(value);
                          if (age == null || age < 1 || age > 120) return 'Enter a valid age';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      // Gender
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
                      const SizedBox(height: 20),
                      // Section: Contact & Medical Info
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text('Contact & Medical Info', style: AppTextStyles.heading4.copyWith(color: AppColors.primaryDark)),
                      ),
                      const SizedBox(height: 14),
                      // Address
                      AppTextField(
                        label: 'Address',
                        hint: 'Enter Your Address',
                        controller: _addressController,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 14),
                      // Blood Type
                      AppTextField(
                        label: 'Blood Type',
                        hint: 'Enter Your Blood Type',
                        controller: _bloodTypeController,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 14),
                      // Allergies
                      AppTextField(
                        label: 'Allergies',
                        hint: 'Enter Any Allergies',
                        controller: _allergiesController,
                        maxLines: 2,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 14),
                      // Chronic Diseases
                      AppTextField(
                        label: 'Chronic Diseases',
                        hint: 'e.g. Diabetes, Hypertension',
                        controller: _chronicDiseasesController,
                        maxLines: 2,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 20),
                      const SizedBox(height: 20),
                      // Section: Account Security
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text('Account Security', style: AppTextStyles.heading4.copyWith(color: AppColors.primaryDark)),
                      ),
                      const SizedBox(height: 14),
                      // Password
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
                      // Confirm Password
                      AppTextField(
                        label: 'Confirm Password',
                        hint: 'Confirm Your Password',
                        controller: _confirmController,
                        obscureText: _obscure2,
                        textInputAction: TextInputAction.done,
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
