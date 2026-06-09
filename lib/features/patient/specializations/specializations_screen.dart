import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../data/doctor_service.dart';

class SpecializationsScreen extends StatefulWidget {
  const SpecializationsScreen({super.key});

  @override
  State<SpecializationsScreen> createState() => _SpecializationsScreenState();
}

class _SpecializationsScreenState extends State<SpecializationsScreen> {
  final DoctorService _service = DoctorService();
  bool _loading = true;
  List<String> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await _service.getSpecializations();
    if (!mounted) return;
    setState(() {
      _items = res;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Specializations'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            final router = GoRouter.of(context);
            if (router.canPop()) {
              router.pop();
            } else {
              router.go(AppRoutes.patientHome);
            }
          },
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                itemCount: _items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final s = _items[i];
                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      context.push(
                        AppRoutes.patientBrowseDoctors,
                        extra: {'specialization': s},
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(s, style: AppTextStyles.heading4),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.textTertiary,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
