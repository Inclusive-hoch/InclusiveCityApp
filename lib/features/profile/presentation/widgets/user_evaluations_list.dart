import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:inclusive_app/core/theme/app_color.dart';
import 'package:inclusive_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:inclusive_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:inclusive_app/features/places/presentation/bloc/place_bloc.dart';
import 'package:inclusive_app/features/profile/application/bloc/user_evaluation_bloc.dart';
import 'package:inclusive_app/features/profile/application/bloc/user_evaluation_event.dart';
import 'package:inclusive_app/features/profile/application/bloc/user_evaluation_state.dart';
import 'package:inclusive_app/features/profile/presentation/widgets/user_evaluation_card.dart';

/// Widget que muestra la lista de evaluaciones del usuario
class UserEvaluationsList extends StatefulWidget {
  const UserEvaluationsList({super.key});

  @override
  State<UserEvaluationsList> createState() => _UserEvaluationsListState();
}

class _UserEvaluationsListState extends State<UserEvaluationsList> {
  @override
  void initState() {
    super.initState();
    // Obtener el userId del AuthBloc y cargar las evaluaciones
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<UserEvaluationBloc>().add(
        RefreshUserEvaluations(userId: authState.user.uid),
      );
    }
  }

  /// Navega al mapa y muestra los detalles del lugar
  void _navigateToPlaceDetails(BuildContext context, String placeId) {
    // Disparar evento para cargar detalles del lugar
    context.read<PlaceBloc>().add(SelectPlaceEvent(placeId));
    // Navegar al mapa
    context.go('/map');
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserEvaluationBloc, UserEvaluationState>(
      builder: (context, state) {
        if (state is UserEvaluationLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(color: AppColor.primaryNormal),
            ),
          );
        }

        if (state is UserEvaluationError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColor.redDark,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColor.neutralDark),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      final authState = context.read<AuthBloc>().state;
                      if (authState is AuthAuthenticated) {
                        context.read<UserEvaluationBloc>().add(
                          RefreshUserEvaluations(userId: authState.user.uid),
                        );
                      }
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is UserEvaluationEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.rate_review_outlined,
                    color: AppColor.neutralDark,
                    size: 48,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Aún no has realizado evaluaciones',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColor.neutralDark),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is UserEvaluationLoaded) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Mis evaluaciones',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColor.secondaryNormal,
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.evaluations.length,
                itemBuilder: (context, index) {
                  final evaluation = state.evaluations[index];
                  final placeDetails = state.placesDetails[evaluation.placeId];
                  return UserEvaluationCard(
                    evaluation: evaluation,
                    placeName: placeDetails?.name,
                    placeType: placeDetails?.address,
                    photoReference: placeDetails?.photos.isNotEmpty == true
                        ? placeDetails!.photos.first
                        : null,
                    onTap: () => _navigateToPlaceDetails(context, evaluation.placeId),
                  );
                },
              ),
              // Botón para expandir
              Center(
                child: IconButton(
                  onPressed: () {
                    context.push('/profile/evaluations');
                  },
                  icon: const Icon(
                    Icons.expand_more,
                    color: AppColor.primaryNormal,
                    size: 32,
                  ),
                ),
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
