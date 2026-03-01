import 'package:inclusive_app/core/network/network_info.dart';
import 'package:inclusive_app/features/routing/data/datasources/route_local_datasource.dart';
import 'package:inclusive_app/features/routing/data/datasources/route_remote_datasource.dart';
import 'package:inclusive_app/features/routing/domain/entities/route_info.dart';
import 'package:inclusive_app/features/routing/domain/repositories/route_repository.dart';

/// Implementación del repositorio de rutas.
/// 
/// Coordina el acceso a los datos desde el data source y maneja
/// la lógica de transformación de excepciones si es necesario.
class RouteRepositoryImpl implements RouteRepository {
  final RouteRemoteDataSource remoteDataSource;
  final RouteLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  
  RouteRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<RouteInfo> getAlternativeRoute({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    // 1. VERIFICAR CACHÉ PRIMERO
    try {
      final cachedRoute = await localDataSource.getCacheRoute(
        originLat: originLat,
        originLng: originLng,
        destLat: destLat,
        destLng: destLng,
      );

      // Si encontramos la ruta y sigue siendo válida, ¡la retornamos al instante!
      if (cachedRoute != null) {
        return cachedRoute;
      }
    } catch (_) {
      // Ignoramos errores de caché para no interrumpir el flujo
    }

    // 2. SI NO HAY CACHÉ, LLAMAR A LA API (Red)
    if (await networkInfo.isConnected) {
      final routeModel = await remoteDataSource.getAlternativeRoute(
        originLat: originLat,
        originLng: originLng,
        destLat: destLat,
        destLng: destLng,
      );

      // 3. GUARDAR EL RESULTADO NUEVO EN CACHÉ PARA LA PRÓXIMA VEZ
      await localDataSource.cacheRoute(
        originLat: originLat,
        originLng: originLng,
        destLat: destLat,
        destLng: destLng,
        route: routeModel,
      );

      return routeModel;
    } else {
      throw Exception('No hay conexión a internet para calcular la ruta');
    }
  }
}
