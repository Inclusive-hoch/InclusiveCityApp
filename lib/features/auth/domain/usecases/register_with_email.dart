import 'package:inclusive_app/features/auth/domain/entities/user.dart';
import 'package:inclusive_app/features/auth/domain/repositories/auth_repository.dart';

class RegisterWithEmail {
  final AuthRepository repository;

  RegisterWithEmail(this.repository);

  Future<User> call(String name, String email, String password) {
    return repository.registerWithEmail(name, email, password);
  }
}
