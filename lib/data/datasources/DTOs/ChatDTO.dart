class InboxItemDTO {
  final int conversationId;
  final String otherUserName;
  final String? otherUserAvatar;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final bool hasUnread;

  InboxItemDTO({
    required this.conversationId,
    required this.otherUserName,
    this.otherUserAvatar,
    this.lastMessage,
    this.lastMessageAt,
    required this.hasUnread,
  });

  factory InboxItemDTO.fromJson(Map<String, dynamic> json) {
    return InboxItemDTO(
      conversationId: json['conversationId'] ?? 0,
      otherUserName: json['otherUserName'] ?? '',
      otherUserAvatar: json['otherUserAvatar'],
      lastMessage: json['lastMessage'],
      lastMessageAt: json['lastMessageAt'] != null 
          ? DateTime.parse(json['lastMessageAt'].toString().endsWith('Z') 
              ? json['lastMessageAt'] 
              : '${json['lastMessageAt']}Z').toLocal() 
          : null,
      hasUnread: json['hasUnread'] ?? false,
    );
  }
}

class MessageDTO {
  final int id;
  final int conversationId;
  final int senderId;
  final int messageType;
  final String? content;
  final String? mediaUrl;
  final DateTime createdAt;

  MessageDTO({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.messageType,
    this.content,
    this.mediaUrl,
    required this.createdAt,
  });

  factory MessageDTO.fromJson(Map<String, dynamic> json) {
    return MessageDTO(
      id: json['id'] ?? 0,
      conversationId: json['conversationId'] ?? 0,
      senderId: json['senderId'] ?? 0,
      messageType: json['messageType'] ?? 0,
      content: json['content'],
      mediaUrl: json['mediaUrl'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'].toString().endsWith('Z') 
              ? json['createdAt'] 
              : '${json['createdAt']}Z').toLocal() 
          : DateTime.now(),
    );
  }
}

class ConversationDetailDTO {
  final int otherUserId;
  final String otherUserName;
  final String? otherUserAvatar;
  final List<MessageDTO> messages;

  ConversationDetailDTO({
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserAvatar,
    required this.messages,
  });

  factory ConversationDetailDTO.fromJson(Map<String, dynamic> json) {
    var list = json['messages'] as List? ?? [];
    List<MessageDTO> messagesList = list.map((i) => MessageDTO.fromJson(i)).toList();

    return ConversationDetailDTO(
      otherUserId: json['otherUserId'] ?? 0,
      otherUserName: json['otherUserName'] ?? '',
      otherUserAvatar: json['otherUserAvatar'],
      messages: messagesList,
    );
  }
}
