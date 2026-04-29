class Post {
  final int id;
  final int userId;
  final String? caption;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.userId,
    this.caption,
    required this.createdAt,
  });
  factory Post.fromJson(Map<String, dynamic> json) => Post(
    id: json['Id'],
    userId: json['UserId'],
    caption: json['Caption'],
    createdAt: json['CreatedAt'],
  );
  Map<String, dynamic> toJson() => {
    'Id': id,
    'UserId': userId,
    'Caption': caption,
    'CreatedAt': createdAt.toIso8601String(),
  };
}