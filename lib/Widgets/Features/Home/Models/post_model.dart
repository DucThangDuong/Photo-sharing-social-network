class UserModel {
  final int id;
  final String username;
  final String avatarUrl;
  UserModel({required this.id, required this.username, required this.avatarUrl});
}

class PostMedia {
  final String mediaUrl;
  PostMedia({required this.mediaUrl});
}

class PostModel {
  final int id;
  final UserModel user;
  final List<PostMedia> mediaList;
  final String caption;
  final int likeCount;
  final int commentCount;
  final DateTime createdAt;

  PostModel({
    required this.id,
    required this.user,
    required this.mediaList,
    required this.caption,
    required this.likeCount,
    required this.commentCount,
    required this.createdAt,
  });
}