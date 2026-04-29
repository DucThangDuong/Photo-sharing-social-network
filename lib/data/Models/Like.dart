class Like {
  final int postId;
  final int userId;
  final DateTime createdAt;

  Like({
    required this.postId,
    required this.userId,
    required this.createdAt,
  });

  factory Like.fromJson(Map<String, dynamic> json) => Like(
    postId: json['PostId'],
    userId: json['UserId'],
    createdAt: DateTime.parse(json['CreatedAt']),
  );

  Map<String, dynamic> toJson() => {
    'PostId': postId,
    'UserId': userId,
    'CreatedAt': createdAt.toIso8601String(),
  };
}