abstract class AuthEvent {}

class AuthStarted extends AuthEvent {}

class LoginWithEmailRequested extends AuthEvent {
  final String email;
  final String password;

  LoginWithEmailRequested(this.email, this.password);
}

class LoginWithGoogleRequested extends AuthEvent {}

class RegisterWithEmailRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;

  RegisterWithEmailRequested(this.name, this.email, this.password);
}

class LogoutRequested extends AuthEvent {}
