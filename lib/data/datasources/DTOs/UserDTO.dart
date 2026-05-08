class UserModelDTO {
  final int id;
  final String username;
  final String email;
  final String? fullName;
  final String? bio;
  final String? avatarUrl;
  final int followersNumber;
  final int followingsNumber;
  final int postsNumber;
  final int gender;

  UserModelDTO({
    required this.id,
    required this.username,
    required this.email,
    this.fullName,
    this.bio,
    this.avatarUrl,
    required this.followersNumber,
    required this.followingsNumber,
    required this.postsNumber,
    required this.gender
  });

  factory UserModelDTO.fromJson(Map<String, dynamic> json) {
    return UserModelDTO(
        id: json['id'] ?? 0,
        username: json['username'] ?? '',
        email: json['email'] ?? '',
        fullName: json['fullName'],
        bio: json['bio'],
        avatarUrl: json['avatarUrl'],
        followersNumber: json['followersNumber'] ?? 0,
        followingsNumber: json['followingsNumber'] ?? 0,
        postsNumber: json['postsNumber'] ?? 0,
        gender: json['gender'] ?? 0,
    );
  }
}

class SuggestedUserDTO {
  final int id;
  final String username;
  final String? fullName;
  final String? avatarUrl;
  final bool isFollowing;

  SuggestedUserDTO({
    required this.id,
    required this.username,
    this.fullName,
    this.avatarUrl,
    this.isFollowing = false,
  });

  factory SuggestedUserDTO.fromJson(Map<String, dynamic> json) {
    return SuggestedUserDTO(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      fullName: json['fullName'],
      avatarUrl: json['avatarUrl'],
      isFollowing: json['isFollowing'] ?? false,
    );
  }

  SuggestedUserDTO copyWith({
    int? id,
    String? username,
    String? fullName,
    String? avatarUrl,
    bool? isFollowing,
  }) {
    return SuggestedUserDTO(
      id: id ?? this.id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }
}
class SummaryUserDTO {
  final int id;
  final String username;
  final String? fullName;
  final String? avatarUrl;

  SummaryUserDTO({
    required this.id,
    required this.username,
    this.fullName,
    this.avatarUrl,
  });

  factory SummaryUserDTO.fromJson(Map<String, dynamic> json) {
    return SummaryUserDTO(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      fullName: json['fullName'],
      avatarUrl: json['avatarUrl'],
    );
  }

  SummaryUserDTO copyWith({
    int? id,
    String? username,
    String? fullName,
    String? avatarUrl,
  }) {
    return SummaryUserDTO(
      id: id ?? this.id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}