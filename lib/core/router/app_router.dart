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
import '../../injection_container.dart' as di;

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
      GoRoute(path: '/login', builder: (context, state) => const AuthPage()),
      GoRoute(path: '/login_form', builder: (context, state) => const LoginForm()),
      GoRoute(path: '/register_form', builder: (context, state) => const RegisterForm()),
      GoRoute(
        path: '/map',
        builder: (context, state) => BlocProvider(
          create: (_) => di.sl<IncidentReportBloc>(),
          child: const MapPage(),
        ),
      ),
      GoRoute(path: '/profile', builder: (context, state) => const ProfilePage()),
      GoRoute(
        path: '/profile/details',
        builder: (context, state) => const ProfileDetailsPage(),
      ),
      GoRoute(
        path: '/profile/evaluations',
        builder: (context, state) => const EvaluatedPlacesPage(),
      ),
      GoRoute(
        path: '/route-selection',
        builder: (context, state) {
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
        builder: (context, state) => const CustomSpotsListsPage(),
      ),
      GoRoute(
        path: '/list-detail',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return ListDetailPage(
            listName: extra['listName'] as String,
          );
        },
      ),
    ],
  );
}
