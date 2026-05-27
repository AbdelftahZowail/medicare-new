import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/models/auth_models.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../widgets/auth_layout.dart';
import '../widgets/otp_input.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String phone;
  const VerifyOtpScreen({super.key, required this.phone});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  String _code = '';
  bool _loading = false;
  int _seconds = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _seconds = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_seconds <= 1) {
        t.cancel();
        setState(() => _seconds = 0);
      } else {
        setState(() => _seconds -= 1);
      }
    });
  }

  Future<void> _resend() async {
    if (_seconds > 0) return;
    try {
      await AuthService().forgotPassword(ForgotPasswordRequest(phone: widget.phone));
      if (!mounted) return;
      _startTimer();
    } catch (_) {
      // no-op
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (_code.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the 4-digit code')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final resp = await AuthService().verifyOtp(
        VerifyOtpRequest(phone: widget.phone, otpCode: _code),
      );

      if (!mounted) return;
      if (resp.isSuccess) {
        context.push(
          AppRoutes.resetPassword,
          extra: {
            'phone': widget.phone,
            'otpCode': _code,
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(resp.message)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
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
              Text('Verify with OTP sent to', style: AppTextStyles.heading2),
              const SizedBox(height: 6),
              Text(
                widget.phone,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 18),
              Center(
                child: OtpInput(
                  length: 4,
                  onChanged: (v) => setState(() => _code = v),
                  onCompleted: (v) => setState(() => _code = v),
                ),
              ),
              const SizedBox(height: 18),
              AppButton(
                text: 'Continue',
                isLoading: _loading,
                onPressed: _loading ? null : _submit,
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: _seconds == 0 ? _resend : null,
                  child: Text(
                    _seconds == 0 ? 'Resend code' : 'Resend in 00:${_seconds.toString().padLeft(2, '0')}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: _seconds == 0 ? AppColors.primary : AppColors.textTertiary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
