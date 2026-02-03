import 'package:flutter/material.dart';
import 'package:inclusive_app/core/theme/app_color.dart';
import 'package:inclusive_app/features/profile/domain/entities/user_evaluation.dart';

/// Widget que muestra una tarjeta de evaluación del usuario
class UserEvaluationCard extends StatelessWidget {
  final UserEvaluation evaluation;
  final String? placeName;
  final String? placeType;
  final String? imageUrl;
  final VoidCallback? onTap;

  const UserEvaluationCard({
    super.key,
    required this.evaluation,
    this.placeName,
    this.placeType,
    this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen del lugar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 100,
                    height: 70,
                    color: AppColor.neutralNormalHover,
                    child: imageUrl != null
                        ? Image.network(
                            imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.image_not_supported,
                              color: AppColor.neutralDarkHover,
                            ),
                          )
                        : const Icon(
                            Icons.place,
                            color: AppColor.neutralDarkHover,
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                // Información del lugar
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        placeName ?? 'Lugar desconocido',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColor.secondaryNormal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        placeType ?? 'Tipo no especificado',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColor.neutralDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildRateIndicator(),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Botones de acción
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionButton(
                  icon: Icons.accessibility_new,
                  onTap: () {
                    // TODO: Navegar a detalles de accesibilidad
                  },
                ),
                const SizedBox(width: 16),
                _buildFormIndicator(),
              ],
            ),
            const Divider(color: AppColor.primaryLight, height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildRateIndicator() {
    final isLiked = evaluation.rate.toLowerCase() == 'like';
    return Row(
      children: [
        Icon(
          isLiked ? Icons.thumb_up : Icons.thumb_down,
          size: 16,
          color: AppColor.primaryNormal,
        ),
        const SizedBox(width: 4),
        Text(
          isLiked ? 'Te gusta este lugar' : 'No te gusta este lugar',
          style: const TextStyle(
            fontSize: 12,
            color: AppColor.primaryNormal,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColor.primaryLight,
        ),
        child: Icon(
          icon,
          color: AppColor.primaryNormal,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildFormIndicator() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColor.primaryLight,
      ),
      child: Center(
        child: Text(
          'E',
          style: const TextStyle(
            color: AppColor.primaryNormal,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}