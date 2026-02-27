import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<BitmapDescriptor> bitmapDescriptorFromSvgAsset(
    String assetName, [Size size = const Size(30, 30)]) async {
  
  // 1. Cargamos el SVG. 
  // Usamos un multiplicador de resolución interna (upscaling) para mejorar la nitidez
  const double pixelRatio = 2.0; 
  final double width = size.width * pixelRatio;
  final double height = size.height * pixelRatio;

  final pictureInfo = await vg.loadPicture(SvgAssetLoader(assetName), null);

  // 2. Crear un canvas de alta resolución
  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final ui.Canvas canvas = ui.Canvas(recorder);
  
  // Escalamos el canvas para que el dibujo ocupe todo el espacio de alta resolución
  canvas.scale(width / pictureInfo.size.width, height / pictureInfo.size.height);
  
  // Dibujamos el SVG en el canvas escalado
  canvas.drawPicture(pictureInfo.picture);

  // 3. Convertir a imagen especificando el tamaño de alta resolución
  final ui.Image img = await recorder.endRecording().toImage(
        width.toInt(), 
        height.toInt()
      );
      
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  final Uint8List bytes = byteData!.buffer.asUint8List();

  // Usamos el constructor de bytes optimizado
  return BitmapDescriptor.bytes(
    bytes,
    // Importante: le decimos a Google Maps qué tamaño visual debe tener 
    // a pesar de que los bytes tengan más resolución.
    imagePixelRatio: pixelRatio, 
  );
}