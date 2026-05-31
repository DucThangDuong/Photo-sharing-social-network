class NotificationModel {
  final int id;
  final int type;

  // Thông tin người gửi
  final int senderId;
  final String senderUsername;
  final String? senderAvatarUrl;

  // Nội dung và Đích đến
  final String? previewText;
  final int? postId;
  final int? commentId;
  final int? storyId;
  final String? targetMediaUrl;

  // Trạng thái
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.senderId,
    required this.senderUsername,
    this.senderAvatarUrl,
    this.previewText,
    this.postId,
    this.commentId,
    this.storyId,
    this.targetMediaUrl,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? 0,
      type: json['type'] ?? 0,
      senderId: json['senderId'] ?? 0,
      senderUsername: json['senderUsername'] ?? 'Instagram User',
      senderAvatarUrl: json['senderAvatarUrl'],
      previewText: json['previewText'],
      postId: json['postId'],
      commentId: json['commentId'],
      storyId: json['storyId'],
      targetMediaUrl: json['targetMediaUrl'],
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}