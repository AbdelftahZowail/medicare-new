import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/models/shared_models.dart';
import '../../../core/services/patient_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/error_utils.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';

class AddFamilyMemberScreen extends StatefulWidget {
  final FamilyMember? existingMember;

  const AddFamilyMemberScreen({super.key, this.existingMember});

  @override
  State<AddFamilyMemberScreen> createState() => _AddFamilyMemberScreenState();
}

class _AddFamilyMemberScreenState extends State<AddFamilyMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _bloodTypeController = TextEditingController();
  final _medicalHistoryController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _chronicDiseasesController = TextEditingController();

  bool _saving = false;
  int? _selectedRelation;
  int? _selectedGender;

  bool get _isEditing => widget.existingMember != null;

  final List<Map<String, dynamic>> _relations = [
    {'value': AppEnums.parent, 'label': 'Parent'},
    {'value': AppEnums.child, 'label': 'Child'},
    {'value': AppEnums.spouse, 'label': 'Spouse'},
    {'value': AppEnums.sibling, 'label': 'Sibling'},
    {'value': AppEnums.other, 'label': 'Other'},
  ];

  @override
  void initState() {
    super.initState();
    final member = widget.existingMember;
    if (member != null) {
      _nameController.text = member.name;
      _ageController.text = member.age?.toString() ?? '';
      _bloodTypeController.text = member.bloodType ?? '';
      _medicalHistoryController.text = member.medicalHistory ?? '';
      _allergiesController.text = member.allergies ?? '';
      _chronicDiseasesController.text = member.chronicDiseases ?? '';
      _selectedRelation = member.relation;
      _selectedGender = member.gender;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _bloodTypeController.dispose();
    _medicalHistoryController.dispose();
    _allergiesController.dispose();
    _chronicDiseasesController.dispose();
    super.dispose();
  }

  Future<void> _saveMember() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRelation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a relation')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final member = FamilyMember(
        id: widget.existingMember?.id ?? 0,
        patientId: widget.existingMember?.patientId ?? 0,
        name: _nameController.text.trim(),
        relation: _selectedRelation!,
        age: int.tryParse(_ageController.text.trim()),
        gender: _selectedGender,
        bloodType: _bloodTypeController.text.trim().isEmpty
            ? null
            : _bloodTypeController.text.trim(),
        medicalHistory: _medicalHistoryController.text.trim().isEmpty
            ? null
            : _medicalHistoryController.text.trim(),
        allergies: _allergiesController.text.trim().isEmpty
            ? null
            : _allergiesController.text.trim(),
        chronicDiseases: _chronicDiseasesController.text.trim().isEmpty
            ? null
            : _chronicDiseasesController.text.trim(),
      );

      final service = PatientService();
      if (_isEditing && widget.existingMember!.id > 0) {
        await service.removeFamilyMember(widget.existingMember!.id);
      }
      await service.addFamilyMember(member);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditing
            ? 'Family member updated successfully'
            : 'Family member added successfully')),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save family member: ${errorMessage(e)}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Family Member' : 'Add Family Member'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(
                  label: 'Full Name',
                  controller: _nameController,
                  validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // Relation Selection
                Text('Relation', style: AppTextStyles.labelLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _relations.map((relation) {
                    final isSelected = _selectedRelation == relation['value'];
                    return ChoiceChip(
                      label: Text(relation['label']),
                      selected: isSelected,
                      onSelected: (_) => setState(() => _selectedRelation = relation['value']),
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.surface,
                      labelStyle: AppTextStyles.labelMedium.copyWith(
                        color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : AppColors.border,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                AppTextField(
                  label: 'Age',
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),

                // Gender Selection
                Text('Gender', style: AppTextStyles.labelLarge),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Male'),
                        selected: _selectedGender == AppEnums.male,
                        onSelected: (_) => setState(() => _selectedGender = AppEnums.male),
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.surface,
                        labelStyle: AppTextStyles.labelMedium.copyWith(
                          color: _selectedGender == AppEnums.male ? AppColors.textOnPrimary : AppColors.textPrimary,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: _selectedGender == AppEnums.male ? AppColors.primary : AppColors.border,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Female'),
                        selected: _selectedGender == AppEnums.female,
                        onSelected: (_) => setState(() => _selectedGender = AppEnums.female),
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.surface,
                        labelStyle: AppTextStyles.labelMedium.copyWith(
                          color: _selectedGender == AppEnums.female ? AppColors.textOnPrimary : AppColors.textPrimary,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: _selectedGender == AppEnums.female ? AppColors.primary : AppColors.border,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                AppTextField(
                  label: 'Blood Type (Optional)',
                  controller: _bloodTypeController,
                  hint: 'e.g. O+, A-, B+',
                ),
                const SizedBox(height: 16),

                AppTextField(
                  label: 'Medical History (Optional)',
                  controller: _medicalHistoryController,
                  hint: 'e.g. Appendectomy, Fracture',
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                AppTextField(
                  label: 'Allergies (Optional)',
                  controller: _allergiesController,
                  hint: 'e.g. Penicillin, Peanuts',
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                AppTextField(
                  label: 'Chronic Diseases (Optional)',
                  controller: _chronicDiseasesController,
                  hint: 'e.g. Diabetes, Hypertension',
                  maxLines: 2,
                ),
                const SizedBox(height: 24),

                AppButton(
                  text: _isEditing ? 'Update' : 'Save',
                  isLoading: _saving,
                  onPressed: _saveMember,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
