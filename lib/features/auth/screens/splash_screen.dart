import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );

    _controller.forward();

    Timer(const Duration(milliseconds: 1700), _checkAuthState);
  }

  Future<void> _checkAuthState() async {
    if (!mounted || _navigated) return;
    _navigated = true;

    final authService = AuthService();
    final isLoggedIn = await authService.isLoggedIn();
    final isFirstTime = await _isFirstTime();

    if (!mounted) return;

    if (isLoggedIn) {
      final role = await authService.getUserRole();
      switch (role) {
        case 'Patient':
          context.go(AppRoutes.patientHome);
          break;
        case 'Doctor':
          context.go(AppRoutes.doctorDashboard);
          break;
        case 'ClinicAdmin':
          context.go(AppRoutes.clinicDashboard);
          break;
        default:
          context.go(AppRoutes.login);
      }
    } else if (isFirstTime) {
      context.go(AppRoutes.onboarding);
    } else {
      context.go(AppRoutes.login);
    }
  }

  Future<bool> _isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(StorageKeys.isFirstTime) ?? true;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: Image.asset(
                  AssetPaths.logo,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) {
                    return Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.primary50,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: AppColors.primary100),
                      ),
                      child: const Icon(
                        Icons.local_hospital,
                        size: 56,
                        color: AppColors.primary,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Medicare',
                style: AppTextStyles.displayMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
