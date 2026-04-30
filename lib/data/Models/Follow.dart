class Follow {
  final int followerId;
  final int followingId;
  final DateTime createdAt;

  Follow({
    required this.followerId,
    required this.followingId,
    required this.createdAt,
  });

  factory Follow.fromJson(Map<String, dynamic> json) => Follow(
    followerId: json['FollowerId'],
    followingId: json['FollowingId'],
    createdAt: DateTime.parse(json['CreatedAt']),
  );

  Map<String, dynamic> toJson() => {
    'FollowerId': followerId,
    'FollowingId': followingId,
    'CreatedAt': createdAt.toIso8601String(),
  };
}