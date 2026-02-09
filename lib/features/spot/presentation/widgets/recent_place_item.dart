import 'package:flutter/material.dart';
import 'package:inclusive_app/core/theme/app_color.dart';

/// Widget para mostrar un lugar reciente en la lista.
/// 
/// Muestra:
/// - Icono de reloj/historial
/// - Texto del lugar
/// - Callback al tocar
class RecentPlaceItem extends StatelessWidget {
  /// Texto a mostrar (descripción del lugar).
  final String title;

  /// Subtítulo opcional (dirección).
  final String? subtitle;

  /// Callback cuando se presiona el item.
  final VoidCallback? onTap;

  const RecentPlaceItem({
    super.key,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColor.neutralLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.access_time,
          color: AppColor.secondaryNormal,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColor.secondaryDarker,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 14,
                color: AppColor.secondaryNormal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      onTap: onTap,
    );
  }
}
