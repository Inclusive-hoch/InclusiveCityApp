part of 'map_bloc.dart';

abstract class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para solicitar la ubicación actual del usuario
class GetUserLocationEvent extends MapEvent {}
