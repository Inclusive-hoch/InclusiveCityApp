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
