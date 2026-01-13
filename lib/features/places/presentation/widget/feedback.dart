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

  const Feedback({
    super.key,
    required this.placeId,
    this.onLike,
    this.onDislike,
  });

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
    return const Text(
      '¿Qué te parece este lugar?',
      style: TextStyle(
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
    return _FeedbackButton(
      icon: Icons.thumb_up_rounded,
      iconColor: AppColor.success,
      backgroundColor: AppColor.greenLight,
      onPressed: () => _handleLike(context),
    );
  }

  /// Construye el botón de dislike (no me gusta).
  Widget _buildDislikeButton(BuildContext context) {
    return _FeedbackButton(
      icon: Icons.thumb_down_rounded,
      iconColor: AppColor.error,
      backgroundColor: AppColor.redLight,
      onPressed: () => _handleDislike(context),
    );
  }

  /// Maneja el evento de like.
  void _handleLike(BuildContext context) {
    onLike?.call();
    _showFeedbackMessage(context);
  }

  /// Maneja el evento de dislike.
  void _handleDislike(BuildContext context) {
    onDislike?.call();
    _showFeedbackMessage(context);
  }

  /// Muestra mensaje de confirmación.
  void _showFeedbackMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Gracias por tu opinión!'),
        backgroundColor: AppColor.success,
        duration: Duration(seconds: 2),
      ),
    );
  }
}

/// Botón circular de feedback reutilizable.
class _FeedbackButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final VoidCallback onPressed;

  const _FeedbackButton({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(50),
      ),
      child: IconButton(
        icon: Icon(icon),
        color: iconColor,
        iconSize: 32,
        padding: const EdgeInsets.all(16),
        onPressed: onPressed,
      ),
    );
  }
}