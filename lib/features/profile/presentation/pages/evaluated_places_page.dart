import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inclusive_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:inclusive_app/features/profile/application/bloc/user_evaluation_bloc.dart';
import 'package:inclusive_app/features/profile/presentation/views/evaluated_places_view.dart';
import 'package:inclusive_app/injection_container.dart' as sl;

/// Página que muestra la lista completa de lugares evaluados por el usuario
class EvaluatedPlacesPage extends StatelessWidget {
  const EvaluatedPlacesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl.sl<AuthBloc>()),
        BlocProvider(create: (context) => sl.sl<UserEvaluationBloc>()),
      ],
      child: const EvaluatedPlacesView(),
    );
  }
}
