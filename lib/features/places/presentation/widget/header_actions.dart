import 'package:flutter/material.dart';
import 'package:inclusive_app/core/theme/app_color.dart';

/// Botones de acción en el header de la vista de detalles del lugar
/// 
/// Incluye botones para cerrar, guardar/eliminar de favoritos, y compartir.
class HeaderActions extends StatelessWidget {
  /// Callback cuando se presiona el botón de cerrar
  final VoidCallback onClose;
  
  /// Callback cuando se presiona el botón de guardar/favoritos
  final VoidCallback onSave;
  
  /// Callback cuando se presiona el botón de compartir
  final VoidCallback onShare;
  
  /// Indica si el lugar está guardado en favoritos
  final bool isSaved;

  const HeaderActions({
    super.key,
    required this.onClose,
    required this.onSave,
    required this.onShare,
    this.isSaved = false,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 40,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Botón guardar/favoritos
          _buildActionButton(
            icon: isSaved ? Icons.bookmark : Icons.bookmark_border,
            onTap: onSave,
          ),
          const SizedBox(width: 12),
          
          // Botón compartir
          _buildActionButton(
            icon: Icons.share,
            onTap: onShare,
          ),
          const SizedBox(width: 12),
          
          // Botón cerrar
          _buildActionButton(
            icon: Icons.close,
            onTap: onClose,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 22,
          color: AppColor.primaryNormal,
        ),
      ),
    );
  }
}
