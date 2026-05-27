import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';

class SubmitReviewScreen extends StatefulWidget {
  final int doctorId;
  final int appointmentId;

  const SubmitReviewScreen({
    super.key,
    required this.doctorId,
    required this.appointmentId,
  });

  @override
  State<SubmitReviewScreen> createState() => _SubmitReviewScreenState();
}

class _SubmitReviewScreenState extends State<SubmitReviewScreen> {
  final _commentController = TextEditingController();

  bool _submitting = false;
  int _rating = 0;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rating')),
      );
      return;
    }

    setState(() => _submitting = true);

    // In a real app, this would call the reviews API
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Review submitted successfully')),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Submit Review'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'How was your experience?',
                style: AppTextStyles.heading2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Rate your doctor and share your feedback',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),

              // Star Rating
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starIndex = index + 1;
                  return GestureDetector(
                    onTap: () => setState(() => _rating = starIndex),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
                      child: Icon(
                        starIndex <= _rating ? Icons.star : Icons.star_border,
                        color: AppColors.warning,
                        size: 40,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),
              Text(
                _rating > 0 ? _ratingText : 'Tap a star to rate',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: _rating > 0 ? AppColors.textPrimary : AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 28),

              // Comment Text Area
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text('Your Review (Optional)', style: AppTextStyles.labelLarge),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  controller: _commentController,
                  maxLines: 5,
                  maxLength: 300,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: 'Share your experience with the doctor...',
                    hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    counterStyle: AppTextStyles.caption,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              AppButton(
                text: 'Submit Review',
                isLoading: _submitting,
                onPressed: _submitReview,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _ratingText {
    switch (_rating) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent';
      default:
        return '';
    }
  }
}
