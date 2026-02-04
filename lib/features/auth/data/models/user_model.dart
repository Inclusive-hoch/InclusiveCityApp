import '../../domain/entities/user.dart';

class UserModel {
  final String uid;
  final String email;
  final String? name;
  final String? profilePictureUrl;

  UserModel({
    required this.uid,
    required this.email,
    this.name,
    this.profilePictureUrl,
  });

  factory UserModel.fromFirebase(dynamic user) {
    return UserModel(
      uid: user.uid,
      email: user.email,
      name: user.displayName,
      profilePictureUrl: user.photoURL,
    );
  }

  User toEntity() => User(
    uid: uid,
    email: email,
    name: name,
    profilePictureUrl: profilePictureUrl,
  );
}
