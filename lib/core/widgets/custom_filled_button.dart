import 'package:flutter/material.dart';
import 'package:inclusive_app/core/theme/app_color.dart';

/// Botón reutilizable con estilo consistente usado en toda la aplicación.
///
/// Proporciona dos variantes:
/// - Primary: Fondo [AppColor.primaryNormal] con texto blanco
/// - Secondary: Fondo [AppColor.neutralLight] con texto [AppColor.primaryNormal]
///
/// El estilo es consistente con los botones de las vistas de autenticación.
enum CustomButtonStyle { primary, secondary, success, error, neutral }

/// Botón reutilizable con estilo consistente usado en toda la aplicación.
class CustomFilledButton extends StatelessWidget {
  /// El texto a mostrar en el botón.
  final String label;

  /// Callback ejecutado al presionar el botón.
  final VoidCallback? onPressed;

  /// El estilo visual del botón.
  final CustomButtonStyle style;

  /// Ancho del botón.
  final double? width;

  /// Icono opcional a mostrar a la izquierda del texto.
  final IconData? icon;

  const CustomFilledButton({
    super.key,
    required this.label,
    this.onPressed,
    this.style = CustomButtonStyle.primary,
    this.width,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 48,
      child: FilledButton(
        onPressed: onPressed,
        style: _getButtonStyle(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: _getTextStyle()?.color),
              const SizedBox(width: 8),
            ],
            Text(label, style: _getTextStyle()),
          ],
        ),
      ),
    );
  }

  TextStyle? _getTextStyle() {
    if (style == CustomButtonStyle.secondary) {
      return const TextStyle(color: AppColor.primaryNormal);
    }
    return const TextStyle(color: Colors.white);
  }

  ButtonStyle _getButtonStyle() {
    return ButtonStyle(
      elevation: const WidgetStatePropertyAll(0),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      backgroundColor: WidgetStatePropertyAll(_getBackgroundColor()),
    );
  }

  Color _getBackgroundColor() {
    switch (style) {
      case CustomButtonStyle.primary:
        return AppColor.primaryNormal;
      case CustomButtonStyle.secondary:
        return AppColor.neutralLight;
      case CustomButtonStyle.success:
        return AppColor.success;
      case CustomButtonStyle.error:
        return AppColor.error;
      case CustomButtonStyle.neutral:
        return AppColor.neutralDarkActive;
    }
  }
}
