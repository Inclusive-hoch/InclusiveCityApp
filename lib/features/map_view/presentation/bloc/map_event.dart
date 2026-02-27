part of 'map_bloc.dart';

abstract class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para solicitar la ubicación actual del usuario
class GetUserLocationEvent extends MapEvent {}

/// Evento para obtener incidencias del sector visible del mapa.
class FetchSectorIncidencesEvent extends MapEvent {
  final double northEastLat;
  final double northEastLng;
  final double southWestLat;
  final double southWestLng;

  const FetchSectorIncidencesEvent({
    required this.northEastLat,
    required this.northEastLng,
    required this.southWestLat,
    required this.southWestLng,
  });

  @override
  List<Object?> get props => [
    northEastLat,
    northEastLng,
    southWestLat,
    southWestLng,
  ];
}

/// Evento para limpiar las incidencias cuando el zoom baja del umbral.
class ClearSectorIncidencesEvent extends MapEvent {}
