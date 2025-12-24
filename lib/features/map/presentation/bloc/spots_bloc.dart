import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inclusivecity_frontend/features/map/domain/usecases/get_user_spots.dart';
import 'package:inclusivecity_frontend/features/map/domain/usecases/save_spot.dart';
import 'package:inclusivecity_frontend/features/map/presentation/bloc/spots_event.dart';

export 'spots_event.dart'; // Exportar eventos y estados

class SpotsBloc extends Bloc<SpotsEvent, SpotsState> {
  final SaveSpot saveSpot;
  final GetUserSpots getUserSpots;

  SpotsBloc({
    required this.saveSpot,
    required this.getUserSpots,
  }) : super(SpotsInitial()) {
    on<SaveSpotEvent>(_onSaveSpot);
    on<LoadUserSpotsEvent>(_onLoadUserSpots);
  }

  Future<void> _onSaveSpot(
    SaveSpotEvent event,
    Emitter<SpotsState> emit,
  ) async {
    emit(SpotsLoading());

    final result = await saveSpot(event.spot);

    result.fold(
      (failure) => emit(SpotsError(failure.message)),
      (spot) => emit(SpotSaved(spot)),
    );
  }

  Future<void> _onLoadUserSpots(
    LoadUserSpotsEvent event,
    Emitter<SpotsState> emit,
  ) async {
    emit(SpotsLoading());

    final result = await getUserSpots(event.userId);

    result.fold(
      (failure) => emit(SpotsError(failure.message)),
      (spots) => emit(SpotsLoaded(spots)),
    );
  }
}
