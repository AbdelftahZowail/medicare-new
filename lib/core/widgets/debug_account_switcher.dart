import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../constants/app_constants.dart';
import '../models/auth_models.dart';
import '../theme/app_colors.dart';

/// Debug-only widget that allows quick account switching.
/// Shows 3 buttons (Patient, Doctor, Clinic) below the logout button.
/// Only visible when [kEnableDebugTools] is `true`.
class DebugAccountSwitcher extends StatelessWidget {
  const DebugAccountSwitcher({super.key});

  static const _accounts = [
    _DebugAccount(
      label: 'Patient',
      phone: '01067179861',
      password: 'password',
      icon: Icons.person,
    ),
    _DebugAccount(
      label: 'Doctor',
      phone: '01067179860',
      password: 'password',
      icon: Icons.local_hospital,
    ),
    _DebugAccount(
      label: 'Clinic',
      phone: '01067179862',
      password: 'password',
      icon: Icons.business,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (!kEnableDebugTools) return const SizedBox.shrink();

    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.warning.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.bug_report, size: 16, color: AppColors.warning),
                  const SizedBox(width: 6),
                  Text(
                    'DEBUG: Switch Account',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...List.generate(_accounts.length, (index) {
                final account = _accounts[index];
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index < _accounts.length - 1 ? 6 : 0,
                  ),
                  child: SizedBox(
                    height: 40,
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _switchAccount(context, account),
                      icon: Icon(account.icon, size: 16),
                      label: Text('${account.label} (${account.phone})'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(
                          color: AppColors.primary.withOpacity(0.5),
                        ),
                        textStyle: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _switchAccount(
    BuildContext context,
    _DebugAccount account,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Switch Account'),
        content: Text(
          'Log out and switch to ${account.label} account?\n'
          'Phone: ${account.phone}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Switch'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // Logout first, then login with new account
      context.read<AuthBloc>().add(AuthLogoutRequested());

      // Wait a bit for logout to complete, then login
      await Future.delayed(const Duration(milliseconds: 500));

      if (context.mounted) {
        context.read<AuthBloc>().add(
          AuthLoginRequested(
            LoginRequest(phone: account.phone, password: account.password),
          ),
        );
      }
    }
  }
}

class _DebugAccount {
  final String label;
  final String phone;
  final String password;
  final IconData icon;

  const _DebugAccount({
    required this.label,
    required this.phone,
    required this.password,
    required this.icon,
  });
}
