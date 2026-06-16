import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/models/auth_models.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/error_utils.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../widgets/auth_layout.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _loading = true);
    try {
      final resp = await AuthService().forgotPassword(
        ForgotPasswordRequest(phone: _phoneController.text.trim()),
      );
      if (!mounted) return;
      if (resp.isSuccess) {
        context.push(AppRoutes.verifyOtp, extra: _phoneController.text.trim());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(resp.message)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(kEnableDebugTools
              ? 'Forgot password error: ${errorMessage(e)}'
              : 'Something went wrong. Please try again.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
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
              Text('Forgot Password', style: AppTextStyles.heading2),
              const SizedBox(height: 6),
              Text(
                'Please enter your Phone — we will send you a code to reset your password.',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
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
                      textInputAction: TextInputAction.done,
                      validator: (v) {
                        final value = (v ?? '').trim();
                        if (value.isEmpty) return 'Phone is required';
                        if (value.length < 8) return 'Enter a valid phone number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    AppButton(
                      text: 'Get OTP',
                      isLoading: _loading,
                      onPressed: _loading ? null : _submit,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
