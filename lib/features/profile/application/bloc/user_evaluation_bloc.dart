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
    // generar una lista de peticiones en proceso 
    // el .map itera sobre la lista sin esperar 
    final futures = placeIds.map((placeId) async{
      try {
        final details = await placeRepository.getPlaceDetails(placeId);
        //retornar un MapEntry
        return MapEntry(placeId, details);
      }catch (_){
        //si falla alguno retorna null sin detener el resto de peticiones
        return null;
      }
    });
    // Ejecutar todas las peticiones al mismo tiempo y espera que 
    final results = await Future.wait(futures);
    // se filtran las peticiones nulas y se construye el mapa de evaluaciones
    return Map.fromEntries(
      results.whereType<MapEntry<String, PlaceDetails>>()
    );

  }

  Future<void> _onLoadUserEvaluations(
    LoadUserEvaluations event,
    Emitter<UserEvaluationState> emit,
  ) async {
    emit(UserEvaluationLoading());
    try {
      final evaluations = await getUserEvaluations(
        event.userId,
        forceRefresh: event.forceRefresh,
      );
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
      final evaluations = await getUserEvaluations(
        event.userId,
        forceRefresh: true,
      );
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