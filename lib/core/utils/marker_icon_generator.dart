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
  /// Implementa técnicas de alta resolución para mejorar la calidad visual:
  /// - Usa un pixelRatio de 3.0 para renderizado de alta definición
  /// - Habilita anti-aliasing en todos los elementos gráficos
  /// - Especifica el imagePixelRatio para que Google Maps escale correctamente
  ///
  /// Parámetros:
  ///  - [iconData]: el ícono de Material a renderizar
  ///  - [backgroundColor]: color de fondo del círculo del marker
  ///  - [iconColor]: color del ícono
  ///  - [size]: tamaño visual del marker en píxeles lógicos (default: 16)
  static Future<BitmapDescriptor> fromIconData(
    IconData iconData, {
    Color backgroundColor = const Color(0xFFFF8C00),
    Color iconColor = Colors.white,
    double size = 28,
  }) async {
    final cacheKey = '${iconData.codePoint}_${backgroundColor.toARGB32()}_$size';

    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    // Multiplicador de resolución interna (upscaling) para mejorar nitidez
    const double pixelRatio = 3.0;
    final double physicalSize = size * pixelRatio;

    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    // Habilitar anti-aliasing para bordes más suaves
    final bgPaint = Paint()
      ..color = backgroundColor
      ..isAntiAlias = true;
    
    canvas.drawCircle(
      Offset(physicalSize / 2, physicalSize / 2),
      physicalSize / 2,
      bgPaint,
    );

    // Dibujar borde con anti-aliasing
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = physicalSize * 0.06
      ..isAntiAlias = true;
    
    canvas.drawCircle(
      Offset(physicalSize / 2, physicalSize / 2),
      physicalSize / 2 - physicalSize * 0.03,
      borderPaint,
    );

    // Dibujar ícono con alta resolución
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(iconData.codePoint),
      style: TextStyle(
        fontSize: physicalSize * 0.5,
        fontFamily: iconData.fontFamily,
        package: iconData.fontPackage,
        color: iconColor,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (physicalSize - textPainter.width) / 2,
        (physicalSize - textPainter.height) / 2,
      ),
    );

    // Convertir a imagen con alta resolución
    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(
      physicalSize.toInt(), 
      physicalSize.toInt()
    );
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    // Usar el constructor optimizado con imagePixelRatio
    // Esto le indica a Google Maps el tamaño visual correcto
    final descriptor = BitmapDescriptor.bytes(
      bytes!.buffer.asUint8List(),
      imagePixelRatio: pixelRatio,
    );
    
    _cache[cacheKey] = descriptor;

    return descriptor;
  }
}
