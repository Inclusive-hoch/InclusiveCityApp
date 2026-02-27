part of 'map_bloc.dart';

abstract class MapState extends Equatable {
  const MapState();

  @override
  List<Object?> get props => [];
}

class MapInitial extends MapState {}

class MapLoading extends MapState {}

class MapLocationLoaded extends MapState {
  final double latitude;
  final double longitude;

  const MapLocationLoaded(this.latitude, this.longitude);

  @override
  List<Object?> get props => [latitude, longitude];
}

class MapError extends MapState {
  final String message;
  const MapError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Estado emitido cuando se cargan incidencias del sector visible.
class SectorIncidencesLoaded extends MapState {
  final List<SectorIncidenceEntity> incidences;

  const SectorIncidencesLoaded(this.incidences);

  @override
  List<Object?> get props => [incidences];
}

/// Estado emitido cuando se limpian las incidencias (zoom bajo).
class SectorIncidencesCleared extends MapState {}
