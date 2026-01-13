abstract class AuthEvent {}

class AuthStarted extends AuthEvent {}

class LoginWithEmailRequested extends AuthEvent {
  final String email;
  final String password;

  LoginWithEmailRequested(this.email, this.password);
}

class LoginWithGoogleRequested extends AuthEvent {}

class LogoutRequested extends AuthEvent {}
