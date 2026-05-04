import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:inclusive_app/core/theme/app_color.dart';
import 'package:inclusive_app/core/auth/firebase_auth_service.dart';
import 'package:inclusive_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:inclusive_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:inclusive_app/features/places/presentation/bloc/place_bloc.dart';
import 'package:inclusive_app/features/profile/application/bloc/user_evaluation_bloc.dart';
import 'package:inclusive_app/features/profile/application/bloc/user_evaluation_event.dart';
import 'package:inclusive_app/features/profile/application/bloc/user_evaluation_state.dart';
import 'package:inclusive_app/features/profile/presentation/widgets/user_evaluation_card.dart';

/// Vista que muestra la lista completa de lugares evaluados por el usuario
class EvaluatedPlacesView extends StatefulWidget {
  const EvaluatedPlacesView({super.key});

  @override
  State<EvaluatedPlacesView> createState() => _EvaluatedPlacesViewState();
}

class _EvaluatedPlacesViewState extends State<EvaluatedPlacesView> {
  String _authToken = '';

  @override
  void initState() {
    super.initState();
    _loadAuthToken();
    _loadEvaluations();
  }

  void _loadEvaluations() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<UserEvaluationBloc>().add(
        RefreshUserEvaluations(userId: authState.user.uid),
      );
    }
  }

  Future<void> _loadAuthToken() async {
    final token = await context.read<FirebaseAuthService>().getIdToken();
    if (!mounted) return;
    setState(() {
      _authToken = token;
    });
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
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Lugares evaluados',
          style: TextStyle(
            color: AppColor.secondaryNormal,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: AppColor.primaryNormal, size: 30),
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.go('/map');
            },
            icon: const Icon(Icons.close, color: AppColor.primaryNormal, size: 30),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          const Divider(color: AppColor.primaryLight, height: 1),
          Expanded(
            child: BlocBuilder<UserEvaluationBloc, UserEvaluationState>(
              builder: (context, state) {
                if (state is UserEvaluationLoading) {
                  return _buildLoadingState();
                }

                if (state is UserEvaluationError) {
                  return _buildErrorState(state.message);
                }

                if (state is UserEvaluationEmpty) {
                  return _buildEmptyState();
                }

                if (state is UserEvaluationLoaded) {
                  return _buildLoadedState(state);
                }

                // Estado inicial - mostrar loading
                return _buildLoadingState();
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Widget de estado de carga con el icono de recarga animado
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1500),
              builder: (context, value, child) {
                return Transform.rotate(
                  angle: value * 2 * 3.14159,
                  child: child,
                );
              },
              onEnd: () {
                // Reiniciar animación si aún está cargando
                if (mounted) {
                  setState(() {});
                }
              },
              child: Icon(
                Icons.refresh_rounded,
                size: 80,
                color: AppColor.primaryNormal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget de estado de error/sin conexión con botón de recarga
  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono de recarga para reintento
            GestureDetector(
              onTap: _loadEvaluations,
              child: Icon(
                Icons.refresh_rounded,
                size: 80,
                color: AppColor.primaryNormal,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No se pudieron cargar las evaluaciones',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColor.neutralDark,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Toca para reintentar',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColor.primaryNormal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget de estado vacío (sin evaluaciones)
  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rate_review_outlined,
              color: AppColor.neutralDark,
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              'Aún no has realizado evaluaciones',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColor.neutralDark,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget de estado con evaluaciones cargadas
  Widget _buildLoadedState(UserEvaluationLoaded state) {
    return RefreshIndicator(
      color: AppColor.primaryNormal,
      onRefresh: () async {
        _loadEvaluations();
        // Esperar un poco para dar feedback visual
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16),
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
            authToken: _authToken,
            onTap: () => _navigateToPlaceDetails(context, evaluation.placeId),
          );
        },
      ),
    );
  }
}
