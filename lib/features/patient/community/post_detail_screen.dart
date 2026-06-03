import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/models/community_models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../services/patient_community_service.dart';

class PostDetailScreen extends StatefulWidget {
  final int postId;
  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _service = PatientCommunityService();
  final _commentController = TextEditingController();

  bool _loading = true;
  bool _postingComment = false;
  CommunityPost? _post;
  List<CommunityComment> _comments = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final posts = await _service.getPosts();
      final comments = await _service.getComments(widget.postId);
      if (!mounted) return;
      setState(() {
        _post = posts.firstWhere(
          (p) => p.id == widget.postId,
          orElse: () => CommunityPost(
            id: widget.postId,
            userId: 0,
            authorName: '',
            authorRoleText: '',
            content: '',
            createdAt: DateTime.now(),
            commentsCount: 0,
            comments: [],
          ),
        );
        _comments = comments;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _post = null;
        _comments = [];
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load post: ${e.toString()}')),
      );
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    setState(() => _postingComment = true);

    final request = CreateCommentRequest(
      postId: widget.postId,
      content: _commentController.text.trim(),
    );

    try {
      final comment = await _service.addComment(request);
      if (!mounted) return;
      setState(() {
        _comments.add(comment);
        _commentController.clear();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add comment: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _postingComment = false);
    }
  }

  Future<void> _deleteComment(CommunityComment comment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Comment'),
        content: const Text('Are you sure you want to delete this comment?'),
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
      await _service.deleteComment(comment.id);
      if (!mounted) return;
      setState(() => _comments.removeWhere((c) => c.id == comment.id));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete comment: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Post'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Post Header
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: AppColors.primary100,
                                backgroundImage: _post?.authorProfileImageUrl != null
                                    ? NetworkImage(_post!.authorProfileImageUrl!)
                                    : null,
                                child: _post?.authorProfileImageUrl == null
                                    ? Text(
                                        _post!.authorName.isNotEmpty ? _post!.authorName[0] : '',
                                        style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _post?.authorName ?? '',
                                      style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Text(
                                          _post?.authorRoleText ?? '',
                                          style: AppTextStyles.bodySmall,
                                        ),
                                        if (_post?.authorSpecialization != null) ...[
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
                                            _post!.authorSpecialization!,
                                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                _timeAgo(_post?.createdAt ?? DateTime.now()),
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Post Content
                          Text(
                            _post?.content ?? '',
                            style: AppTextStyles.bodyLarge,
                          ),
                          if (_post?.specialization != null) ...[
                            const SizedBox(height: 16),
                            Chip(
                              label: Text(_post!.specialization!),
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
                          const SizedBox(height: 20),

                          // Comments Header
                          Row(
                            children: [
                              Text(
                                'Comments',
                                style: AppTextStyles.heading3,
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${_comments.length}',
                                  style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Comments List
                          ..._comments.map((comment) => _CommentItem(
                            comment: comment,
                            onDelete: () => _deleteComment(comment),
                          )),
                        ],
                      ),
                    ),
                  ),

                  // Add Comment Input
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      boxShadow: [
                        BoxShadow(color: AppColors.shadow, blurRadius: 4, offset: const Offset(0, -2)),
                      ],
                    ),
                    child: SafeArea(
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: TextField(
                                controller: _commentController,
                                maxLines: null,
                                textInputAction: TextInputAction.send,
                                onSubmitted: (_) => _addComment(),
                                decoration: InputDecoration(
                                  hintText: 'Add a comment...',
                                  hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          _postingComment
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : GestureDetector(
                                  onTap: _addComment,
                                  child: Container(
                                    height: 44,
                                    width: 44,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.send,
                                      color: AppColors.textOnPrimary,
                                      size: 20,
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _CommentItem extends StatelessWidget {
  final CommunityComment comment;
  final VoidCallback? onDelete;

  const _CommentItem({required this.comment, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary100,
            backgroundImage: comment.authorProfileImageUrl != null
                ? NetworkImage(comment.authorProfileImageUrl!)
                : null,
            child: comment.authorProfileImageUrl == null
                ? Text(
                    comment.authorName.isNotEmpty ? comment.authorName[0] : '',
                    style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.authorName,
                      style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.fromLTRB(6, 2, 6, 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        comment.authorRoleText,
                        style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary),
                      ),
                    ),
                    if (onDelete != null)
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.textTertiary),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                        onPressed: onDelete,
                      ),
                    Text(
                      DateFormat('MMM d, HH:mm').format(comment.createdAt),
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  comment.content,
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
