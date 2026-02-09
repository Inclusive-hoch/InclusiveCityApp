import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_firebase_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthFirebaseDataSource firebase;

  AuthRepositoryImpl(this.firebase);

  @override
  Future<User> loginWithEmail(String email, String password) async {
    final userModel = await firebase.loginWithEmail(email, password);
    return userModel.toEntity();
  }

  @override
  Future<User> loginWithGoogle() async {
    final userModel = await firebase.loginWithGoogle();
    return userModel.toEntity();
  }

  @override
  Future<User> registerWithEmail(
    String name,
    String email,
    String password,
  ) async {
    final userModel = await firebase.registerWithEmail(name, email, password);
    return userModel.toEntity();
  }

  @override
  Future<User?> getCurrentUser() async {
    final userModel = firebase.getCurrentUser();
    return userModel?.toEntity();
  }

  @override
  Future<void> logout() async {
    await firebase.logout();
  }
}
