import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/notifications_controller.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const Color _bg = Color(0xFFF5F7FB);
  static const Color _card = Colors.white;
  static const Color _heading = Color(0xFF0B1F45);
  static const Color _muted = Color(0xFF5C6B82);
  static const Color _border = Color(0xFFE2E7F0);
  static const Color _teal = Color(0xFF2EC4B6);

  late final NotificationsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<NotificationsController>(tag: 'notif')
        ? Get.find<NotificationsController>(tag: 'notif')
        : Get.put(NotificationsController(), tag: 'notif');
    controller.fetchNotifications();
  }

  String _formatTime(dynamic raw) {
    if (raw == null) return '';
    try {
      final dt = DateTime.parse(raw.toString()).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 1) return 'just_now'.tr;
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ${'ago'.tr}';
      if (diff.inHours < 24) return '${diff.inHours}h ${'ago'.tr}';
      if (diff.inDays < 7) return '${diff.inDays}d ${'ago'.tr}';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _card,
        foregroundColor: _heading,
        elevation: 0.5,
        title: Text(
          'notifications'.tr,
          style: const TextStyle(color: _heading, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all_rounded, color: _teal),
            tooltip: 'mark_all_read'.tr,
            onPressed: controller.markAllAsRead,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.notifications.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: _teal));
        }
        if (controller.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _teal.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.notifications_off_outlined,
                      color: _teal, size: 48),
                ),
                const SizedBox(height: 14),
                Text(
                  'no_notifications'.tr,
                  style: const TextStyle(
                    color: _heading,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          color: _teal,
          onRefresh: controller.fetchNotifications,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.notifications.length,
            itemBuilder: (context, index) {
              final item = controller.notifications[index];
              final isRead =
                  item['is_read'] == true || item['is_read'] == 1;
              final timeLabel =
                  _formatTime(item['created_at'] ?? item['updated_at']);
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: _card,
                  border: Border.all(
                    color: isRead ? _border : _teal.withOpacity(0.35),
                    width: isRead ? 1.0 : 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _heading.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isRead
                            ? const Color(0xFFEFF3F8)
                            : _teal.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isRead
                            ? Icons.notifications_none_rounded
                            : Icons.notifications_active_rounded,
                        color: isRead ? _muted : _teal,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  item['title']?.toString() ?? '',
                                  style: TextStyle(
                                    color: _heading,
                                    fontWeight: isRead
                                        ? FontWeight.w600
                                        : FontWeight.w800,
                                  ),
                                ),
                              ),
                              if (timeLabel.isNotEmpty) ...[
                                const SizedBox(width: 6),
                                Text(
                                  timeLabel,
                                  style: const TextStyle(
                                      color: _muted, fontSize: 11),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['message']?.toString() ?? '',
                            style: const TextStyle(color: _muted, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                    if (!isRead)
                      IconButton(
                        icon: const Icon(Icons.mark_email_read_outlined,
                            color: _teal, size: 20),
                        onPressed: () => controller.markAsRead(
                            int.tryParse(item['id'].toString()) ?? 0),
                      ),
                  ],
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
