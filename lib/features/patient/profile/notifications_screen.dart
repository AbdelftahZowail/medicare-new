import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/models/shared_models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/error_utils.dart';
import '../services/patient_notifications_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _service = PatientNotificationsService();
  bool _loading = true;
  List<NotificationItem> _notifications = [];
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) _pollNotifications();
    });
  }

  Future<void> _loadNotifications() async {
    setState(() => _loading = true);
    try {
      final notifications = await _service.getNotifications();
      if (!mounted) return;
      setState(() {
        _notifications = notifications;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(kEnableDebugTools
              ? 'Failed to load notifications: ${errorMessage(e)}'
              : 'Failed to load notifications. Please try again.'),
        ),
      );
      setState(() {
        _notifications = [];
        _loading = false;
      });
    }
  }

  Future<void> _pollNotifications() async {
    try {
      final notifications = await _service.getNotifications();
      if (!mounted) return;
      setState(() => _notifications = notifications);
    } catch (_) {
      // Silently ignore poll failures
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _markAllAsRead() async {
    setState(() {
      for (var i = 0; i < _notifications.length; i++) {
        _notifications[i] = NotificationItem(
          id: _notifications[i].id,
          title: _notifications[i].title,
          message: _notifications[i].message,
          isRead: true,
          createdAt: _notifications[i].createdAt,
          type: _notifications[i].type,
          relatedId: _notifications[i].relatedId,
        );
      }
    });
  }

  Future<void> _markAsRead(NotificationItem notification) async {
    if (notification.isRead) return;

    try {
      await _service.markAsRead(notification.id);
    } catch (e) {
      // Ignore API errors
    }

    setState(() {
      final index = _notifications.indexWhere((n) => n.id == notification.id);
      if (index != -1) {
        _notifications[index] = NotificationItem(
          id: notification.id,
          title: notification.title,
          message: notification.message,
          isRead: true,
          createdAt: notification.createdAt,
          type: notification.type,
          relatedId: notification.relatedId,
        );
      }
    });
  }

  void _onNotificationTap(NotificationItem notification) {
    _markAsRead(notification);

    // Deep-link based on notification type
    if (notification.relatedId == null) return;

    switch (notification.type) {
      case 'appointment':
        context.push('${AppRoutes.patientAppointmentDetail}/${notification.relatedId}');
      case 'queue':
        context.push('${AppRoutes.patientQueueTracker}/${notification.relatedId}');
      case 'community':
        context.push('${AppRoutes.patientPostDetail}/${notification.relatedId}');
      default:
        break;
    }
  }

  Future<void> _deleteNotification(NotificationItem notification) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Notification'),
        content: const Text('Are you sure you want to delete this notification?'),
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
      await _service.deleteNotification(notification.id);
      if (!mounted) return;
      setState(() => _notifications.removeWhere((n) => n.id == notification.id));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(kEnableDebugTools
              ? 'Failed to delete notification: ${errorMessage(e)}'
              : 'Failed to delete notification. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _markAllAsRead,
            child: Text(
              'Mark all read',
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadNotifications,
                child: _notifications.isEmpty
                    ? _EmptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                        itemCount: _notifications.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final notification = _notifications[index];
                          return _NotificationCard(
                            notification: notification,
                            onTap: () => _onNotificationTap(notification),
                            onDelete: () => _deleteNotification(notification),
                          );
                        },
                      ),
              ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationItem notification;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        decoration: BoxDecoration(
          color: notification.isRead ? AppColors.surface : AppColors.primary50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: notification.isRead ? AppColors.borderLight : AppColors.primary200,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: _iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_icon, color: _iconColor, size: 20),
            ),
            const SizedBox(width: 12),
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
                            fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w600,
                          ),
                        ),
                      ),
                      if (onDelete != null)
                        IconButton(
                          icon: const Icon(Icons.close, size: 16, color: AppColors.textTertiary),
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                          onPressed: onDelete,
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
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _timeAgo(notification.createdAt),
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData get _icon {
    switch (notification.type) {
      case 'appointment':
        return Icons.calendar_today;
      case 'queue':
        return Icons.confirmation_number;
      case 'community':
        return Icons.chat_bubble;
      default:
        return Icons.notifications;
    }
  }

  Color get _iconColor {
    switch (notification.type) {
      case 'appointment':
        return AppColors.info;
      case 'queue':
        return AppColors.warning;
      case 'community':
        return AppColors.success;
      default:
        return AppColors.primary;
    }
  }

  Color get _iconBgColor {
    switch (notification.type) {
      case 'appointment':
        return AppColors.infoBg;
      case 'queue':
        return AppColors.warningBg;
      case 'community':
        return AppColors.successBg;
      default:
        return AppColors.primary100;
    }
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return DateFormat('MMM d').format(date);
  }
}

class _EmptyState extends StatelessWidget {
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
                Icons.notifications_none,
                size: 56,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No notifications',
              style: AppTextStyles.heading3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'You\'re all caught up! Check back later for updates.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
