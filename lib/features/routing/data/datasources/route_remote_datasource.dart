import 'package:inclusive_app/features/routing/data/models/route_info_model.dart';

/// Data source remota para obtener información de rutas desde el backend.
abstract class RouteRemoteDataSource {
  /// Obtiene la ruta segura desde el endpoint de OpenRouteService (ORS).
  /// 
  /// [originLat] latitud del origen
  /// [originLng] longitud del origen
  /// [destLat] latitud del destino
  /// [destLng] longitud del destino
  /// 
  /// Retorna [RouteInfoModel] con los datos parseados.
  /// Lanza excepción si hay error en la petición HTTP o en el parseo.
  Future<RouteInfoModel> getAlternativeRoute({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  });
}
