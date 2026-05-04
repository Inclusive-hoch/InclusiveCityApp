import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inclusive_app/core/router/app_router.dart';
import 'package:inclusive_app/core/auth/firebase_auth_service.dart';
import 'package:inclusive_app/features/reviews/domain/usecases/save_place_rate_choice_usecase.dart';
import 'package:inclusive_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:inclusive_app/features/map_view/presentation/bloc/map_bloc.dart';
import 'package:inclusive_app/features/places/presentation/bloc/place_bloc.dart';
import 'package:inclusive_app/features/routing/application/bloc/route_bloc.dart';
import 'package:inclusive_app/features/spot/presentation/bloc/spot_bloc.dart';
import 'package:inclusive_app/injection_container.dart' as di;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authBloc = di.sl<AuthBloc>();
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<FirebaseAuthService>(
          create: (_) => di.sl<FirebaseAuthService>(),
        ),
        RepositoryProvider<SavePlaceRateChoiceUseCase>(
          create: (_) => di.sl<SavePlaceRateChoiceUseCase>(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(create: (_) => authBloc),
          BlocProvider<MapBloc>(create: (_) => di.sl<MapBloc>()),
          BlocProvider(create: (context) => di.sl<PlaceBloc>()),
          BlocProvider(create: (context) => di.sl<RouteBloc>()),
          BlocProvider(create: (context) => di.sl<SpotBloc>()),
        ],
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: createRouter(authBloc),
        ),
      ),
    );
  }
}
