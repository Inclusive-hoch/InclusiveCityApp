// lib/features/profile/presentation/widgets/profile_menu_item.dart

import 'package:flutter/material.dart';
import 'package:inclusive_app/core/theme/app_color.dart';

/// Widget de opción del menú de perfil
/// 
/// Muestra un ícono a la izquierda, texto y es clickeable
class ProfileMenuItem extends StatelessWidget {
  /// Ícono a mostrar
  final IconData icon;
  
  /// Texto del menú
  final String label;
  
  /// Callback al hacer tap
  final VoidCallback onTap;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColor.primaryNormal,
              size: 30,
            ),
            
            const SizedBox(width: 16),
            
            // Texto del menú
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColor.secondaryNormal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}