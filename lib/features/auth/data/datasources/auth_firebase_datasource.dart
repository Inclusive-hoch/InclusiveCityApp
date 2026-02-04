import '../models/user_model.dart';

abstract class AuthFirebaseDataSource {
  Future<UserModel> loginWithEmail(String email, String password);
  Future<UserModel> loginWithGoogle();
  Future<UserModel> registerWithEmail(
    String name,
    String email,
    String password,
  );
  UserModel? getCurrentUser();
  Future<void> logout();
}
