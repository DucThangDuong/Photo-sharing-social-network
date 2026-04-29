class PostMedia {
  final int id;
  final int postId;
  final String mediaUrl;
  final int sortOrder;
  final DateTime createdAt;

  PostMedia({
    required this.id,
    required this.postId,
    required this.mediaUrl,
    required this.sortOrder,
    required this.createdAt,
  });

  factory PostMedia.fromJson(Map<String, dynamic> json) => PostMedia(
    id: json['Id'],
    postId: json['PostId'],
    mediaUrl: json['MediaUrl'],
    sortOrder: json['SortOrder'],
    createdAt: DateTime.parse(json['CreatedAt']),
  );

  Map<String, dynamic> toJson() => {
    'Id': id,
    'PostId': postId,
    'MediaUrl': mediaUrl,
    'SortOrder': sortOrder,
    'CreatedAt': createdAt.toIso8601String(),
  };
}