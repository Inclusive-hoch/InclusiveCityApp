import 'package:inclusive_app/features/auth/domain/entities/user.dart';
import 'package:inclusive_app/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentUser {
  final AuthRepository repository;

  GetCurrentUser(this.repository);

  Future<User?> call() {
    return repository.getCurrentUser();
  }
}
