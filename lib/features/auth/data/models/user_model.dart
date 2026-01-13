import '../../domain/entities/user.dart';

class UserModel {
  final String uid;
  final String email;
  final String? name;

  UserModel({required this.uid, required this.email, this.name});

  factory UserModel.fromFirebase(dynamic user) {
    return UserModel(uid: user.uid, email: user.email, name: user.displayName);
  }

  User toEntity() => User(uid: uid, email: email, name: name);
}
