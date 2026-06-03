import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/models/community_models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../services/patient_community_service.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _service = PatientCommunityService();
  final _contentController = TextEditingController();

  bool _posting = false;
  String? _selectedSpecialization;

  final List<String> _specializations = AppConstants.specializations;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _createPost() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write something')),
      );
      return;
    }

    setState(() => _posting = true);

    final request = CreatePostRequest(
      content: _contentController.text.trim(),
      specialization: _selectedSpecialization,
    );

    try {
      await _service.createPost(request);
      if (!mounted) return;
      context.pop();
    } catch (e) {
      if (!mounted) return;
      context.pop();
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create Post'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('What would you like to share?', style: AppTextStyles.heading3),
              const SizedBox(height: 16),

              // Content Text Area
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  controller: _contentController,
                  maxLines: 8,
                  maxLength: 500,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: 'Write your post here...',
                    hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    counterStyle: AppTextStyles.caption,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Specialization Dropdown
              Text('Specialization (Optional)', style: AppTextStyles.labelLarge),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedSpecialization,
                    hint: Text('Select specialization', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary)),
                    icon: const Icon(Icons.arrow_drop_down, color: AppColors.textTertiary),
                    items: _specializations.map((spec) {
                      return DropdownMenuItem(
                        value: spec,
                        child: Text(spec, style: AppTextStyles.bodyMedium),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _selectedSpecialization = v),
                  ),
                ),
              ),
              const Spacer(),
              const SizedBox(height: 16),

              AppButton(
                text: 'Post',
                isLoading: _posting,
                onPressed: _createPost,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
