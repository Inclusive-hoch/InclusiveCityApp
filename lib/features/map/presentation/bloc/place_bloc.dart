import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:inclusivecity_frontend/features/map/domain/entities/place_details.dart';
import 'package:inclusivecity_frontend/features/map/domain/entities/place_suggestion.dart';
import 'package:inclusivecity_frontend/features/map/domain/usecases/search_places.dart';
import 'package:inclusivecity_frontend/features/map/domain/usecases/get_place_detail.dart';
import 'package:inclusivecity_frontend/features/map/domain/usecases/get_search_history.dart';
import 'package:inclusivecity_frontend/features/map/domain/usecases/save_place_to_history.dart';
import 'package:stream_transform/stream_transform.dart';

part 'place_event.dart';
part 'place_state.dart';

EventTransformer<E> debounceTransformer<E>(Duration duration) {
  return (events, mapper) {
    return events.debounce(duration).switchMap(mapper);
  };
}

class PlacesBloc extends Bloc<PlacesEvent, PlacesState> {
  final SearchPlaces searchPlacesUseCase;
  final GetPlaceDetails getPlaceDetailsUseCase;
  final GetSearchHistory getSearchHistoryUseCase;
  final SavePlaceToHistory savePlaceToHistoryUseCase;

  PlacesBloc({
    required this.searchPlacesUseCase,
    required this.getPlaceDetailsUseCase,
    required this.getSearchHistoryUseCase,
    required this.savePlaceToHistoryUseCase,
  }) : super(PlacesInitial()) {
    on<SearchPlacesEvent>(
      _onSearchPlaces,
      transformer: debounceTransformer(const Duration(milliseconds: 500)),
    );

    on<ClearSearchEvent>(_onClearSearch);
    
    on<GetUserLocationEvent>(_onGetUserLocation);
    
    on<SelectPlaceEvent>(_onSelectPlace);

    on<LoadSearchHistoryEvent>(_onLoadSearchHistory);

    on<SaveToHistoryEvent>(_onSaveToHistory);
  }

  Future<void> _onSearchPlaces(
      SearchPlacesEvent event, Emitter<PlacesState> emit) async {
    if (event.query.isEmpty) {
      // Si la búsqueda está vacía, cargar historial en lugar de mostrar estado inicial
      final failureOrHistory = await getSearchHistoryUseCase();
      failureOrHistory.fold(
        (failure) => emit(PlacesInitial()),
        (history) => emit(SearchHistoryLoaded(history)),
      );
      return;
    }

    emit(PlacesLoading()); 

    final failureOrSuggestions = await searchPlacesUseCase(event.query);

    failureOrSuggestions.fold(
      (failure) => emit(PlacesError(failure.message)), 
      (suggestions) { 
        if (suggestions.isEmpty) {
          emit(PlacesEmpty()); 
        } else {
          emit(PlacesLoaded(suggestions));
        }
      },
    );
  }

  Future<void> _onClearSearch(
      ClearSearchEvent event, Emitter<PlacesState> emit) async {
    emit(PlacesInitial());
  }

  Future<void> _onGetUserLocation(
      GetUserLocationEvent event, Emitter<PlacesState> emit) async {
    try {
      // Verificar si los servicios de ubicación están habilitados
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        emit(PlacesError("Los servicios de ubicación están deshabilitados."));
        return;
      }

      // Verificar permisos
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          emit(PlacesError("Permiso de ubicación denegado."));
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        emit(PlacesError(
            "Los permisos de ubicación están permanentemente denegados. Actívalos en configuración."));
        return;
      }

      // Obtener la ubicación actual
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      
      emit(UserLocationLoaded(position.latitude, position.longitude));
    } catch (e) {
      emit(PlacesError(
          "No se pudo obtener la ubicación: ${e.toString()}"));
    }
  }

  Future<void> _onSelectPlace(
      SelectPlaceEvent event, Emitter<PlacesState> emit) async {
    // Guardar en el historial ANTES de obtener los detalles
    if (state is PlacesLoaded) {
      final suggestion = (state as PlacesLoaded)
          .suggestions
          .firstWhere((s) => s.placeId == event.placeId);
      
      add(SaveToHistoryEvent(suggestion));
    }

    try {
      emit(PlaceDetailsLoading());

      final failureOrDetails = await getPlaceDetailsUseCase(event.placeId);

      failureOrDetails.fold(
        (failure) => emit(PlacesError(failure.message)),
        (placeDetails) => emit(PlaceDetailsLoaded(placeDetails)),
      );
    } catch (e) {
      emit(PlacesError("Error al obtener detalles del lugar: ${e.toString()}"));
    }
  }

  Future<void> _onLoadSearchHistory(
      LoadSearchHistoryEvent event, Emitter<PlacesState> emit) async {
    try {
      final failureOrHistory = await getSearchHistoryUseCase();

      failureOrHistory.fold(
        (failure) => emit(PlacesError(failure.message)),
        (history) => emit(SearchHistoryLoaded(history)),
      );
    } catch (e) {
      emit(PlacesError("Error al cargar el historial: ${e.toString()}"));
    }
  }

  Future<void> _onSaveToHistory(
      SaveToHistoryEvent event, Emitter<PlacesState> emit) async {
    try {
      await savePlaceToHistoryUseCase(event.place);
    } catch (e) {
      // Silenciosamente fallar, no es crítico
      print("Error al guardar en historial: ${e.toString()}");
    }
  }
}