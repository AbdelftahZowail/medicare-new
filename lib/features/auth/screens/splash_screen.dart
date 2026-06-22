import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    if (!mounted || _navigated) return;
    _navigated = true;

    final authService = AuthService();
    final isLoggedIn = await authService.isLoggedIn();
    final isFirstTime = await _isFirstTime();

    FlutterNativeSplash.remove();

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
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: SizedBox.shrink(),
    );
  }
}
