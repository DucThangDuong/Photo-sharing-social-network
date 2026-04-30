class UserModelDTO {
  final int id;
  final String username;
  final String email;
  final String? fullName;
  final String? bio;
  final String? avatarUrl;
  final int followersNumber;
  final int followingsNumber;

  UserModelDTO({
    required this.id,
    required this.username,
    required this.email,
    this.fullName,
    this.bio,
    this.avatarUrl,
    required this.followersNumber,
    required this.followingsNumber,
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
    );
  }
}