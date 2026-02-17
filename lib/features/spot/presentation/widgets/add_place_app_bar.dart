import 'package:flutter/material.dart';
import 'package:inclusive_app/core/theme/app_color.dart';

/// AppBar personalizado para la vista de agregar lugar.
/// 
/// Incluye:
/// - Botón de retroceso
/// - Título "Agregar lugar"
/// - Botón de cerrar
class AddPlaceAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Callback cuando se presiona el botón de retroceso.
  final VoidCallback? onBack;

  /// Callback cuando se presiona el botón de cerrar.
  final VoidCallback? onClose;

  const AddPlaceAppBar({
    super.key,
    this.onBack,
    this.onClose,
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
        'Agregar lugar',
        style: TextStyle(
          color: AppColor.secondaryDarker,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(
            Icons.close,
            color: AppColor.secondaryDarker,
          ),
          onPressed: onClose ?? () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
