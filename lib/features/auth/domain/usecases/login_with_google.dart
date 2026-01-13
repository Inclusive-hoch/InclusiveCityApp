import 'package:inclusive_app/features/auth/domain/entities/user.dart';
import 'package:inclusive_app/features/auth/domain/repositories/auth_repository.dart';

class LoginWithGoogle {
  final AuthRepository repository;

  LoginWithGoogle(this.repository);

  Future<User> call() {
    return repository.loginWithGoogle();
  }
}
