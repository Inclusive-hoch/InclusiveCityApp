import 'package:inclusive_app/features/routing/domain/entities/route_info.dart';

/// Repositorio para obtener información de rutas.
/// 
/// Proporciona métodos para calcular rutas principales (Google Maps)
/// y rutas alternativas (HERE Maps) entre dos puntos.
abstract class RouteRepository {
  /// Obtiene la ruta principal usando la API de Google Maps.
  /// 
  /// [originLat] latitud del punto de origen
  /// [originLng] longitud del punto de origen
  /// [destLat] latitud del punto de destino
  /// [destLng] longitud del punto de destino
  /// 
  /// Retorna [RouteInfo] con los datos de la ruta principal.
  /// Lanza excepción si hay error en la petición.
  Future<RouteInfo> getMainRoute({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  });

  /// Obtiene la ruta alternativa usando la API de HERE Maps.
  /// 
  /// Esta ruta evita incidencias registradas en el sistema.
  /// 
  /// [originLat] latitud del punto de origen
  /// [originLng] longitud del punto de origen
  /// [destLat] latitud del punto de destino
  /// [destLng] longitud del punto de destino
  /// 
  /// Retorna [RouteInfo] con los datos de la ruta alternativa.
  /// Lanza excepción si hay error en la petición.
  Future<RouteInfo> getAlternativeRoute({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  });
}
