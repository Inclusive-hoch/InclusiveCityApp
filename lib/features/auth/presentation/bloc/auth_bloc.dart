import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inclusive_app/features/auth/domain/usecases/get_current_user.dart';
import 'package:inclusive_app/features/auth/domain/usecases/login_with_email.dart';
import 'package:inclusive_app/features/auth/domain/usecases/login_with_google.dart';
import 'package:inclusive_app/features/auth/domain/usecases/logout.dart';
import 'package:inclusive_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:inclusive_app/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginWithEmail loginWithEmail;
  final LoginWithGoogle loginWithGoogle;
  final GetCurrentUser getCurrentUser;
  final Logout logout;

  AuthBloc({
    required this.loginWithEmail,
    required this.loginWithGoogle,
    required this.getCurrentUser,
    required this.logout,
  }) : super(AuthInitial()) {
    on<AuthStarted>(_onStarted);
    on<LoginWithEmailRequested>(_onLoginEmail);
    on<LoginWithGoogleRequested>(_onLoginGoogle);
    on<LogoutRequested>(_onLogout);
  }

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    final user = await getCurrentUser();
    emit(user != null ? AuthAuthenticated(user) : AuthUnauthenticated());
  }

  Future<void> _onLoginEmail(
    LoginWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final user = await loginWithEmail(event.email, event.password);
    emit(AuthAuthenticated(user));
  }

  Future<void> _onLoginGoogle(
    LoginWithGoogleRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final user = await loginWithGoogle();
    emit(AuthAuthenticated(user));
  }

  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    await logout();
    emit(AuthUnauthenticated());
  }
}
