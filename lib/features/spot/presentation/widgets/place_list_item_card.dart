import 'package:flutter/material.dart';
import 'package:inclusive_app/core/theme/app_color.dart';
import 'package:inclusive_app/features/spot/domain/entities/spot.dart';

/// Tarjeta que muestra un lugar dentro de una lista personalizada.
/// 
/// Incluye nombre, dirección y acciones para ver detalles o eliminar.
class PlaceListItemCard extends StatelessWidget {
  final Spot spot;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const PlaceListItemCard({
    super.key,
    required this.spot,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Ícono de lugar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColor.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.place,
                  color: AppColor.primaryNormal,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),

              // Información del lugar
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      spot.spotName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            spot.address,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (spot.type != null) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.primaryLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          spot.type!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColor.primaryNormal,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Botón de eliminar
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: Colors.red[400],
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
