import 'package:inclusive_app/features/routing/domain/entities/route_info.dart';
import 'package:inclusive_app/features/routing/domain/repositories/route_repository.dart';

/// Caso de uso para obtener la ruta segura usando OpenRouteService (ORS).
/// 
/// Calcula una ruta que evita incidencias registradas en el sistema.
class GetAlternativeRoute {
  final RouteRepository repository;

  GetAlternativeRoute(this.repository);

  /// Ejecuta el caso de uso para obtener la ruta alternativa.
  /// 
  /// [originLat] latitud del punto de origen (ubicación actual del usuario)
  /// [originLng] longitud del punto de origen
  /// [destLat] latitud del punto de destino (place seleccionado)
  /// [destLng] longitud del punto de destino
  /// 
  /// Retorna [RouteInfo] con el polyline y metadata de la ruta alternativa.
  Future<RouteInfo> call({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) {
    return repository.getAlternativeRoute(
      originLat: originLat,
      originLng: originLng,
      destLat: destLat,
      destLng: destLng,
    );
  }
}
