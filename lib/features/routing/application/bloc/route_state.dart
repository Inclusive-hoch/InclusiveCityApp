part of 'route_bloc.dart';

/// Estados para el BLoC de rutas.
abstract class RouteState extends Equatable {
  const RouteState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial, sin rutas cargadas.
class RouteInitial extends RouteState {}

/// Estado de carga mientras se obtiene la ruta.
class RouteLoading extends RouteState {}

/// Estado con la ruta segura cargada exitosamente.
class RouteLoaded extends RouteState {
  /// Ruta segura calculada con OpenRouteService, evita incidencias.
  final RouteInfo? alternativeRoute;

  const RouteLoaded({
    required this.alternativeRoute,
  });

  @override
  List<Object?> get props => [alternativeRoute];
}

/// Estado de error al obtener la ruta.
class RouteError extends RouteState {
  final String message;

  const RouteError(this.message);

  @override
  List<Object?> get props => [message];
}
