import 'package:flutter/material.dart';
import 'package:inclusive_app/core/theme/app_color.dart';

/// AppBar personalizado para la vista de lugares guardados.
/// 
/// Incluye:
/// - Botón de retroceso
/// - Título "Lugares guardados"
/// - Botón de cerrar (opcional)
class SavedPlacesAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Callback cuando se presiona el botón de retroceso.
  final VoidCallback? onBack;

  /// Callback cuando se presiona el botón de cerrar.
  final VoidCallback? onClose;

  /// Si debe mostrar el botón de cerrar.
  final bool showCloseButton;

  const SavedPlacesAppBar({
    super.key,
    this.onBack,
    this.onClose,
    this.showCloseButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back,
          color: AppColor.secondaryDarker,
        ),
        onPressed: onBack ?? () => Navigator.of(context).pop(),
      ),
      title: const Text(
        'Lugares guardados',
        style: TextStyle(
          color: AppColor.secondaryDarker,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      actions: showCloseButton
          ? [
              IconButton(
                icon: const Icon(
                  Icons.close,
                  color: AppColor.secondaryDarker,
                ),
                onPressed: onClose ?? () => Navigator.of(context).pop(),
              ),
            ]
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
