import 'package:flutter/material.dart';
import 'package:inclusive_app/core/theme/app_color.dart';

/// Botón reutilizable con estilo consistente usado en toda la aplicación.
///
/// Proporciona dos variantes:
/// - Primary: Fondo [AppColor.primaryNormal] con texto blanco
/// - Secondary: Fondo [AppColor.neutralLight] con texto [AppColor.primaryNormal]
///
/// El estilo es consistente con los botones de las vistas de autenticación.
class CustomFilledButton extends StatelessWidget {
  /// El texto a mostrar en el botón.
  final String label;

  /// Callback ejecutado al presionar el botón.
  /// Si es `null`, el botón estará deshabilitado.
  final VoidCallback? onPressed;

  /// Si es `true`, usa el estilo primario (fondo oscuro).
  /// Si es `false`, usa el estilo secundario (fondo claro).
  final bool isPrimary;

  const CustomFilledButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isPrimary = true,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: _getButtonStyle(),
      child: Text(
        label,
        style: isPrimary
            ? null
            : const TextStyle(color: AppColor.primaryNormal),
      ),
    );
  }

  ButtonStyle _getButtonStyle() {
    return ButtonStyle(
      elevation: const WidgetStatePropertyAll(2),
      fixedSize: const WidgetStatePropertyAll(Size(300, 43)),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      backgroundColor: WidgetStatePropertyAll(
        isPrimary ? AppColor.primaryNormal : AppColor.neutralLight,
      ),
    );
  }
}
