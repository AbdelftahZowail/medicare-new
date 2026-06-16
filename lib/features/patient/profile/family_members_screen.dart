import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/models/shared_models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/error_utils.dart';
import '../../../core/widgets/app_button.dart';
import '../services/patient_family_members_service.dart';

class FamilyMembersScreen extends StatefulWidget {
  const FamilyMembersScreen({super.key});

  @override
  State<FamilyMembersScreen> createState() => _FamilyMembersScreenState();
}

class _FamilyMembersScreenState extends State<FamilyMembersScreen> {
  final _service = PatientFamilyMembersService();
  bool _loading = true;
  List<FamilyMember> _members = [];

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() => _loading = true);
    try {
      final members = await _service.getFamilyMembers();
      if (!mounted) return;
      setState(() {
        _members = members;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(kEnableDebugTools
              ? 'Failed to load family members: ${errorMessage(e)}'
              : 'Failed to load family members. Please try again.'),
        ),
      );
      setState(() {
        _members = [];
        _loading = false;
      });
    }
  }

  Future<void> _deleteMember(FamilyMember member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Family Member'),
        content: Text('Are you sure you want to remove ${member.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _service.deleteFamilyMember(member.id);
      if (!mounted) return;
      _loadMembers();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _members.removeWhere((m) => m.id == member.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Family Members'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadMembers,
                child: _members.isEmpty
                    ? _EmptyState(onAdd: () => context.push(AppRoutes.patientAddFamilyMember))
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                        itemCount: _members.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final member = _members[index];
                          return _FamilyMemberCard(
                            member: member,
                            onEdit: () => context.push(
                              AppRoutes.patientAddFamilyMember,
                              extra: member,
                            ),
                            onDelete: () => _deleteMember(member),
                          );
                        },
                      ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.patientAddFamilyMember),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _FamilyMemberCard extends StatelessWidget {
  final FamilyMember member;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _FamilyMemberCard({
    required this.member,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primary100,
            child: Icon(Icons.person, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _relationText(member.relation),
                        style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (member.age != null)
                      Text(
                        '${member.age} years',
                        style: AppTextStyles.bodySmall,
                      ),
                  ],
                ),
                if (member.bloodType != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Blood Type: ${member.bloodType}',
                    style: AppTextStyles.caption,
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }

  String _relationText(int relation) {
    switch (relation) {
      case 0:
        return 'Parent';
      case 1:
        return 'Child';
      case 2:
        return 'Spouse';
      case 3:
        return 'Sibling';
      default:
        return 'Other';
    }
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 0, 32, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                color: AppColors.primary50,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.people_outline,
                size: 56,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No family members',
              style: AppTextStyles.heading3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Add your family members to book appointments for them.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            AppButton(
              text: 'Add Family Member',
              isSmall: true,
              onPressed: onAdd,
            ),
          ],
        ),
      ),
    );
  }
}
