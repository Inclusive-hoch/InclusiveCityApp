import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

/// Utilidad para decodificar polylines codificados.
///
/// Envuelve las bibliotecas especializadas para decodificar polylines:
/// - Google Maps: flutter_polyline_points
/// - HERE Maps: implementación manual del formato Flexible Polyline
///   (https://github.com/heremaps/flexible-polyline)
class PolylineDecoder {
  static final _polylinePoints = PolylinePoints();

  // ─── Google Maps decoder ─────────────────────────────────────────────────

  /// Decodifica un polyline codificado de Google Maps a una lista de LatLng.
  static List<LatLng> decodeGoogle(String encodedPolyline) {
    final result = _polylinePoints.decodePolyline(encodedPolyline);
    return result
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();
  }

  // ─── HERE Maps Flexible Polyline decoder ─────────────────────────────────

  /// Decodifica un polyline en formato HERE Flexible Polyline a LatLng.
  ///
  /// Implementación manual basada en la especificación oficial:
  /// https://github.com/heremaps/flexible-polyline
  static List<LatLng> decodeHere(String encodedPolyline) {
    if (encodedPolyline.isEmpty) return [];
    try {
      return _HereFlexDecoder.decode(encodedPolyline);
    } catch (_) {
      // Fallback al decodificador de Google en caso de error
      return decodeGoogle(encodedPolyline);
    }
  }

  // ─── Dispatcher ──────────────────────────────────────────────────────────

  /// Decodifica un polyline (detecta automáticamente el formato).
  static List<LatLng> decode(String encodedPolyline, {bool isHere = false}) {
    return isHere ? decodeHere(encodedPolyline) : decodeGoogle(encodedPolyline);
  }

  // ─── Factory ─────────────────────────────────────────────────────────────

  /// Crea un [Polyline] de Google Maps desde un polyline codificado.
  ///
  /// [polylineId]      identificador único para el polyline
  /// [encodedPolyline] string codificado de la ruta
  /// [color]           color del polyline en el mapa
  /// [width]           grosor de la línea en pixels
  /// [isHere]          si true, usa el decodificador de HERE Maps
  /// [zIndex]          orden de renderizado (mayor = encima)
  static Polyline createPolyline({
    required String polylineId,
    required String encodedPolyline,
    required Color color,
    int width = 5,
    bool isHere = false,
    int zIndex = 0,
  }) {
    final points = decode(encodedPolyline, isHere: isHere);

    return Polyline(
      polylineId: PolylineId(polylineId),
      points: points,
      color: color,
      width: width,
      geodesic: true,
      zIndex: zIndex,
    );
  }
}

// ─── Internal HERE Flexible Polyline decoder ───────────────────────────────

/// Implementación del decodificador HERE Flexible Polyline.
///
/// Spec: https://github.com/heremaps/flexible-polyline
class _HereFlexDecoder {
  /// Mapeo de caracteres base64url-like a valores 0-63.
  /// Alphabet: ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_
  static int _charValue(int codeUnit) {
    if (codeUnit >= 65 && codeUnit <= 90) return codeUnit - 65;       // A-Z → 0-25
    if (codeUnit >= 97 && codeUnit <= 122) return codeUnit - 97 + 26; // a-z → 26-51
    if (codeUnit >= 48 && codeUnit <= 57) return codeUnit - 48 + 52;  // 0-9 → 52-61
    if (codeUnit == 45) return 62;  // '-' → 62
    if (codeUnit == 95) return 63;  // '_' → 63
    throw FormatException('Invalid HERE polyline character: $codeUnit');
  }

  /// Lee el siguiente valor sin signo de la secuencia de caracteres.
  /// Los bits 0-4 de cada carácter son datos; el bit 5 indica continuación.
  static int _readUnsigned(List<int> codes, List<int> idx) {
    int result = 0, shift = 0;
    while (true) {
      final c = _charValue(codes[idx[0]++]);
      result |= (c & 31) << shift;
      shift += 5;
      if (c < 32) break; // sin bit de continuación
    }
    return result;
  }

  /// Lee el siguiente valor con signo usando codificación zigzag.
  static int _readSigned(List<int> codes, List<int> idx) {
    final value = _readUnsigned(codes, idx);
    // Zigzag decode: LSB=1 indica negativo
    return (value & 1) != 0 ? ~(value >> 1) : (value >> 1);
  }

  /// Decodifica un string en formato HERE Flexible Polyline.
  static List<LatLng> decode(String encoded) {
    final codes = encoded.codeUnits;
    // idx[0] actúa como puntero mutable al índice actual
    final idx = [0];

    // Cabecera: versión
    final version = _readUnsigned(codes, idx);
    if (version != 1) {
      throw FormatException('Unsupported HERE polyline version: $version');
    }

    // Cabecera: precision | (thirdDimType << 4) | (thirdDimPrecision << 7)
    final headerValue = _readUnsigned(codes, idx);
    final precision = headerValue & 0xF;
    final thirdDimType = (headerValue >> 4) & 0x7;
    // thirdDimType == 0 → sin dimensión extra
    // thirdDimType == 1/4/5 → altitude / altitude offset / elevation (se omite para el mapa)

    final factor = math.pow(10, precision).toDouble();

    final points = <LatLng>[];
    double lastLat = 0, lastLng = 0;

    while (idx[0] < codes.length) {
      lastLat += _readSigned(codes, idx) / factor;
      lastLng += _readSigned(codes, idx) / factor;

      // Si hay 3ª dimensión, leerla y descartarla
      if (thirdDimType != 0) {
        _readSigned(codes, idx);
      }

      points.add(LatLng(lastLat, lastLng));
    }

    return points;
  }
}

