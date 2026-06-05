import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/app_bottom_nav.dart';

class PatientShellScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const PatientShellScreen({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppBottomNav(
        currentIndex: navigationShell.currentIndex,
        items: PatientNavItems.items,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        centerFabIndex: 2,
        centerFabIcon: Icons.smart_toy_outlined,
      ),
    );
  }
}
