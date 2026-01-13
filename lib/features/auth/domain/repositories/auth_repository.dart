import 'package:inclusive_app/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<User> loginWithEmail(String email, String password);
  Future<User> loginWithGoogle();
  Future<User?> getCurrentUser();
  Future<void> logout();
}
