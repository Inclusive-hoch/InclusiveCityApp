import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';
import 'auth_firebase_datasource.dart';
import '../models/user_model.dart';

class AuthFirebaseDataSourceImpl implements AuthFirebaseDataSource {
  final FirebaseAuth firebaseAuth;

  AuthFirebaseDataSourceImpl(this.firebaseAuth);

  Future<void> _logFirebaseToken() async {
    final user = firebaseAuth.currentUser;
    if (user != null) {
      final token = await user.getIdToken();
      developer.log('🔑 Firebase ID Token: $token', name: 'FirebaseAuth');
    }
  }

  @override
  Future<UserModel> loginWithEmail(String email, String password) async {
    final cred = await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _logFirebaseToken();
    return UserModel.fromFirebase(cred.user);
  }

  @override
  Future<UserModel> loginWithGoogle() async {
    final cred = await firebaseAuth.signInWithProvider(GoogleAuthProvider());
    await _logFirebaseToken();
    return UserModel.fromFirebase(cred.user);
  }

  @override
  UserModel? getCurrentUser() {
    final user = firebaseAuth.currentUser;
    if (user == null) return null;
    _logFirebaseToken(); // Log token when getting current user
    return UserModel.fromFirebase(user);
  }

  @override
  Future<void> logout() async {
    await firebaseAuth.signOut();
  }
}
