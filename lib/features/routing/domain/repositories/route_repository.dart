import 'package:inclusive_app/features/routing/domain/entities/route_info.dart';

/// Repositorio para obtener información de rutas.
/// 
/// Proporciona el método para calcular la ruta segura (OpenRouteService)
/// entre dos puntos, evitando incidencias registradas en el sistema.
abstract class RouteRepository {
  /// Obtiene la ruta segura usando la API de OpenRouteService (ORS).
  /// 
  /// Esta ruta evita incidencias registradas en el sistema.
  /// 
  /// [originLat] latitud del punto de origen
  /// [originLng] longitud del punto de origen
  /// [destLat] latitud del punto de destino
  /// [destLng] longitud del punto de destino
  /// 
  /// Retorna [RouteInfo] con los datos de la ruta segura.
  /// Lanza excepción si hay error en la petición.
  Future<RouteInfo> getAlternativeRoute({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  });
}
