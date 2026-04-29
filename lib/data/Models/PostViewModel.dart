import 'Post.dart';
import 'PostMedia.dart';
import 'User.dart';

class PostViewModel {
  final Post post;
  final User user;
  final List<PostMedia> mediaList;
  final int likeCount;
  final int commentCount;

  PostViewModel({
    required this.post,
    required this.user,
    required this.mediaList,
    required this.likeCount,
    required this.commentCount,
  });
  factory PostViewModel.fromJson(Map<String, dynamic> json) => PostViewModel(
    post: Post.fromJson(json['Post']),
    user: User.fromJson(json['User']),
    mediaList: (json['MediaList'] as List)
        .map((i) => PostMedia.fromJson(i))
        .toList(),
    likeCount: json['LikeCount'] ?? 0,
    commentCount: json['CommentCount'] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'Post': post.toJson(),
    'User': user.toJson(),
    'MediaList': mediaList.map((i) => i.toJson()).toList(),
    'LikeCount': likeCount,
    'CommentCount': commentCount,
  };
}