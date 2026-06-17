import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class AuthLayout extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Widget? topRight;
  final Widget? floatingActionButton;

  const AuthLayout({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
    this.topRight,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: floatingActionButton,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: padding,
              child: child,
            ),
            if (topRight != null)
              Positioned(
                top: 8,
                right: 8,
                child: topRight!,
              ),
          ],
        ),
      ),
    );
  }
}
