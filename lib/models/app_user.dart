class AppUser {
  final String uid;
  final String email;
  final String? username;
  final String? profilePictureUrl;
  final DateTime? createdAt;
  final bool? isDeleted;

  AppUser({
    required this.uid,
    required this.email,
    this.username,
    this.profilePictureUrl,
    this.createdAt,
    this.isDeleted,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'],
      email: json['email'],
      username: json['username'],
      profilePictureUrl: json['profilePictureUrl'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      isDeleted: json['isDeleted'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'profilePictureUrl': profilePictureUrl,
      'createdAt': createdAt?.toIso8601String(),
      'isDeleted': isDeleted,
    };
  }
}