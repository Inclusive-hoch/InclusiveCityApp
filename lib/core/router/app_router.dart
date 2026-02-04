import 'package:go_router/go_router.dart';
import 'package:inclusive_app/core/router/auth_router_notifier.dart';
import 'package:inclusive_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:inclusive_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:inclusive_app/features/auth/presentation/pages/auth_page.dart';
import 'package:inclusive_app/features/auth/presentation/views/login_form.dart';
import 'package:inclusive_app/features/map_view/presentation/pages/map_page.dart';
import 'package:inclusive_app/features/profile/presentation/pages/profile_details_page.dart';
import 'package:inclusive_app/features/profile/presentation/pages/profile_page.dart';
import 'package:inclusive_app/features/profile/presentation/views/profile_details_view.dart';

GoRouter createRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: AuthRouterNotifier(authBloc),

    redirect: (context, state) {
      final authState = authBloc.state;
      final publicRoutes = ['/login', '/login_form', '/'];
      final isPublicRoute = publicRoutes.contains(state.matchedLocation);

      if (authState is AuthAuthenticated) {
        return isPublicRoute && state.matchedLocation != '/' ? '/map' : null;
      }

      if (authState is AuthUnauthenticated) {
        return isPublicRoute ? null : '/login';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const AuthPage()),
      GoRoute(path: '/login_form', builder: (_, __) => const LoginForm()),
      GoRoute(path: '/map', builder: (_, __) => const MapPage()),
      GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
      GoRoute(path: '/profile/details', builder: (_, __) => const ProfileDetailsPage()),
    ],
  );
}
