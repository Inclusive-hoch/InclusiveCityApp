import 'package:inclusive_app/features/routing/domain/entities/route_info.dart';

/// Modelo de datos para RouteInfo obtenido del backend.
/// 
/// Parsea la respuesta JSON del endpoint de rutas y la convierte
/// en una entidad de dominio.
class RouteInfoModel extends RouteInfo {
  const RouteInfoModel({
    required super.encodedPolyline,
    required super.distanceMeters,
    required super.durationSeconds,
    required super.routeType,
  });

  /// Crea un modelo desde JSON del backend.
  /// 
  /// Ejemplo de respuesta esperada:
  /// ```json
  /// {
  ///   "status": true,
  ///   "data": {
  ///     "distance": "1.7 km",
  ///     "duration": "5 mins",
  ///     "polyline": "encoded_polyline_string"
  ///   }
  /// }
  /// ```
  factory RouteInfoModel.fromJson(Map<String, dynamic> json, {String? routeType}) {
    // La respuesta viene envuelta en un objeto con 'status' y 'data'
    final data = json['data'] as Map<String, dynamic>;
    
    return RouteInfoModel(
      encodedPolyline: data['polyline'] as String,
      distanceMeters: _parseDistance(data['distance']),
      durationSeconds: _parseDuration(data['duration']),
      routeType: routeType ?? 'main',
    );
  }

  /// Parsea la distancia desde string "1.7 km" a metros
  static double _parseDistance(dynamic distance) {
    if (distance is num) return distance.toDouble();
    
    final distanceStr = distance.toString();
    // Remover 'km' y convertir a metros
    final value = double.tryParse(distanceStr.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
    
    if (distanceStr.contains('km')) {
      return value * 1000; // Convertir km a metros
    }
    return value; // Ya está en metros
  }

  /// Parsea la duración desde string "5 mins" a segundos
  static double _parseDuration(dynamic duration) {
    if (duration is num) return duration.toDouble();
    
    final durationStr = duration.toString().toLowerCase();
    final value = double.tryParse(durationStr.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
    
    if (durationStr.contains('min')) {
      return value * 60; // Convertir minutos a segundos
    } else if (durationStr.contains('hour') || durationStr.contains('hr')) {
      return value * 3600; // Convertir horas a segundos
    }
    return value; // Ya está en segundos
  }

  /// Convierte el modelo a JSON.
  Map<String, dynamic> toJson() {
    return {
      'polyline': encodedPolyline,
      'distance': distanceMeters,
      'duration': durationSeconds,
      'routeType': routeType,
    };
  }

  /// Crea un modelo desde una entidad de dominio.
  factory RouteInfoModel.fromEntity(RouteInfo entity) {
    return RouteInfoModel(
      encodedPolyline: entity.encodedPolyline,
      distanceMeters: entity.distanceMeters,
      durationSeconds: entity.durationSeconds,
      routeType: entity.routeType,
    );
  }
}
