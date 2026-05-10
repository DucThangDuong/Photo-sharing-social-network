class StoryDTO {
  final int id;
  final int userId;
  final String mediaUrl;
  final DateTime createdAt;
  final DateTime expiresAt;

  StoryDTO({
    required this.id,
    required this.mediaUrl,
    required this.createdAt,
    required this.userId,
    required this.expiresAt
  });

  factory StoryDTO.fromJson(Map<String, dynamic> json) {
    return StoryDTO(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      mediaUrl: json['mediaUrl'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : DateTime.now(),
    );
  }
}

class UserStoryDTO {
  final int userId;
  final String username;
  final String? avatarUrl;
  final List<StoryDTO> stories;

  UserStoryDTO({
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.stories,
  });

  factory UserStoryDTO.fromJson(Map<String, dynamic> json) {
    var storiesList = json['stories'] as List? ?? [];
    List<StoryDTO> stories = storiesList.map((i) => StoryDTO.fromJson(i)).toList();

    return UserStoryDTO(
      userId: json['userId'] ?? 0,
      username: json['username'] ?? '',
      avatarUrl: json['avatarUrl'],
      stories: stories,
    );
  }
}
