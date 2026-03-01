import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inclusive_app/features/routing/data/models/route_info_model.dart';
import 'package:inclusive_app/features/routing/data/datasources/route_local_datasource.dart';

class RouteLocalDataSourceImpl implements RouteLocalDataSource {
  final SharedPreferences sharedPreferences;

  RouteLocalDataSourceImpl({required this.sharedPreferences});

  String _generateKey(double oLat, double oLng, double dLat, double dLng) {
    return 'ROUTE_${oLat}_${oLng}_${dLat}_${dLng}';
  }

  String _generateTimeKey(String routeKey) => '${routeKey}_TIMESTAMP';

  @override
  Future<RouteInfoModel?> getCacheRoute({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    final routeKey = _generateKey(originLat, originLng, destLat, destLng);
    final timeKey = _generateTimeKey(routeKey);

    final timeString = sharedPreferences.getString(timeKey);
    final routeString = sharedPreferences.getString(routeKey);

    if (timeString != null && routeString != null) {
      final saveTime = DateTime.parse(timeString);
      final expirationTime = saveTime.add(const Duration(hours: 24));

      if (DateTime.now().isBefore(expirationTime)) {
        return RouteInfoModel.fromJson(jsonDecode(routeString));
      } else {
        await sharedPreferences.remove(routeKey);
        await sharedPreferences.remove(timeKey);
      }
    }
    return null;
  }

  @override
  Future<void> cacheRoute({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    required RouteInfoModel route,
  }) async {
    final routeKey = _generateKey(originLat, originLng, destLat, destLng);
    final timeKey = _generateTimeKey(routeKey);

    await sharedPreferences.setString(routeKey, jsonEncode(route.toJson()));
    await sharedPreferences.setString(timeKey, DateTime.now().toIso8601String());
  }

  @override
  Future<void> clearOldRoutes() async {
    final allKeys = sharedPreferences.getKeys();
    final routeKeys = allKeys.where((key) => key.startsWith('ROUTE_')).toList();

    for (final routeKey in routeKeys) {
      // Ignorar las claves de timestamp
      if (routeKey.endsWith('_TIMESTAMP')) continue;

      final timeKey = _generateTimeKey(routeKey);
      final timeString = sharedPreferences.getString(timeKey);

      if (timeString != null) {
        final saveTime = DateTime.parse(timeString);
        final expirationTime = saveTime.add(const Duration(hours: 24));

        // Si la ruta ha expirado, eliminarla
        if (DateTime.now().isAfter(expirationTime)) {
          await sharedPreferences.remove(routeKey);
          await sharedPreferences.remove(timeKey);
        }
      } else {
        // Si no tiene timestamp, eliminar la ruta huérfana
        await sharedPreferences.remove(routeKey);
      }
    }
  }
}