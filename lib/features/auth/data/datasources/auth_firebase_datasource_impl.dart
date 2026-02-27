import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'auth_firebase_datasource.dart';
import '../models/user_model.dart';

class AuthFirebaseDataSourceImpl implements AuthFirebaseDataSource {
  final FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;

  AuthFirebaseDataSourceImpl(this.firebaseAuth, this.googleSignIn);

  @override
  Future<UserModel> loginWithEmail(String email, String password) async {
    final cred = await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Reload user to get fresh data including displayName
    await cred.user?.reload();
    final user = firebaseAuth.currentUser;

    // Get displayName from providerData if not available in main user object
    String? displayName = user?.displayName;
    if (displayName == null && user?.providerData != null) {
      for (var provider in user!.providerData) {
        if (provider.displayName != null) {
          displayName = provider.displayName;
          break;
        }
      }
    }

    // Debug logging
    print('Firebase User Data (Email Login):');
    print('  - UID: ${user?.uid}');
    print('  - Email: ${user?.email}');
    print('  - DisplayName: ${user?.displayName}');
    print('  - DisplayName from providerData: $displayName');
    print('  - PhotoURL: ${user?.photoURL}');
    print(
      '  - ProviderData: ${user?.providerData.map((p) => p.providerId).toList()}',
    );

    return _createUserModel(user, displayName);
  }

  @override
  Future<UserModel> loginWithGoogle() async {
    // Sign in with Google - this will show account picker
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      // User canceled the sign-in
      throw Exception('Google sign in aborted by user');
    }

    // Get Google authentication credentials
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create Firebase credential from Google tokens
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in to Firebase with the Google credential
    final cred = await firebaseAuth.signInWithCredential(credential);

    // Reload user to get fresh data including displayName
    await cred.user?.reload();
    final user = firebaseAuth.currentUser;

    // Get displayName from providerData if not available in main user object
    String? displayName = user?.displayName;
    if (displayName == null && user?.providerData != null) {
      for (var provider in user!.providerData) {
        if (provider.displayName != null) {
          displayName = provider.displayName;
          break;
        }
      }
    }

    // Debug logging
    print('Firebase User Data (Google Login):');
    print('  - UID: ${user?.uid}');
    print('  - Email: ${user?.email}');
    print('  - DisplayName: ${user?.displayName}');
    print('  - DisplayName from providerData: $displayName');
    print('  - PhotoURL: ${user?.photoURL}');
    print(
      '  - ProviderData: ${user?.providerData.map((p) => p.providerId).toList()}',
    );

    return _createUserModel(user, displayName);
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = firebaseAuth.currentUser;
    if (user == null) return null;

    // Reload user to ensure we have the latest data (important for maintained sessions)
    await user.reload();
    final reloadedUser = firebaseAuth.currentUser;
    if (reloadedUser == null) return null;

    // Get displayName from providerData if not available in main user object
    String? displayName = reloadedUser.displayName;
    if (displayName == null && reloadedUser.providerData.isNotEmpty) {
      for (var provider in reloadedUser.providerData) {
        if (provider.displayName != null) {
          displayName = provider.displayName;
          break;
        }
      }
    }

    // Debug logging
    print('Firebase Current User Data:');
    print('  - UID: ${reloadedUser.uid}');
    print('  - Email: ${reloadedUser.email}');
    print('  - DisplayName: ${reloadedUser.displayName}');
    print('  - DisplayName from providerData: $displayName');
    print('  - PhotoURL: ${reloadedUser.photoURL}');
    print(
      '  - ProviderData: ${reloadedUser.providerData.map((p) => p.providerId).toList()}',
    );

    return _createUserModel(reloadedUser, displayName);
  }

  @override
  Future<UserModel> registerWithEmail(
    String name,
    String email,
    String password,
  ) async {
    // Create user with email and password
    final cred = await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Update user profile with display name
    await cred.user?.updateProfile(displayName: name);

    // Reload to get updated profile
    await cred.user?.reload();
    final user = firebaseAuth.currentUser;

    // Get displayName from providerData or updated profile
    String? displayName = user?.displayName;
    if (displayName == null) {
      // Use the name provided during registration as fallback
      displayName = name;
      // Also check providerData
      if (user?.providerData != null) {
        for (var provider in user!.providerData) {
          if (provider.displayName != null) {
            displayName = provider.displayName;
            break;
          }
        }
      }
    }

    // Debug logging
    print('Firebase User Data (Registration):');
    print('  - UID: ${user?.uid}');
    print('  - Email: ${user?.email}');
    print('  - DisplayName: ${user?.displayName}');
    print('  - DisplayName from providerData: $displayName');
    print('  - PhotoURL: ${user?.photoURL}');

    return _createUserModel(user, displayName);
  }

  @override
  Future<void> logout() async {
    // Sign out from Firebase
    await firebaseAuth.signOut();

    // Sign out from Google (clears cached Google session)
    // This ensures next login will show account picker
    await googleSignIn.signOut();
  }

  // Helper method to create UserModel with displayName from providerData
  UserModel _createUserModel(dynamic user, String? displayName) {
    return UserModel(
      uid: user?.uid ?? '',
      email: user?.email ?? '',
      name: displayName,
      profilePictureUrl: user?.photoURL,
    );
  }
}
