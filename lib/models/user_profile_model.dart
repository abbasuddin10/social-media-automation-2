class UserProfileModel {
  final String id;
  final String email;
  final String? name;
  final String? avatarUrl;
  final String? bio;

  UserProfileModel({
    required this.id,
    required this.email,
    this.name,
    this.avatarUrl,
    this.bio,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      name: json['name'],
      avatarUrl: json['avatar_url'],
      bio: json['bio'],
    );
  }
}
