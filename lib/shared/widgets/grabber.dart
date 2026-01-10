import 'package:flutter/widgets.dart';
import 'package:inclusive_app/core/theme/app_color.dart';

/// Widget que representa un indicador visual de deslizamiento (grabber).
///
/// Se utiliza típicamente en bottom sheets, paneles deslizables o drawers
/// para indicar al usuario que el elemento puede ser arrastrado o deslizado.
///
/// Características:
/// - Barra horizontal redondeada de 40x5 píxeles
/// - Color neutral del tema de la aplicación
/// - Márgenes verticales de 10 píxeles para espaciado
///
/// Ejemplo de uso:
/// ```dart
/// DraggableScrollableSheet(
///   builder: (context, scrollController) {
///     return Column(
///       children: [
///         const Grabber(), // Indicador visual
///         // Contenido del panel...
///       ],
///     );
///   },
/// )
/// ```
class Grabber extends StatelessWidget {
  const Grabber({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20.0,
      height: 5.0,
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      decoration: BoxDecoration(
        color: AppColor.neutralNormal,
        borderRadius: BorderRadius.circular(2.5),
      ),
    );
  }
}
