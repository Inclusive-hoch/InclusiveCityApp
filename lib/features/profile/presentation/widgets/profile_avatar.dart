// lib/features/profile/presentation/widgets/profile_avatar.dart

import 'package:flutter/material.dart';
import 'package:inclusive_app/core/theme/app_color.dart';

/// Widget de avatar de perfil reutilizable
/// 
/// Muestra:
/// - Imagen de red si hay [photoUrl]
/// - Ícono de persona como fallback si no hay foto
/// 
/// [size] define el diámetro del círculo
class ProfileAvatar extends StatelessWidget {
  /// URL de la imagen de perfil (puede ser null)
  final String? photoUrl;
  
  /// Tamaño del avatar en píxeles
  final double size;

  const ProfileAvatar({
    super.key,
    this.photoUrl,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColor.neutralNormalHover,
        border: Border.all(
          color: AppColor.neutralNormalActive,
          width: 2,
        ),
        // Imagen de fondo si existe photoUrl
        image: photoUrl != null
            ? DecorationImage(
                image: NetworkImage(photoUrl!),
                fit: BoxFit.cover,
                onError: (_, __) {}, // Silencia errores de carga
              )
            : null,
      ),
      // Si no hay imagen, muestra ícono de persona
      child: photoUrl == null
          ? Icon(
              Icons.person,
              size: size * 0.5,
              color: AppColor.neutralDarkHover,
            )
          : null,
    );
  }
}