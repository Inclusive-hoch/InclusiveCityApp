class User {
  final String uid;
  final String email;
  final String? name;
  final String? profilePictureUrl;

  User({
    required this.uid,
    required this.email,
    this.name,
    this.profilePictureUrl,
  });
}
