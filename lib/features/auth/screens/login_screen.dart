import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/bloc/auth_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/auth_models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../widgets/auth_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  String _appVersion = '';
  String? _backendVersion;

  @override
  void initState() {
    super.initState();
    _loadVersions();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadVersions() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() => _appVersion = 'v${packageInfo.version}');

    if (kEnableDebugTools) {
      try {
        final response = await Dio().get(ApiEndpoints.version);
        final data = response.data as Map<String, dynamic>;
        if (data['isSuccess'] == true && data['data'] != null) {
          setState(() => _backendVersion = data['data']['version'] as String?);
        }
      } catch (_) {}
    }
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    context.read<AuthBloc>().add(
          AuthLoginRequested(
            LoginRequest(
              phone: _phoneController.text.trim(),
              password: _passwordController.text,
            ),
          ),
        );
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
                const SizedBox(height: 10),
                Text('Login', style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary)),
                const SizedBox(height: 14),
                Text('Welcome Back', style: AppTextStyles.heading1),
                const SizedBox(height: 6),
                Text(
                  'Please enter your phone number and password for login',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, height: 1.35),
                ),
                const SizedBox(height: 18),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
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
                        label: 'Password',
                        hint: 'Enter Your Password',
                        controller: _passwordController,
                        obscureText: _obscure,
                        textInputAction: TextInputAction.done,
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
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => context.push(AppRoutes.forgotPassword),
                          child: Text(
                            'Forgot Password?',
                            style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          final loading = state is AuthLoading;
                          return AppButton(
                            text: 'login',
                            isLoading: loading,
                            onPressed: loading ? null : _submit,
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Create Account? ', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                          GestureDetector(
                            onTap: () => context.push(AppRoutes.roleSelection),
                            child: Text('Sign Up', style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_backendVersion != null) ...[
                      Text(
                        _appVersion,
                        style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Backend: v$_backendVersion',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}