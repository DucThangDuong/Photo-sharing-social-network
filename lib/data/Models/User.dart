class User {
  final int id;
  final String username;
  final String email;
  final String? passwordHash; 
  final String fullName;
  final String? bio;
  final String? avatarUrl;
  final DateTime createdAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.passwordHash,
    required this.fullName,
    this.bio,
    this.avatarUrl,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['Id'],
    username: json['Username'],
    email: json['Email'],
    fullName: json['FullName'],
    bio: json['Bio'],
    avatarUrl: json['AvatarUrl'],
    createdAt: DateTime.parse(json['CreatedAt']),
  );

  Map<String, dynamic> toJson() => {
    'Id': id,
    'Username': username,
    'Email': email,
    'FullName': fullName,
    'Bio': bio,
    'AvatarUrl': avatarUrl,
    'CreatedAt': createdAt.toIso8601String(),
  };
}