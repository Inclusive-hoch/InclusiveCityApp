import 'package:equatable/equatable.dart';

/// Entidad que representa información de una ruta calculada.
/// 
/// Contiene el polyline codificado, distancia, duración y tipo de ruta.
/// Puede ser una ruta principal (Google) o segura (OpenRouteService).
class RouteInfo extends Equatable {
  /// Polyline codificado de la ruta
  final String encodedPolyline;
  
  /// Distancia de la ruta en metros
  final double distanceMeters;
  
  /// Duración estimada de la ruta en segundos
  final double durationSeconds;
  
  /// Tipo de ruta: 'main' para Google o 'alternative' para OpenRouteService
  final String routeType;

  const RouteInfo({
    required this.encodedPolyline,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.routeType,
  });

  @override
  List<Object?> get props => [
        encodedPolyline,
        distanceMeters,
        durationSeconds,
        routeType,
      ];

  /// Formatea la distancia en kilómetros con 1 decimal
  String get formattedDistance {
    final km = distanceMeters / 1000;
    return '${km.toStringAsFixed(1)} km';
  }

  /// Formatea la duración en minutos u horas según corresponda
  String get formattedDuration {
    final totalMinutes = (durationSeconds / 60).round();
    
    if (totalMinutes < 60) {
      return '$totalMinutes min';
    }
    
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    
    if (minutes == 0) {
      return hours == 1 ? '1 hora' : '$hours horas';
    }
    
    final hourText = hours == 1 ? '1 hora' : '$hours horas';
    return '$hourText $minutes min';
  }
}
