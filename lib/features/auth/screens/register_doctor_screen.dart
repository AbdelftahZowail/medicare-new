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

  final _specializations = AppConstants.specializations;

  String? _licenseFilePath;
  String? _licenseFileUrl;
  bool _isUploading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
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
                      DashedUploadPlaceholder(
                        title: 'Upload doctor license',
                        subtitle: 'Tap to upload',
                        fileName: _licenseFilePath != null
                            ? File(_licenseFilePath!).path.split(Platform.pathSeparator).last
                            : null,
                        isLoading: _isUploading,
                        onTap: _pickAndUploadLicense,
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
