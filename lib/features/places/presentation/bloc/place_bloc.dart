
import 'dart:developer';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_transform/stream_transform.dart';

import 'package:inclusive_app/features/places/domain/usecases/get_place_detail.dart';
import 'package:inclusive_app/features/places/domain/usecases/get_search_history.dart';
import 'package:inclusive_app/features/places/domain/usecases/save_place_to_history.dart';
import 'package:inclusive_app/features/places/domain/usecases/search_places.dart';
import 'package:inclusive_app/features/places/domain/entities/place_details.dart';
import 'package:inclusive_app/features/places/domain/entities/place_search_result.dart';

part 'place_event.dart';
part 'place_state.dart';

/// Transforma eventos aplicando debounce para evitar múltiples requests.
/// Útil para búsquedas en tiempo real.
EventTransformer<E> debounceTransformer<E>(Duration duration) {
  return (events, mapper) {
    return events.debounce(duration).switchMap(mapper);
  };
}

/// BLoC para gestionar búsqueda, selección y detalles de lugares.
/// Coordina la interacción entre la capa de presentación y los casos de uso.
class PlaceBloc extends Bloc<PlacesEvent, PlacesState> {
  /// Caso de uso para buscar lugares.
  final SearchPlaces searchPlacesUseCase;
  
  /// Caso de uso para obtener detalles de un lugar.
  final GetPlaceDetails getPlaceDetailsUseCase;
  
  /// Caso de uso para obtener historial de búsquedas.
  final GetSearchHistory getSearchHistoryUseCase;
  
  /// Caso de uso para guardar lugar en historial.
  final SavePlaceToHistory savePlaceToHistoryUseCase;

  PlaceBloc({
    required this.getPlaceDetailsUseCase,
    required this.getSearchHistoryUseCase,
    required this.savePlaceToHistoryUseCase,
    required this.searchPlacesUseCase,
  }) : super(PlacesInitial()) {
    on<SearchPlacesEvent>(
      _onSearchPlaces,
      transformer: debounceTransformer(const Duration(milliseconds: 500)),
    );

    on<ClearSearchEvent>(_onClearSearch);

    on<SelectPlaceEvent>(_onSelectPlace);

    on<LoadSearchHistoryEvent>(_onLoadSearchHistory);

    on<SaveToHistoryEvent>(_onSaveToHistory);
  }

  /// Maneja la búsqueda de lugares con query.
  /// Si el query está vacío, carga el historial de búsquedas.
  /// Aplica debounce de 500ms para optimizar requests.
  Future<void> _onSearchPlaces(
    SearchPlacesEvent event,
    Emitter<PlacesState> emit,
  ) async {
    if (event.query.isEmpty) {
      try {
        final history = await getSearchHistoryUseCase();
        emit(SearchHistoryLoaded(history));
      } catch (e) {
        emit(PlacesInitial());
      }
      return;
    }

    emit(PlacesLoading());

    try {
      final suggestions = await searchPlacesUseCase(event.query);

      if (suggestions.isEmpty) {
        emit(PlacesEmpty());
      } else {
        emit(PlacesLoaded(suggestions));
      }
    } catch (e) {
      log('Error en búsqueda: $e');
      emit(PlacesError('No se pudo completar la búsqueda. Intenta de nuevo'));
    }
  }

  /// Limpia los resultados de búsqueda y retorna al estado inicial.
  Future<void> _onClearSearch(
    ClearSearchEvent event,
    Emitter<PlacesState> emit,
  ) async {
    emit(PlacesInitial());
  }

  /// Selecciona un lugar y obtiene sus detalles.
  /// Si el lugar proviene de resultados de búsqueda, lo guarda en historial.
  Future<void> _onSelectPlace(
    SelectPlaceEvent event,
    Emitter<PlacesState> emit,
  ) async {
    if (state is PlacesLoaded) {
      final suggestion = (state as PlacesLoaded).suggestions.firstWhere(
        (s) => s.placeId == event.placeId,
      );

      add(SaveToHistoryEvent(suggestion));
    }

    try {
      emit(PlaceDetailsLoading());

      final placeDetails = await getPlaceDetailsUseCase(event.placeId);
      
      emit(PlaceDetailsLoaded(placeDetails));
    } catch (e) {
      emit(PlacesError('No se pudieron cargar los detalles del lugar'));
    }
  }

  Future<void> _onLoadSearchHistory(
      LoadSearchHistoryEvent event, Emitter<PlacesState> emit) async {
    try {
      final history = await getSearchHistoryUseCase();
      emit(SearchHistoryLoaded(history));
    } catch (e) {
      emit(PlacesError('No se pudo cargar el historial de búsquedas'));
    }
  }
/// Guarda un lugar en el historial de búsquedas.
  /// No emite estados, opera de forma silenciosa.
  
  Future<void> _onSaveToHistory(
      SaveToHistoryEvent event, Emitter<PlacesState> emit) async {
    try {
      await savePlaceToHistoryUseCase(event.place);
    } catch (e) {
      log('Error al guardar en historial: $e');
    }
  }
}
