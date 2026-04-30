class Comment {
  final int id;
  final int postId;
  final int userId;
  final String content;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
    id: json['Id'],
    postId: json['PostId'],
    userId: json['UserId'],
    content: json['Content'],
    createdAt: DateTime.parse(json['CreatedAt']),
  );

  Map<String, dynamic> toJson() => {
    'Id': id,
    'PostId': postId,
    'UserId': userId,
    'Content': content,
    'CreatedAt': createdAt.toIso8601String(),
  };
}
