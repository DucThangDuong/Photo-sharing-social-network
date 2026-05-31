import 'package:flutter/material.dart';

import '../../../../../data/Helper.dart';
import '../../../../../data/datasources/DTOs/NotificationDTO.dart';
import '../../../../../data/datasources/global/CallAPIOfUser.dart';
import '../../../../../presentation/pages/guest_profile_page.dart';
import '../../../Search/Presentation/Page/discover_post_detail_page.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  bool _isLoading = true;
  List<NotificationModel> _notifications = [];

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    final notifs = await CallMyAPI.getNotifications();
    if (mounted) {
      setState(() {
        _notifications = notifs;
        _isLoading = false;
      });
    }
  }

  String _getTimeGroup(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays == 0 && now.day == date.day) {
      return 'Hôm nay';
    } else if (difference.inDays < 7) {
      return '7 ngày qua';
    } else if (difference.inDays < 30) {
      return 'Tháng này';
    } else {
      return 'Trước đó';
    }
  }

  void _handleNotificationClick(NotificationModel notif) async {
    if (!notif.isRead) {
      await CallMyAPI.markNotificationAsRead(notif.id);
      if (mounted) {
        setState(() {
          final index = _notifications.indexWhere((n) => n.id == notif.id);
          if (index != -1) {
            _notifications[index] = NotificationModel(
              id: notif.id,
              type: notif.type,
              senderId: notif.senderId,
              senderUsername: notif.senderUsername,
              senderAvatarUrl: notif.senderAvatarUrl,
              previewText: notif.previewText,
              postId: notif.postId,
              commentId: notif.commentId,
              storyId: notif.storyId,
              targetMediaUrl: notif.targetMediaUrl,
              isRead: true,
              createdAt: notif.createdAt,
            );
          }
        });
      }
    }

    if (!mounted) return;

    if (notif.type == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GuestProfilePage(userId: notif.senderId),
        ),
      );
    } else if (notif.type == 3 && notif.postId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DiscoverPostDetailPage(postId: notif.postId!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Thông báo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white54))
          : _notifications.isEmpty
              ? const Center(child: Text('Không có thông báo', style: TextStyle(color: Colors.white)))
              : RefreshIndicator(
                  onRefresh: _fetchNotifications,
                  color: Colors.blue,
                  child: ListView.builder(
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notif = _notifications[index];
                      final prevNotif = index > 0 ? _notifications[index - 1] : null;
                      
                      final currentGroup = _getTimeGroup(notif.createdAt);
                      final prevGroup = prevNotif != null ? _getTimeGroup(prevNotif.createdAt) : null;
                      
                      final bool showHeader = currentGroup != prevGroup;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showHeader)
                            Padding(
                              padding: const EdgeInsets.only(left: 16, top: 16, bottom: 12),
                              child: Text(
                                currentGroup,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          _buildNotificationItem(notif),
                        ],
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildNotificationItem(NotificationModel notif) {
    final avatarUrl = notif.senderAvatarUrl != null && notif.senderAvatarUrl!.isNotEmpty
        ? AppHelper.formatImageURL(notif.senderAvatarUrl!)
        : '';
    final targetImageUrl = notif.targetMediaUrl != null && notif.targetMediaUrl!.isNotEmpty
        ? AppHelper.formatImageURL(notif.targetMediaUrl!)
        : '';

    // timeago
    final timeStr = AppHelper.formatTimeAgo(notif.createdAt);

    return GestureDetector(
      onTap: () => _handleNotificationClick(notif),
      child: Container(
        color: notif.isRead ? Colors.transparent : Colors.blue.withOpacity(0.15),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.grey[800],
              backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
              child: avatarUrl.isEmpty ? const Icon(Icons.person, color: Colors.white, size: 24) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.3),
                  children: [
                    TextSpan(
                      text: notif.senderUsername,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(text: ' '),
                    TextSpan(
                      text: (notif.previewText ?? 'đã gửi một thông báo.') + ' ',
                    ),
                    TextSpan(
                      text: timeStr.replaceAll(' trước', ''), // simplify like "26 phút"
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            if (notif.type == 3 && targetImageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  targetImageUrl,
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 44,
                    height: 44,
                    color: Colors.grey[800],
                    child: const Icon(Icons.broken_image, color: Colors.white54, size: 20),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
