part of 'place_bloc.dart';

/// Estados del bloc de lugares.
/// Representa los diferentes estados durante la búsqueda, carga y gestión de lugares.
abstract class PlacesState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Estado inicial del bloc de lugares.
class PlacesInitial extends PlacesState {}

/// Estado de carga durante la búsqueda de lugares.
class PlacesLoading extends PlacesState {}

/// Estado cuando se han cargado sugerencias de lugares.
class PlacesLoaded extends PlacesState {
  /// Lista de sugerencias de lugares encontrados.
  final List<PlaceSearchResult> suggestions;

  PlacesLoaded(this.suggestions);

  @override
  List<Object> get props => [suggestions];
}

/// Estado cuando la búsqueda no retornó resultados.
class PlacesEmpty extends PlacesState {}

/// Estado de error durante operaciones con lugares.
class PlacesError extends PlacesState {
  /// Mensaje descriptivo del error.
  final String message;

  PlacesError(this.message);

  @override
  List<Object> get props => [message];
}

/// Estado de carga durante la obtención de detalles de un lugar.
class PlaceDetailsLoading extends PlacesState {}

/// Estado cuando se han cargado los detalles de un lugar.
class PlaceDetailsLoaded extends PlacesState {
  /// Detalles completos del lugar seleccionado.
  final PlaceDetails placeDetails;

  PlaceDetailsLoaded(this.placeDetails);

  @override
  List<Object> get props => [placeDetails];
}

/// Estado cuando se ha cargado el historial de búsquedas.
class SearchHistoryLoaded extends PlacesState {
  /// Lista de lugares del historial de búsquedas.
  final List<PlaceSearchResult> history;

  SearchHistoryLoaded(this.history);

  @override
  List<Object> get props => [history];
}

/// Estado cuando se han obtenido detalles de un lugar sin seleccionarlo.
/// No dispara navegación automática.
class PlaceDetailsFetched extends PlacesState {
  /// Detalles del lugar.
  final PlaceDetails placeDetails;

  PlaceDetailsFetched(this.placeDetails);

  @override
  List<Object> get props => [placeDetails];
}
