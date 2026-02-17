part of 'route_bloc.dart';

/// Estados para el BLoC de rutas.
abstract class RouteState extends Equatable {
  const RouteState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial, sin rutas cargadas.
class RouteInitial extends RouteState {}

/// Estado de carga mientras se obtienen las rutas.
class RouteLoading extends RouteState {}

/// Estado con rutas cargadas exitosamente.
/// 
/// Puede contener solo la ruta principal, solo la alternativa,
/// o ambas rutas en paralelo.
class RouteLoaded extends RouteState {
  /// Ruta principal calculada con Google Maps (puede ser null)
  final RouteInfo? mainRoute;
  
  /// Ruta alternativa calculada con HERE Maps (puede ser null)
  final RouteInfo? alternativeRoute;

  const RouteLoaded({
    required this.mainRoute,
    required this.alternativeRoute,
  });

  @override
  List<Object?> get props => [mainRoute, alternativeRoute];

  /// Verifica si hay al menos una ruta cargada.
  bool get hasAnyRoute => mainRoute != null || alternativeRoute != null;

  /// Verifica si ambas rutas están cargadas.
  bool get hasBothRoutes => mainRoute != null && alternativeRoute != null;
}

/// Estado de error al obtener las rutas.
class RouteError extends RouteState {
  final String message;

  const RouteError(this.message);

  @override
  List<Object?> get props => [message];
}
