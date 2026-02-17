import 'package:inclusive_app/features/routing/data/models/route_info_model.dart';

/// Data source remota para obtener información de rutas desde el backend.
abstract class RouteRemoteDataSource {
  /// Obtiene la ruta principal desde el endpoint de Google Maps.
  /// 
  /// [originLat] latitud del origen
  /// [originLng] longitud del origen  /// [destLat] latitud del destino
  /// [destLng] longitud del destino
  /// 
  /// Retorna [RouteInfoModel] con los datos parseados.
  /// Lanza excepción si hay error en la petición HTTP o en el parseo.
  Future<RouteInfoModel> getMainRoute({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  });

  /// Obtiene la ruta alternativa desde el endpoint de HERE Maps.
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
