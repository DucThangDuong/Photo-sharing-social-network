class StoryDTO {
  final int id;
  final int userId;
  final String mediaUrl;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isSeen;
  bool isLiked; // Cho phép thay đổi trạng thái like ở local

  StoryDTO({
    required this.id,
    required this.mediaUrl,
    required this.createdAt,
    required this.userId,
    required this.expiresAt,
    required this.isSeen,
    required this.isLiked,
  });

  factory StoryDTO.fromJson(Map<String, dynamic> json) {
    return StoryDTO(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      mediaUrl: json['mediaUrl'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'])
          : DateTime.now(),
      isSeen: json['isSeen'] ?? false,
      isLiked: json['isLiked'] ?? false,
    );
  }
}

class UserStoryDTO {
  final int userId;
  final String username;
  final String? avatarUrl;
  final bool hasSeen;
  final List<StoryDTO> stories;

  UserStoryDTO({
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.stories,
    required this.hasSeen
  });

  factory UserStoryDTO.fromJson(Map<String, dynamic> json) {
    var storiesList = json['stories'] as List? ?? [];
    List<StoryDTO> stories = storiesList.map((i) => StoryDTO.fromJson(i)).toList();

    return UserStoryDTO(
      userId: json['userId'] ?? 0,
      username: json['username'] ?? '',
      avatarUrl: json['avatarUrl'],
      hasSeen: json['hasSeen'] ?? false,
      stories: stories,
    );
  }
}

class StoryViewerDTO {
  final int viewerId;
  final String username;
  final String? fullName;
  final String? avatarUrl;
  final bool isLiked;
  final DateTime viewedAt;

  StoryViewerDTO({
    required this.viewerId,
    required this.username,
    this.fullName,
    this.avatarUrl,
    required this.isLiked,
    required this.viewedAt,
  });

  factory StoryViewerDTO.fromJson(Map<String, dynamic> json) {
    return StoryViewerDTO(
      viewerId: json['viewerId'] ?? 0,
      username: json['username'] ?? '',
      fullName: json['fullName'],
      avatarUrl: json['avatarUrl'],
      isLiked: json['isLiked'] ?? false,
      viewedAt: json['viewedAt'] != null ? DateTime.parse(json['viewedAt']) : DateTime.now(),
    );
  }
}

class HighlightDTO {
  final int id;
  final String title;
  final String? coverUrl;
  final DateTime createdAt;

  HighlightDTO({
    required this.id,
    required this.title,
    this.coverUrl,
    required this.createdAt,
  });

  factory HighlightDTO.fromJson(Map<String, dynamic> json) {
    return HighlightDTO(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      coverUrl: json['coverUrl'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}

class StoryWithStatsDTO extends StoryDTO {
  final int viewCount;
  final int likeCount;
  final List<StoryViewerDTO> viewers;

  StoryWithStatsDTO({
    required int id,
    required int userId,
    required String mediaUrl,
    required DateTime createdAt,
    required DateTime expiresAt,
    required bool isSeen,
    required bool isLiked,
    required this.viewCount,
    required this.likeCount,
    required this.viewers,
  }) : super(
          id: id,
          userId: userId,
          mediaUrl: mediaUrl,
          createdAt: createdAt,
          expiresAt: expiresAt,
          isSeen: isSeen,
          isLiked: isLiked,
        );

  factory StoryWithStatsDTO.fromJson(Map<String, dynamic> json) {
    var viewersList = json['viewers'] as List? ?? [];
    List<StoryViewerDTO> viewers = viewersList.map((i) => StoryViewerDTO.fromJson(i)).toList();

    return StoryWithStatsDTO(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      mediaUrl: json['mediaUrl'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : DateTime.now(),
      isSeen: json['isSeen'] ?? false,
      isLiked: json['isLiked'] ?? false,
      viewCount: json['viewCount'] ?? 0,
      likeCount: json['likeCount'] ?? 0,
      viewers: viewers,
    );
  }
}

class HighlightDetailDTO extends HighlightDTO {
  final List<StoryWithStatsDTO> stories;

  HighlightDetailDTO({
    required int id,
    required String title,
    String? coverUrl,
    required DateTime createdAt,
    required this.stories,
  }) : super(
          id: id,
          title: title,
          coverUrl: coverUrl,
          createdAt: createdAt,
        );

  factory HighlightDetailDTO.fromJson(Map<String, dynamic> json) {
    var storiesList = json['stories'] as List? ?? [];
    List<StoryWithStatsDTO> stories = storiesList.map((i) => StoryWithStatsDTO.fromJson(i)).toList();

    return HighlightDetailDTO(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      coverUrl: json['coverUrl'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      stories: stories,
    );
  }
}
