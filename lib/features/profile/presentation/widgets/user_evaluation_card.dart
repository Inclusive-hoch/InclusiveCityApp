import 'package:flutter/material.dart';
import 'package:inclusive_app/core/auth/firebase_auth_service.dart';
import 'package:inclusive_app/core/utils/accessibility_medals.dart';
import 'package:inclusive_app/core/constants/api_constants.dart';
import 'package:inclusive_app/core/theme/app_color.dart';
import 'package:inclusive_app/features/profile/domain/entities/user_evaluation.dart';
import 'package:inclusive_app/injection_container.dart' as di;

/// Widget que muestra una tarjeta de evaluación del usuario
class UserEvaluationCard extends StatefulWidget {
  final UserEvaluation evaluation;
  final String? placeName;
  final String? placeType;
  final String? photoReference;
  final VoidCallback? onTap;

  const UserEvaluationCard({
    super.key,
    required this.evaluation,
    this.placeName,
    this.placeType,
    this.photoReference,
    this.onTap,
  });

  @override
  State<UserEvaluationCard> createState() => _UserEvaluationCardState();
}

class _UserEvaluationCardState extends State<UserEvaluationCard> {
  String _authToken = '';

  @override
  void initState() {
    super.initState();
    _loadAuthToken();
  }

  /// Carga el token de autenticación para las fotos.
  Future<void> _loadAuthToken() async {
    final token = await di.sl<FirebaseAuthService>().getIdToken();
    if (mounted) {
      setState(() {
        _authToken = token;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtener las medallas confirmadas basado en forms
    final confirmedMedals = AccessibilityMedalsHelper.getConfirmedMedals(
      widget.evaluation.forms,
    );

    return InkWell(
      onTap: widget.onTap,
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
                    child: _buildPlaceImage(),
                  ),
                ),
                const SizedBox(width: 12),
                // Información del lugar
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.placeName ?? 'Lugar desconocido',
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
                        widget.placeType ?? 'Tipo no especificado',
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
            // Iconos de medallas confirmadas
            _buildMedalsRow(confirmedMedals),
            const Divider(color: AppColor.primaryLight, height: 24),
          ],
        ),
      ),
    );
  }

  /// Construye la imagen del lugar con autenticación
  Widget _buildPlaceImage() {
    // Si no hay token aún, mostrar loading
    if (_authToken.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColor.primaryNormal,
          strokeWidth: 2,
        ),
      );
    }

    // Si no hay foto, mostrar icono de lugar
    if (widget.photoReference == null || widget.photoReference!.isEmpty) {
      return const Icon(
        Icons.place,
        color: AppColor.neutralDarkHover,
        size: 40,
      );
    }

    // Cargar imagen con autenticación
    return Image.network(
      ApiConstants.placePhoto(widget.photoReference!),
      fit: BoxFit.cover,
      headers: {'Authorization': 'Bearer $_authToken'},
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                : null,
            color: AppColor.primaryNormal,
            strokeWidth: 2,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return const Icon(
          Icons.image_not_supported,
          color: AppColor.neutralDarkHover,
          size: 40,
        );
      },
    );
  }

  Widget _buildRateIndicator() {
    final isLiked = widget.evaluation.rateChoice.toUpperCase() == 'LIKE';
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
          style: const TextStyle(fontSize: 12, color: AppColor.primaryNormal),
        ),
      ],
    );
  }

  /// Construye la fila de iconos de medallas confirmadas
  Widget _buildMedalsRow(List<AccessibilityMedal> confirmedMedals) {
    if (confirmedMedals.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: confirmedMedals.map((medal) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: _buildMedalIcon(medal),
        );
      }).toList(),
    );
  }

  /// Construye un icono individual de medalla
  Widget _buildMedalIcon(AccessibilityMedal medal) {
    return Tooltip(
      message: medal.displayName,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColor.primaryLight,
        ),
        child: Icon(medal.icon, color: AppColor.primaryNormal, size: 26),
      ),
    );
  }
}
