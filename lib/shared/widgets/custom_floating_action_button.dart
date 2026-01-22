import 'package:flutter/material.dart';
import 'package:inclusive_app/core/theme/app_color.dart';

/// Widget personalizado de FloatingActionButton con diferentes estilos predefinidos.
///
/// Proporciona tres variantes de botones flotantes:
/// - [CustomFloatingActionButton.primary]: Botón circular con color primario
/// - [CustomFloatingActionButton.incidence]: Botón circular amarillo para reportar incidencias
/// - [CustomFloatingActionButton.square]: Botón cuadrado con bordes redondeados
///
/// Todos los botones permiten personalizar el tamaño del botón y del icono.
class CustomFloatingActionButton extends StatelessWidget {
  /// Callback que se ejecuta al presionar el botón
  final VoidCallback onPressed;

  /// Icono que se mostrará en el botón
  final IconData icon;

  final Color backgroundColor;
  final ShapeBorder shapeBorder;
  final double buttonSize;
  final double iconSize;
  final Object? heroTag;

  /// Constructor privado base para crear instancias personalizadas
  const CustomFloatingActionButton._({
    required this.onPressed,
    required this.icon,
    required this.backgroundColor,
    required this.shapeBorder,
    required this.buttonSize,
    required this.iconSize,
    this.heroTag,
  });

  factory CustomFloatingActionButton.primary({
    required VoidCallback onPressed,
    required IconData icon,
    Object? heroTag,
  }) {
    return CustomFloatingActionButton._(
      onPressed: onPressed,
      icon: icon,
      backgroundColor: AppColor.primaryNormal,
      shapeBorder: const CircleBorder(),
      buttonSize: 56,
      iconSize: 24,
      heroTag: heroTag,
    );
  }

  factory CustomFloatingActionButton.incidence({
    required VoidCallback onPressed,
    required IconData icon,
    Object? heroTag,
  }) {
    return CustomFloatingActionButton._(
      onPressed: onPressed,
      icon: icon,
      backgroundColor: AppColor.yellowNormal,
      shapeBorder: const CircleBorder(),
      buttonSize: 56,
      iconSize: 24,
      heroTag: heroTag,
    );
  }

  factory CustomFloatingActionButton.square({
    required VoidCallback onPressed,
    required IconData icon,
    Object? heroTag,
  }) {
    return CustomFloatingActionButton._(
      onPressed: onPressed,
      icon: icon,
      backgroundColor: AppColor.primaryNormal,
      shapeBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      buttonSize: 56,
      iconSize: 24,
      heroTag: heroTag,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: buttonSize,
      width: buttonSize,
      child: FloatingActionButton(
        heroTag: heroTag, // Added this
        onPressed: onPressed,
        backgroundColor: backgroundColor,
        shape: shapeBorder,
        elevation: 3,
        child: Icon(icon, color: Colors.white, size: iconSize),
      ),
    );
  }
}
