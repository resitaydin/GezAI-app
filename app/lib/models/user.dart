class AppUser {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final DateTime? createdAt;

  AppUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.createdAt,
  });

  factory AppUser.fromFirebase(Map<String, dynamic> data, String uid) {
    return AppUser(
      uid: uid,
      email: data['email'] as String?,
      displayName: data['display_name'] as String?,
      photoUrl: data['photo_url'] as String?,
      createdAt: data['created_at'] != null
          ? DateTime.parse(data['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'display_name': displayName,
      'photo_url': photoUrl,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
