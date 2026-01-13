import 'package:inclusive_app/features/auth/domain/entities/user.dart';
import 'package:inclusive_app/features/auth/domain/repositories/auth_repository.dart';

class LoginWithEmail {
  final AuthRepository repository;

  LoginWithEmail(this.repository);

  Future<User> call(String email, String password) {
    return repository.loginWithEmail(email, password);
  }
}
