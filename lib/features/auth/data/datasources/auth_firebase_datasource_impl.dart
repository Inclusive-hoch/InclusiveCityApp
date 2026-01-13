import 'package:firebase_auth/firebase_auth.dart';
import 'auth_firebase_datasource.dart';
import '../models/user_model.dart';

class AuthFirebaseDataSourceImpl implements AuthFirebaseDataSource {
  final FirebaseAuth firebaseAuth;

  AuthFirebaseDataSourceImpl(this.firebaseAuth);

  @override
  Future<UserModel> loginWithEmail(String email, String password) async {
    final cred = await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return UserModel.fromFirebase(cred.user);
  }

  @override
  Future<UserModel> loginWithGoogle() async {
    final cred = await firebaseAuth.signInWithProvider(GoogleAuthProvider());
    return UserModel.fromFirebase(cred.user);
  }

  @override
  UserModel? getCurrentUser() {
    final user = firebaseAuth.currentUser;
    if (user == null) return null;
    return UserModel.fromFirebase(user);
  }

  @override
  Future<void> logout() async {
    await firebaseAuth.signOut();
  }
}
