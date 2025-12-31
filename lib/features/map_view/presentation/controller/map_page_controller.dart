
import 'package:flutter/material.dart';

/// Controlador que gestiona el estado de centrado del mapa en la ubicación del usuario.
/// 
/// Detecta cuando el usuario mueve el mapa manualmente y coordina animaciones
/// de centrado, separando esta lógica de presentación del [MapBloc].
/// 
/// Uso básico:
/// ```dart
/// final controller = MapPageController();
/// 
/// // Al centrar
/// controller.startCentering();
/// 
/// // En callbacks del mapa
/// GoogleMap(
///   onCameraMove: (_) => controller.handleCameraMove(),
///   onCameraIdle: () => controller.handleCameraIdle(),
/// )
/// ```

class MapPageController extends ChangeNotifier {
  final ValueNotifier<bool> isCenteredOnUser = ValueNotifier<bool>(false);

  bool _isAnimating = false;

/// Inicia el centrado del mapa. Llámalo antes de obtener la ubicación GPS.
  void startCentering() {
    _isAnimating = true;
    isCenteredOnUser.value = true;
  }

  /// Detecta cuando el usuario mueve el mapa manualmente.
  void handleCameraMove() {
    if (!_isAnimating && isCenteredOnUser.value) {
      isCenteredOnUser.value = false;
    }
  }

  /// Finaliza el tracking de animación cuando la cámara se detiene.
  void handleCameraIdle() {
    _isAnimating = false;
  }
  
  @override
  void dispose() {
    isCenteredOnUser.dispose();
    super.dispose();
  }

}