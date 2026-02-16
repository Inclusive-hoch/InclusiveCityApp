import 'package:inclusive_app/features/routing/data/datasources/route_remote_datasource.dart';
import 'package:inclusive_app/features/routing/domain/entities/route_info.dart';
import 'package:inclusive_app/features/routing/domain/repositories/route_repository.dart';

/// Implementación del repositorio de rutas.
/// 
/// Coordina el acceso a los datos desde el data source y maneja
/// la lógica de transformación de excepciones si es necesario.
class RouteRepositoryImpl implements RouteRepository {
  final RouteRemoteDataSource remoteDataSource;

  RouteRepositoryImpl({required this.remoteDataSource});

  @override
  Future<RouteInfo> getMainRoute({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    try {
      final routeModel = await remoteDataSource.getMainRoute(
        originLat: originLat,
        originLng: originLng,
        destLat: destLat,
        destLng: destLng,
      );
      return routeModel;
    } catch (e) {
      throw Exception('Error al obtener ruta principal: $e');
    }
  }

  @override
  Future<RouteInfo> getAlternativeRoute({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    try {
      final routeModel = await remoteDataSource.getAlternativeRoute(
        originLat: originLat,
        originLng: originLng,
        destLat: destLat,
        destLng: destLng,
      );
      return routeModel;
    } catch (e) {
      throw Exception('Error al obtener ruta alternativa: $e');
    }
  }
}
