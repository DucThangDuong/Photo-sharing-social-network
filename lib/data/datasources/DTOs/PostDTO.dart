class PostSummaryDTO {
  final int id;
  final String? caption;
  final List<PostMediumSummaryDTO> postMedia;

  PostSummaryDTO({
    required this.id,
    this.caption,
    required this.postMedia,
  });

  factory PostSummaryDTO.fromJson(Map<String, dynamic> json) {
    var list = json['postMedia'] as List? ?? [];
    List<PostMediumSummaryDTO> mediaList = list.map((i) => PostMediumSummaryDTO.fromJson(i)).toList();

    return PostSummaryDTO(
      id: json['id'] ?? 0,
      caption: json['caption'],
      postMedia: mediaList,
    );
  }
}

class PostMediumSummaryDTO {
  final String mediaUrl;
  PostMediumSummaryDTO({
    required this.mediaUrl,
  });

  factory PostMediumSummaryDTO.fromJson(Map<String, dynamic> json) {
    return PostMediumSummaryDTO(
      mediaUrl: json['mediaUrl'] ?? '',
    );
  }
}
class PostDetailUserDTO {
  final int id;
  final String? caption;
  final DateTime createdAt;
  final int visibility;
  final bool hideLikeCount;
  final bool disableComments;
  final List<PostMediumSummaryDTO> postMedia;
  final int likeCount;
  final int commentCount;
  final bool isLikedByCurrentUser;
  final bool isArchived;

  PostDetailUserDTO({
    required this.id,
    this.caption,
    required this.createdAt,
    required this.visibility,
    required this.hideLikeCount,
    required this.disableComments,
    required this.postMedia,
    required this.likeCount,
    required this.commentCount,
    required this.isLikedByCurrentUser,
    required this.isArchived,
  });

  factory PostDetailUserDTO.fromJson(Map<String, dynamic> json) {
    var list = json['postMedia'] as List? ?? [];
    List<PostMediumSummaryDTO> mediaList = list.map((i) =>
        PostMediumSummaryDTO.fromJson(i)).toList();
    return PostDetailUserDTO(
      id: json['id'] ?? 0,
      caption: json['caption'],
      createdAt: DateTime.parse(
          json['createdAt'] ?? DateTime.now().toIso8601String()),
      visibility: json['visibility'] ?? 0,
      hideLikeCount: json['hideLikeCount'] ?? false,
      disableComments: json['disableComments'] ?? false,
      postMedia: mediaList,
      likeCount: json['likeCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
      isLikedByCurrentUser: json['isLikedByCurrentUser'] ?? false,
      isArchived: json['isArchived'] ?? false,
    );
  }

  PostDetailUserDTO copyWith({
    int? id,
    String? caption,
    DateTime? createdAt,
    int? visibility,
    bool? hideLikeCount,
    bool? disableComments,
    List<PostMediumSummaryDTO>? postMedia,
    int? likeCount,
    int? commentCount,
    bool? isLikedByCurrentUser,
    bool? isArchived,
  }) {
    return PostDetailUserDTO(
      id: id ?? this.id,
      caption: caption ?? this.caption,
      createdAt: createdAt ?? this.createdAt,
      visibility: visibility ?? this.visibility,
      hideLikeCount: hideLikeCount ?? this.hideLikeCount,
      disableComments: disableComments ?? this.disableComments,
      postMedia: postMedia ?? this.postMedia,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isLikedByCurrentUser: isLikedByCurrentUser ?? this.isLikedByCurrentUser,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}

class CommentDTO {
  final int id;
  final int userId;
  final String username;
  final String? avatarUrl;
  final String content;
  final DateTime createdAt;

  CommentDTO({
    required this.id,
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.content,
    required this.createdAt,
  });

  factory CommentDTO.fromJson(Map<String, dynamic> json) {
    return CommentDTO(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      username: json['username'] ?? '',
      avatarUrl: json['avatarUrl'],
      content: json['content'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class HomePostDTO {
  final int id;
  final String? caption;
  final DateTime createdAt;
  final int visibility;
  final bool hideLikeCount;
  final bool disableComments;
  final List<PostMediumSummaryDTO> postMedia;
  final int likeCount;
  final int commentCount;
  final bool isLikedByCurrentUser;
  final bool isArchived;
  final int userId;
  final String username;
  final String? avatarUrl;

  HomePostDTO({
    required this.id,
    this.caption,
    required this.createdAt,
    required this.visibility,
    required this.hideLikeCount,
    required this.disableComments,
    required this.postMedia,
    required this.likeCount,
    required this.commentCount,
    required this.isLikedByCurrentUser,
    required this.isArchived,
    required this.userId,
    required this.username,
    this.avatarUrl,
  });

  factory HomePostDTO.fromJson(Map<String, dynamic> json) {
    var list = json['postMedia'] as List? ?? [];
    List<PostMediumSummaryDTO> mediaList = list.map((i) =>
        PostMediumSummaryDTO.fromJson(i)).toList();
    return HomePostDTO(
      id: json['id'] ?? 0,
      caption: json['caption'],
      createdAt: DateTime.parse(
          json['createdAt'] ?? DateTime.now().toIso8601String()),
      visibility: json['visibility'] ?? 0,
      hideLikeCount: json['hideLikeCount'] ?? false,
      disableComments: json['disableComments'] ?? false,
      postMedia: mediaList,
      likeCount: json['likeCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
      isLikedByCurrentUser: json['isLikedByCurrentUser'] ?? false,
      isArchived: json['isArchived'] ?? false,
      userId: json['userId'] ?? 0,
      username: json['username'] ?? '',
      avatarUrl: json['avatarUrl'],
    );
  }

  HomePostDTO copyWith({
    int? id,
    String? caption,
    DateTime? createdAt,
    int? visibility,
    bool? hideLikeCount,
    bool? disableComments,
    List<PostMediumSummaryDTO>? postMedia,
    int? likeCount,
    int? commentCount,
    bool? isLikedByCurrentUser,
    bool? isArchived,
    int? userId,
    String? username,
    String? avatarUrl,
  }) {
    return HomePostDTO(
      id: id ?? this.id,
      caption: caption ?? this.caption,
      createdAt: createdAt ?? this.createdAt,
      visibility: visibility ?? this.visibility,
      hideLikeCount: hideLikeCount ?? this.hideLikeCount,
      disableComments: disableComments ?? this.disableComments,
      postMedia: postMedia ?? this.postMedia,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isLikedByCurrentUser: isLikedByCurrentUser ?? this.isLikedByCurrentUser,
      isArchived: isArchived ?? this.isArchived,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
