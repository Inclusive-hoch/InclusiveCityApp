import 'package:inclusive_app/features/routing/data/models/route_info_model.dart';

abstract class RouteLocalDataSource {

  Future<RouteInfoModel?> getCacheRoute({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  });

  Future<void> cacheRoute({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    required RouteInfoModel route,
  });

  Future<void> clearOldRoutes();
}