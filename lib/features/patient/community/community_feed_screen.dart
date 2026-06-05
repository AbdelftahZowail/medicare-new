import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/models/community_models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/error_utils.dart';
import '../../../core/widgets/app_button.dart';
import '../services/patient_community_service.dart';

class CommunityFeedScreen extends StatefulWidget {
  const CommunityFeedScreen({super.key});

  @override
  State<CommunityFeedScreen> createState() => _CommunityFeedScreenState();
}

class _CommunityFeedScreenState extends State<CommunityFeedScreen> {
  final _service = PatientCommunityService();
  final _searchController = TextEditingController();
  Timer? _debounce;

  bool _loading = true;
  List<CommunityPost> _posts = [];
  String? _selectedSpecialization;

  final List<String> _specializations = [
    'All',
    ...AppConstants.specializations,
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (mounted) setState(() {});
    });
    _loadPosts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _loadPosts();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _loadPosts();
  }

  Future<void> _deletePost(CommunityPost post) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await _service.deletePost(post.id);
      if (!mounted) return;
      setState(() => _posts.removeWhere((p) => p.id == post.id));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post deleted')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete post: ${errorMessage(e)}')),
      );
    }
  }

  Future<void> _loadPosts() async {
    setState(() => _loading = true);
    try {
      final spec = _selectedSpecialization == 'All' ? null : _selectedSpecialization;
      final posts = await _service.getPosts(specialization: spec);
      if (!mounted) return;
      setState(() {
        _posts = posts;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _posts = [];
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load posts: ${errorMessage(e)}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Community'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
            onPressed: () => context.push(AppRoutes.patientCreatePost),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onChanged: _onSearchChanged,
                onSubmitted: (_) => _loadPosts(),
                decoration: InputDecoration(
                  hintText: 'Search posts...',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
                  prefixIcon: const Icon(Icons.search, color: AppColors.textTertiary),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: _clearSearch,
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                ),
              ),
            ),
          ),

          // Specialization Chips
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              itemCount: _specializations.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final spec = _specializations[index];
                final isSelected = _selectedSpecialization == spec ||
                    (spec == 'All' && _selectedSpecialization == null);
                return ChoiceChip(
                  label: Text(spec),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() => _selectedSpecialization = spec == 'All' ? null : spec);
                    _loadPosts();
                  },
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  labelStyle: AppTextStyles.labelMedium.copyWith(
                    color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.border,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Posts List
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadPosts,
                    child: _posts.isEmpty
                        ? _EmptyState(onRefresh: _loadPosts)
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            itemCount: _posts.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final post = _posts[index];
                              return _PostCard(
                                post: post,
                                onTap: () => context.push('${AppRoutes.patientPostDetail}/${post.id}'),
                                onDelete: () => _deletePost(post),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.patientCreatePost),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final CommunityPost post;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const _PostCard({required this.post, this.onTap, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary100,
                  backgroundImage: AssetImage(
                    [
                      AssetPaths.familyMember1,
                      AssetPaths.familyMember2,
                      AssetPaths.familyMember3,
                    ][(post.id - 1) % 3],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName,
                        style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            post.authorRoleText,
                            style: AppTextStyles.bodySmall,
                          ),
                          if (post.authorSpecialization != null) ...[
                            const SizedBox(width: 6),
                            Container(
                              height: 4,
                              width: 4,
                              decoration: const BoxDecoration(
                                color: AppColors.textTertiary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              post.authorSpecialization!,
                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  _timeAgo(post.createdAt),
                  style: AppTextStyles.caption,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              post.content,
              style: AppTextStyles.bodyMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (post.specialization != null) ...[
              const SizedBox(height: 12),
              Chip(
                label: Text(post.specialization!),
                backgroundColor: AppColors.primary50,
                labelStyle: AppTextStyles.labelSmall.copyWith(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: AppColors.primary200),
                ),
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.chat_bubble_outline, size: 18, color: AppColors.textTertiary),
                const SizedBox(width: 6),
                Text(
                  '${post.commentsCount} comments',
                  style: AppTextStyles.bodySmall,
                ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.textTertiary),
                    tooltip: 'Delete post',
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    onPressed: onDelete,
                  ),
                IconButton(
                  icon: const Icon(Icons.ios_share, size: 18, color: AppColors.textTertiary),
                  tooltip: 'Share post',
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: () {
                    final box = context.findRenderObject() as RenderBox?;
                    _sharePost(post, box);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sharePost(CommunityPost post, RenderBox? box) async {
    final lines = <String>[
      '${post.authorName} shared in Medicare Community:',
      '',
      post.content,
    ];
    if (post.specialization != null && post.specialization!.isNotEmpty) {
      lines.add('');
      lines.add('#${post.specialization}');
    }
    final text = lines.join('\n');
    await Share.share(
      text,
      subject: 'Medicare Community post',
      sharePositionOrigin:
          box != null ? box.localToGlobal(Offset.zero) & box.size : null,
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onRefresh;
  const _EmptyState({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 0, 32, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                AssetPaths.emptyCommunity,
                height: 120,
                width: 120,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No posts yet',
              style: AppTextStyles.heading3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to share your thoughts with the community.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            AppButton(
              text: 'Create Post',
              isSmall: true,
              onPressed: () => context.push(AppRoutes.patientCreatePost),
            ),
          ],
        ),
      ),
    );
  }
}

