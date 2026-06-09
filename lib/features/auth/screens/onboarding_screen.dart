import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../widgets/auth_layout.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      image: AssetPaths.onboarding1,
      title: 'Easy Doctor Booking',
      description: 'Find clinics. Book fast. No waiting.',
      color: AppColors.primary,
    ),
    OnboardingPageData(
      image: AssetPaths.onboarding2,
      title: 'Smart Clinic App',
      description: 'Real appointments. Real doctors. Real easy.',
      color: AppColors.primary,
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(StorageKeys.isFirstTime, false);
    if (!mounted) return;
    context.go(AppRoutes.login);
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      topRight: TextButton(
        onPressed: _finishOnboarding,
        child: Text(
          'skip',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 30),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                final page = _pages[index];
                return Column(
                  children: [
                    const SizedBox(height: 44),
                    Expanded(
                      child: Center(
                        child: Container(
                          width: 290,
                          height: 290,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Center(
                            child: Image.asset(
                              page.image,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 34),
                    Text(page.title, style: AppTextStyles.heading2, textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        page.description,
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _DotsIndicator(count: _pages.length, index: _currentPage),
                    const SizedBox(height: 22),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Row(
              children: [
                if (_currentPage > 0)
                  Expanded(
                    child: AppButton(
                      text: 'Back',
                      isOutlined: true,
                      onPressed: _previousPage,
                    ),
                  )
                else
                  const Spacer(),
                if (_currentPage > 0) const SizedBox(width: 14),
                Expanded(
                  child: AppButton(
                    text: _currentPage == 0
                        ? 'Continue'
                        : (_currentPage == _pages.length - 1 ? 'Get Started' : 'Next'),
                    onPressed: _nextPage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPageData {
  final String image;
  final String title;
  final String description;
  final Color color;

  OnboardingPageData({
    required this.image,
    required this.title,
    required this.description,
    required this.color,
  });
}

class _DotsIndicator extends StatelessWidget {
  final int count;
  final int index;

  const _DotsIndicator({required this.count, required this.index});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final selected = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.border,
            borderRadius: BorderRadius.circular(6),
          ),
        );
      }),
    );
  }
}
