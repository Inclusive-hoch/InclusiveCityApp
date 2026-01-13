import 'package:inclusive_app/features/auth/domain/repositories/auth_repository.dart'
    show AuthRepository;

class Logout {
  final AuthRepository repository;

  Logout(this.repository);

  Future<void> call() {
    return repository.logout();
  }
}
