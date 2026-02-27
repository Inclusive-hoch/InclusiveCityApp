import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Utilidad para convertir un [IconData] de Material en un [BitmapDescriptor]
/// para usarse como ícono de marker en Google Maps.
///
/// Renderiza el ícono dentro de un círculo con fondo de color y lo convierte
/// a un bitmap compatible con el SDK de Maps.
class MarkerIconGenerator {
  /// Cache de íconos ya generados para evitar recálculos.
  static final Map<String, BitmapDescriptor> _cache = {};

  /// Genera un [BitmapDescriptor] a partir de un [IconData].
  ///
  /// Parámetros:
  ///  - [iconData]: el ícono de Material a renderizar
  ///  - [backgroundColor]: color de fondo del círculo del marker
  ///  - [iconColor]: color del ícono
  ///  - [size]: tamaño total del marker en píxeles lógicos
  static Future<BitmapDescriptor> fromIconData(
    IconData iconData, {
    Color backgroundColor = const Color(0xFFFF8C00),
    Color iconColor = Colors.white,
    double size = 16,
  }) async {
    final cacheKey = '${iconData.codePoint}_${backgroundColor.value}_$size';

    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final pixelSize = size * 2; // Para alta resolución

    // Dibujar círculo de fondo
    final bgPaint = Paint()..color = backgroundColor;
    canvas.drawCircle(
      Offset(pixelSize / 2, pixelSize / 2),
      pixelSize / 2,
      bgPaint,
    );

    // Dibujar borde
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = pixelSize * 0.08;
    canvas.drawCircle(
      Offset(pixelSize / 2, pixelSize / 2),
      pixelSize / 2 - pixelSize * 0.04,
      borderPaint,
    );

    // Dibujar ícono
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(iconData.codePoint),
      style: TextStyle(
        fontSize: pixelSize * 0.5,
        fontFamily: iconData.fontFamily,
        package: iconData.fontPackage,
        color: iconColor,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (pixelSize - textPainter.width) / 2,
        (pixelSize - textPainter.height) / 2,
      ),
    );

    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(pixelSize.toInt(), pixelSize.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    final descriptor = BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
    _cache[cacheKey] = descriptor;

    return descriptor;
  }
}
