part of 'route_bloc.dart';

/// Eventos para el BLoC de rutas.
abstract class RouteEvent extends Equatable {
  const RouteEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para obtener la ruta segura (OpenRouteService), que evita incidencias.
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

/// Evento para limpiar las rutas del mapa.
class ClearRoutesEvent extends RouteEvent {}
