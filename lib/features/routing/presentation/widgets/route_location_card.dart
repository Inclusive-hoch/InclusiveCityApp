import 'package:flutter/material.dart';
import 'package:inclusive_app/core/theme/app_color.dart';
import 'package:inclusive_app/features/routing/presentation/widgets/location_field.dart';

/// Widget flotante que muestra los campos de origen y destino de la ruta
class RouteLocationCard extends StatelessWidget {
  final String originName;
  final String destName;
  final VoidCallback onOriginTap;
  final VoidCallback onDestTap;

  const RouteLocationCard({
    super.key,
    required this.originName,
    required this.destName,
    required this.onOriginTap,
    required this.onDestTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 60,
      left: 16,
      right: 16,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Campo de origen
            LocationField(
              locationName: originName,
              iconColor: AppColor.primaryNormal,
              iconData: Icons.my_location,
              isEditable: true,
              onTap: onOriginTap,
            ),
            
            const SizedBox(height: 12),
            
            // Campo de destino
            LocationField(
              locationName: destName,
              iconColor: Colors.red,
              iconData: Icons.place,
              isEditable: true,
              onTap: onDestTap,
            ),
          ],
        ),
      ),
    );
  }
}
