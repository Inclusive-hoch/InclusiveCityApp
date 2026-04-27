import 'package:flutter/material.dart';
import 'package:inclusive_app/core/theme/app_color.dart';

/// Sección de feedback para calificar un lugar.
/// 
/// Permite al usuario expresar su opinión sobre un lugar mediante
/// botones de like (me gusta) o dislike (no me gusta).
class Feedback extends StatelessWidget {
  /// ID del lugar para enviar el feedback.
  final String placeId;

  /// Callback cuando el usuario da like al lugar.
  final VoidCallback? onLike;

  /// Callback cuando el usuario da dislike al lugar.
  final VoidCallback? onDislike;

  /// Opción seleccionada previamente por el usuario (LIKE o DISLIKE).
  final String? selectedRateChoice;

  const Feedback({
    super.key,
    required this.placeId,
    this.onLike,
    this.onDislike,
    this.selectedRateChoice,
  });

  bool get _hasVoted => selectedRateChoice != null;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle(),
        const SizedBox(height: 16),
        _buildFeedbackButtons(context),
      ],
    );
  }

  /// Construye el título de la sección.
  Widget _buildTitle() {
    return Text(
      _hasVoted
          ? 'Ya calificaste este lugar'
          : '¿Qué te parece este lugar?',
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColor.neutralDarkDarker,
      ),
    );
  }

  /// Construye los botones de like y dislike.
  Widget _buildFeedbackButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLikeButton(context),
        const SizedBox(width: 24),
        _buildDislikeButton(context),
      ],
    );
  }

  /// Construye el botón de like (me gusta).
  Widget _buildLikeButton(BuildContext context) {
    final isSelected = selectedRateChoice == 'LIKE';
    return _FeedbackButton(
      icon: Icons.thumb_up_rounded,
      iconColor: AppColor.success,
      backgroundColor: AppColor.greenLight,
      isSelected: isSelected,
      onPressed: _handleLike,
    );
  }

  /// Construye el botón de dislike (no me gusta).
  Widget _buildDislikeButton(BuildContext context) {
    final isSelected = selectedRateChoice == 'DISLIKE';
    return _FeedbackButton(
      icon: Icons.thumb_down_rounded,
      iconColor: AppColor.error,
      backgroundColor: AppColor.redLight,
      isSelected: isSelected,
      onPressed: _handleDislike,
    );
  }

  /// Maneja el evento de like.
  void _handleLike() {
    onLike?.call();
  }

  /// Maneja el evento de dislike.
  void _handleDislike() {
    onDislike?.call();
  }
}

/// Botón circular de feedback reutilizable.
class _FeedbackButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final bool isSelected;
  final VoidCallback onPressed;

  const _FeedbackButton({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    this.isSelected = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = isSelected
        ? iconColor
        : backgroundColor;
    final effectiveIconColor = isSelected
        ? Colors.white
        : iconColor;

    return Container(
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: BorderRadius.circular(50),
        border: isSelected ? Border.all(color: iconColor, width: 2) : null,
      ),
      child: IconButton(
        icon: Icon(icon),
        color: effectiveIconColor,
        iconSize: 32,
        padding: const EdgeInsets.all(16),
        onPressed: onPressed,
      ),
    );
  }
}