import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/error_utils.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/models/shared_models.dart';
import '../../clinic/clinic_service.dart';

class ClinicNotificationsScreen extends StatefulWidget {
  const ClinicNotificationsScreen({super.key});

  @override
  State<ClinicNotificationsScreen> createState() => _ClinicNotificationsScreenState();
}

class _ClinicNotificationsScreenState extends State<ClinicNotificationsScreen> {
  final _service = ClinicService();
  List<NotificationItem> _notifications = [];
  bool _isLoading = true;
  String? _error;

  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) _pollNotifications();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final notifications = await _service.getNotifications();
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = errorMessage(e);
        _isLoading = false;
      });
    }
  }

  Future<void> _pollNotifications() async {
    try {
      final notifications = await _service.getNotifications();
      if (!mounted) return;
      setState(() {
        _notifications = notifications;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = errorMessage(e));
    }
  }

  Future<void> _markAsRead(int id) async {
    try {
      await _service.markNotificationRead(id);
      setState(() {
        final index = _notifications.indexWhere((n) => n.id == id);
        if (index != -1) {
          _notifications[index] = NotificationItem(
            id: _notifications[index].id,
            title: _notifications[index].title,
            message: _notifications[index].message,
            isRead: true,
            createdAt: _notifications[index].createdAt,
            type: _notifications[index].type,
            relatedId: _notifications[index].relatedId,
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(kEnableDebugTools
                ? 'Failed to mark notification as read: ${errorMessage(e)}'
                : 'Failed to mark notification as read. Please try again.'),
          ),
        );
      }
    }
  }

  String _timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_notifications.any((n) => !n.isRead))
            TextButton(
              onPressed: () async {
                for (final notification in _notifications.where((n) => !n.isRead)) {
                  await _markAsRead(notification.id);
                }
              },
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _buildError()
                : RefreshIndicator(
                    onRefresh: _loadNotifications,
                    child: _notifications.isEmpty
                        ? _buildEmptyState()
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                            itemCount: _notifications.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final notification = _notifications[index];
                              return _NotificationCard(
                                notification: notification,
                                timeAgo: _timeAgo(notification.createdAt),
                                onTap: () {
                                  if (!notification.isRead) {
                                    _markAsRead(notification.id);
                                  }
                                },
                              );
                            },
                          ),
                  ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: AppColors.error.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            'Failed to load notifications',
            style: AppTextStyles.heading3.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Unknown error',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadNotifications,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Center(
          child: Column(
            children: [
              Icon(Icons.notifications_off, size: 64, color: AppColors.textTertiary.withOpacity(0.3)),
              const SizedBox(height: 16),
              Text(
                'No notifications',
                style: AppTextStyles.heading3.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              Text(
                'You\'re all caught up!',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationItem notification;
  final String timeAgo;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.timeAgo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    Color iconColor;

    switch (notification.type?.toLowerCase()) {
      case 'appointment':
        iconData = Icons.calendar_today;
        iconColor = AppColors.primary;
        break;
      case 'payment':
        iconData = Icons.payment;
        iconColor = AppColors.success;
        break;
      case 'queue':
        iconData = Icons.queue;
        iconColor = AppColors.warning;
        break;
      case 'alert':
        iconData = Icons.warning;
        iconColor = AppColors.error;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = AppColors.primary;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: notification.isRead ? AppColors.surface : AppColors.primary50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: notification.isRead ? AppColors.borderLight : AppColors.primary200,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(iconData, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: AppTextStyles.labelLarge.copyWith(
                            fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w700,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          height: 8,
                          width: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    timeAgo,
                    style: AppTextStyles.labelSmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
