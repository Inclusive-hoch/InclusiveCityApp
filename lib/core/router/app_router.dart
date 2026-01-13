import 'package:go_router/go_router.dart';
import 'package:inclusive_app/core/router/auth_router_notifier.dart';
import 'package:inclusive_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:inclusive_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:inclusive_app/features/auth/presentation/pages/auth_page.dart';
import 'package:inclusive_app/features/auth/presentation/views/login_form.dart';
import 'package:inclusive_app/features/map_view/presentation/pages/map_page.dart';

GoRouter createRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: AuthRouterNotifier(authBloc),

    redirect: (context, state) {
      final authState = authBloc.state;
      final isLogin = state.matchedLocation == '/login';

      if (authState is AuthAuthenticated) {
        return isLogin ? '/map' : null;
      }

      if (authState is AuthUnauthenticated) {
        return isLogin ? null : '/login';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const AuthPage()),
      GoRoute(path: '/login_form', builder: (_, __) => const LoginForm()),
      GoRoute(path: '/map', builder: (_, __) => const MapPage()),
    ],
  );
}
