import '../models/user_model.dart';

abstract class AuthFirebaseDataSource {
  Future<UserModel> loginWithEmail(String email, String password);
  Future<UserModel> loginWithGoogle();
  UserModel? getCurrentUser();
  Future<void> logout();
}
