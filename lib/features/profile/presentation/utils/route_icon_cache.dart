import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// Asegúrate de importar tu utilidad de bitmaps (revisé tu estructura y la tienes aquí)
import 'package:inclusive_app/core/utils/bitmap_descriptor.dart' as bitmap_utils;

class RouteIconCache {
  // 1. LA MAGIA DEL SINGLETON: Instancia estática privada
  static final RouteIconCache _instance = RouteIconCache._internal();

  // 2. Factory constructor que siempre devuelve la misma instancia
  factory RouteIconCache() => _instance;

  // 3. Constructor privado real
  RouteIconCache._internal();

  // Variables para guardar los iconos ya calculados
  BitmapDescriptor? _originIcon;
  BitmapDescriptor? _destIcon;
  bool _isLoading = false;

  // Getters para acceder a los iconos de forma segura (asumimos que ya se cargaron)
  BitmapDescriptor get originIcon => _originIcon!;
  BitmapDescriptor get destIcon => _destIcon!;

  /// Método para pre-calcular y guardar los iconos
  Future<void> preloadIcons() async {
    // Si ya los calculamos antes, no hacemos nada (retorno rápido)
    if (_originIcon != null && _destIcon != null) return;
    
    // Si ya estamos en proceso de carga, esperamos un poco y reintentamos
    if (_isLoading) {
      await Future.delayed(const Duration(milliseconds: 100));
      return preloadIcons();
    }

    _isLoading = true;

    try {
      // Usamos Future.wait (¡como aprendimos antes!) para procesar AMBOS al mismo tiempo
      final results = await Future.wait([
        bitmap_utils.bitmapDescriptorFromSvgAsset(
          'assets/routeLogo/inicio_ruta.svg',
          const Size(33, 33), // Tamaño del origen
        ),
        bitmap_utils.bitmapDescriptorFromSvgAsset(
          'assets/routeLogo/llegada_logo.svg',
          const Size(25, 32), // Tamaño del destino
        ),
      ]);

      // Guardamos los resultados en memoria RAM
      _originIcon = results[0];
      _destIcon = results[1];
    } catch (e) {
      debugPrint('Error al pre-cargar iconos: $e');
      // Podrías asignar iconos por defecto aquí si falla
    } finally {
      _isLoading = false;
    }
  }
}