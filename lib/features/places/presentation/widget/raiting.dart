import 'package:flutter/material.dart';
import 'package:inclusive_app/core/theme/app_color.dart';

/// Sección que muestra el rating y porcentaje de aprobación de un lugar.
/// 
/// Muestra un porcentaje de usuarios que aprueban o les gusta el lugar,
/// con un ícono de pulgar arriba y texto descriptivo.
class Rating extends StatelessWidget {
  /// Rating del lugar (0-100).
  final double rating;

  const Rating({
    super.key,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = rating.toInt();
    final hasRating = percentage > 0;

    return Row(
      children: [
        _buildIcon(),
        const SizedBox(width: 8),
        _buildPercentageText(percentage, hasRating),
        const SizedBox(width: 4),
        _buildDescriptionText(hasRating),
      ],
    );
  }

  /// Construye el ícono de pulgar arriba.
  Widget _buildIcon() {
    return const Icon(
      Icons.thumb_up,
      color: AppColor.primaryNormal,
      size: 24,
    );
  }

  /// Construye el texto del porcentaje.
  Widget _buildPercentageText(int percentage, bool hasRating) {
    final displayText = hasRating ? '$percentage%' : 'Sin calificación';

    return Text(
      displayText,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColor.primaryNormal,
      ),
    );
  }

  /// Construye el texto descriptivo.
  Widget _buildDescriptionText(bool hasRating) {
    return Text(
      hasRating ? 'le gusta este lugar' : '',
      style: const TextStyle(
        fontSize: 14,
        color: AppColor.neutralDarkNormal,
      ),
    );
  }
}