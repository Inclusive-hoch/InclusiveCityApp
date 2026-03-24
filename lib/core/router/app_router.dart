import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inclusive_app/core/router/auth_router_notifier.dart';
import 'package:inclusive_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:inclusive_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:inclusive_app/features/incidents/application/bloc/incident_report_bloc.dart';
import 'package:inclusive_app/features/auth/presentation/pages/auth_page.dart';
import 'package:inclusive_app/features/auth/presentation/views/login_form.dart';
import 'package:inclusive_app/features/auth/presentation/views/register_form.dart';
import 'package:inclusive_app/features/map_view/presentation/pages/map_page.dart';
import 'package:inclusive_app/features/profile/presentation/pages/evaluated_places_page.dart';
import 'package:inclusive_app/features/profile/presentation/pages/profile_details_page.dart';
import 'package:inclusive_app/features/profile/presentation/pages/profile_page.dart';
import 'package:inclusive_app/features/routing/presentation/pages/route_selection_page.dart';
import 'package:inclusive_app/features/spot/presentation/pages/custom_spots_lists_page.dart';
import 'package:inclusive_app/features/spot/presentation/pages/list_detail_page.dart';

GoRouter createRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: AuthRouterNotifier(authBloc),

    redirect: (context, state) {
      final authState = authBloc.state;
      final publicRoutes = ['/login', '/login_form', '/register_form', '/'];
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
      GoRoute(path: '/register_form', builder: (_, __) => const RegisterForm()),
      GoRoute(
        path: '/map',
        builder: (_, __) => BlocProvider(
          create: (_) => di.sl<IncidentReportBloc>(),
          child: const MapPage(),
        ),
      ),
      GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
      GoRoute(
        path: '/profile/details',
        builder: (_, __) => const ProfileDetailsPage(),
      ),
      GoRoute(
        path: '/profile/evaluations',
        builder: (_, __) => const EvaluatedPlacesPage(),
      ),
      GoRoute(
        path: '/route-selection',
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>;
          return RouteSelectionPage(
            originLat: extra['originLat'] as double,
            originLng: extra['originLng'] as double,
            destLat: extra['destLat'] as double,
            destLng: extra['destLng'] as double,
            originName: extra['originName'] as String,
            destName: extra['destName'] as String,
          );
        },
      ),
      GoRoute(
        path: '/custom-spots-lists',
        builder: (_, __) => const CustomSpotsListsPage(),
      ),
      GoRoute(
        path: '/list-detail',
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>;
          return ListDetailPage(
            listName: extra['listName'] as String,
          );
        },
      ),
    ],
  );
}
