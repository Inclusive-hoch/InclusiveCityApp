import 'package:flutter/material.dart';
import 'package:inclusive_app/core/theme/app_color.dart';

/// Widget reutilizable para mostrar un campo de ubicación (origen o destino)
class LocationField extends StatelessWidget {
  final String locationName;
  final Color iconColor;
  final IconData iconData;
  final bool isEditable;
  final VoidCallback? onTap;

  const LocationField({
    super.key,
    required this.locationName,
    required this.iconColor,
    required this.iconData,
    this.isEditable = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Icono circular
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: iconColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            iconData,
            color: Colors.white,
            size: 14,
          ),
        ),
        const SizedBox(width: 12),
        
        // Campo de texto
        Expanded(
          child: GestureDetector(
            onTap: isEditable ? onTap : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isEditable 
                      ? AppColor.primaryNormal.withOpacity(0.4) 
                      : Colors.grey.shade300,
                  width: isEditable ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      locationName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isEditable) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.edit_location_alt_outlined,
                      size: 18,
                      color: AppColor.primaryNormal.withOpacity(0.7),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
