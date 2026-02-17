import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

/// Utilidad para decodificar polylines codificados.
/// 
/// Envuelve las bibliotecas especializadas para decodificar polylines:
/// - Google Maps: flutter_polyline_points (implementado)
/// - HERE Maps: Preparado para futura implementación con flexible_polyline
class PolylineDecoder {
  static final _polylinePoints = PolylinePoints();

  /// Decodifica un polyline codificado de Google Maps a una lista de coordenadas LatLng.
  /// 
  /// El [encodedPolyline] es el string codificado obtenido de la API de Google Maps.
  /// Usa el algoritmo de codificación de Google Maps.
  /// 
  /// Retorna una lista de [LatLng] que representa los puntos de la ruta.
  static List<LatLng> decodeGoogle(String encodedPolyline) {
    final result = _polylinePoints.decodePolyline(encodedPolyline);
    return result.map((point) => LatLng(point.latitude, point.longitude)).toList();
  }

  /// Decodifica un polyline codificado de HERE Maps a una lista de coordenadas LatLng.
  /// 
  /// NOTA: Actualmente usa el mismo decodificador de Google Maps.
  /// Cuando se implemente el endpoint de HERE Maps, se debe:
  /// 1. Agregar el paquete 'flexible_polyline' al pubspec.yaml
  /// 2. Importar: import 'package:flexible_polyline/flexible_polyline.dart' as flexible;
  /// 3. Usar: flexible.FlexiblePolyline.decode(encodedPolyline)
  /// 
  /// HERE Maps usa el formato "Flexible Polyline" que es más eficiente y compacto.
  static List<LatLng> decodeHere(String encodedPolyline) {
    // TODO: Implementar decodificador de HERE Maps cuando se necesite
    // Por ahora, usa el mismo que Google
    return decodeGoogle(encodedPolyline);
  }

  /// Decodifica un polyline (detecta automáticamente el formato).
  /// Por defecto asume formato de Google Maps.
  /// 
  /// [encodedPolyline] string codificado de la ruta
  /// [isHere] si true, usa el decodificador de HERE Maps
  /// 
  /// Para mayor claridad, se recomienda usar [decodeGoogle] o [decodeHere] directamente.
  static List<LatLng> decode(String encodedPolyline, {bool isHere = false}) {
    return isHere ? decodeHere(encodedPolyline) : decodeGoogle(encodedPolyline);
  }

  /// Crea un Polyline de Google Maps desde un polyline codificado.
  /// 
  /// [polylineId] identificador único para el polyline
  /// [encodedPolyline] string codificado de la ruta
  /// [color] color del polyline en el mapa
  /// [width] grosor de la línea en pixels
  /// [isHere] si true, usa el decodificador de HERE Maps
  /// 
  /// Retorna un [Polyline] listo para ser agregado al mapa.
  static Polyline createPolyline({
    required String polylineId,
    required String encodedPolyline,
    required Color color,
    int width = 5,
    bool isHere = false,
  }) {
    final points = decode(encodedPolyline, isHere: isHere);
    
    return Polyline(
      polylineId: PolylineId(polylineId),
      points: points,
      color: color,
      width: width,
      geodesic: true,
    );
  }
}
