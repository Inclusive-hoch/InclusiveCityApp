part of 'place_bloc.dart';

/// Eventos del bloc de lugares.
/// Todos los eventos relacionados con búsqueda, selección y ubicación de lugares.
abstract class PlacesEvent extends Equatable {
  @override
  List<Object> get props => [];
}

/// Evento para buscar lugares con un query.
class SearchPlacesEvent extends PlacesEvent {
  /// Query de búsqueda ingresado por el usuario.
  final String query;

  SearchPlacesEvent(this.query);

  @override
  List<Object> get props => [query];
}

/// Evento para limpiar los resultados de búsqueda.
class ClearSearchEvent extends PlacesEvent {}

/// Evento para seleccionar un lugar específico.
class SelectPlaceEvent extends PlacesEvent {
  /// ID del lugar seleccionado.
  final String placeId;

  SelectPlaceEvent(this.placeId);

  @override
  List<Object> get props => [placeId];
}

/// Evento para obtener la ubicación actual del usuario.
class GetUserLocationEvent extends PlacesEvent {}

/// Evento para cargar el historial de búsquedas.
class LoadSearchHistoryEvent extends PlacesEvent {}

/// Evento para guardar un lugar en el historial.
class SaveToHistoryEvent extends PlacesEvent {
  /// Lugar a guardar en el historial.
  final PlaceSearchResult place;

  SaveToHistoryEvent(this.place);

  @override
  List<Object> get props => [place];
}
