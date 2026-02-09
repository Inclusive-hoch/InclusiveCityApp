import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inclusive_app/features/places/domain/entities/place_details.dart';
import 'package:inclusive_app/features/places/domain/repositories/place_repository.dart';
import 'package:inclusive_app/features/profile/application/bloc/user_evaluation_event.dart';
import 'package:inclusive_app/features/profile/application/bloc/user_evaluation_state.dart';
import 'package:inclusive_app/features/profile/domain/usecases/get_user_evaluations.dart';

/// BLoC para gestionar las evaluaciones del usuario
class UserEvaluationBloc extends Bloc<UserEvaluationEvent, UserEvaluationState> {
  final GetUserEvaluations getUserEvaluations;
  final PlaceRepository placeRepository;

  UserEvaluationBloc({
    required this.getUserEvaluations,
    required this.placeRepository,
  }) : super(UserEvaluationInitial()) {
    on<LoadUserEvaluations>(_onLoadUserEvaluations);
    on<RefreshUserEvaluations>(_onRefreshUserEvaluations);
  }

  Future<Map<String, PlaceDetails>> _loadPlacesDetails(
    List<String> placeIds,
  ) async {
    final Map<String, PlaceDetails> placesDetails = {};
    for (final placeId in placeIds) {
      try {
        final details = await placeRepository.getPlaceDetails(placeId);
        placesDetails[placeId] = details;
      } catch (_) {
        // Si falla la carga de un lugar, continuamos con los demás
      }
    }
    return placesDetails;
  }

  Future<void> _onLoadUserEvaluations(
    LoadUserEvaluations event,
    Emitter<UserEvaluationState> emit,
  ) async {
    emit(UserEvaluationLoading());
    try {
      final evaluations = await getUserEvaluations(event.userId);
      if (evaluations.isEmpty) {
        emit(UserEvaluationEmpty());
      } else {
        // Obtener los placeIds únicos
        final placeIds = evaluations.map((e) => e.placeId).toSet().toList();
        final placesDetails = await _loadPlacesDetails(placeIds);
        emit(UserEvaluationLoaded(evaluations, placesDetails: placesDetails));
      }
    } catch (e) {
      emit(UserEvaluationError(e.toString()));
    }
  }

  Future<void> _onRefreshUserEvaluations(
    RefreshUserEvaluations event,
    Emitter<UserEvaluationState> emit,
  ) async {
    try {
      final evaluations = await getUserEvaluations(event.userId);
      if (evaluations.isEmpty) {
        emit(UserEvaluationEmpty());
      } else {
        final placeIds = evaluations.map((e) => e.placeId).toSet().toList();
        final placesDetails = await _loadPlacesDetails(placeIds);
        emit(UserEvaluationLoaded(evaluations, placesDetails: placesDetails));
      }
    } catch (e) {
      emit(UserEvaluationError(e.toString()));
    }
  }
}