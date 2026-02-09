import 'package:inclusive_app/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<User> loginWithEmail(String email, String password);
  Future<User> loginWithGoogle();
  Future<User> registerWithEmail(String name, String email, String password);
  Future<User?> getCurrentUser();
  Future<void> logout();
}
