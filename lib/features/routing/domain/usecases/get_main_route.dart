import 'package:inclusive_app/features/routing/domain/entities/route_info.dart';
import 'package:inclusive_app/features/routing/domain/repositories/route_repository.dart';

/// Caso de uso para obtener la ruta principal usando Google Maps API.
/// 
/// Calcula la ruta óptima entre dos puntos usando el servicio de Google Maps.
class GetMainRoute {
  final RouteRepository repository;

  GetMainRoute(this.repository);

  /// Ejecuta el caso de uso para obtener la ruta principal.
  /// 
  /// [originLat] latitud del punto de origen (ubicación actual del usuario)
  /// [originLng] longitud del punto de origen
  /// [destLat] latitud del punto de destino (place seleccionado)
  /// [destLng] longitud del punto de destino
  /// 
  /// Retorna [RouteInfo] con el polyline y metadata de la ruta.
  Future<RouteInfo> call({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) {
    return repository.getMainRoute(
      originLat: originLat,
      originLng: originLng,
      destLat: destLat,
      destLng: destLng,
    );
  }
}
