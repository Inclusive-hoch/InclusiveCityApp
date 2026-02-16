part of 'route_bloc.dart';

/// Eventos para el BLoC de rutas.
abstract class RouteEvent extends Equatable {
  const RouteEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para obtener la ruta principal (Google Maps).
class GetMainRouteEvent extends RouteEvent {
  final double originLat;
  final double originLng;
  final double destLat;
  final double destLng;

  const GetMainRouteEvent({
    required this.originLat,
    required this.originLng,
    required this.destLat,
    required this.destLng,
  });

  @override
  List<Object?> get props => [originLat, originLng, destLat, destLng];
}

/// Evento para obtener la ruta alternativa (HERE Maps).
class GetAlternativeRouteEvent extends RouteEvent {
  final double originLat;
  final double originLng;
  final double destLat;
  final double destLng;

  const GetAlternativeRouteEvent({
    required this.originLat,
    required this.originLng,
    required this.destLat,
    required this.destLng,
  });

  @override
  List<Object?> get props => [originLat, originLng, destLat, destLng];
}

/// Evento para obtener ambas rutas en paralelo.
class GetBothRoutesEvent extends RouteEvent {
  final double originLat;
  final double originLng;
  final double destLat;
  final double destLng;

  const GetBothRoutesEvent({
    required this.originLat,
    required this.originLng,
    required this.destLat,
    required this.destLng,
  });

  @override
  List<Object?> get props => [originLat, originLng, destLat, destLng];
}

/// Evento para limpiar las rutas del mapa.
class ClearRoutesEvent extends RouteEvent {}
