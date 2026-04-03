import 'package:flutter/material.dart';
import 'package:inclusive_app/core/theme/app_color.dart';
import 'package:inclusive_app/core/constants/accessibility_medals.dart';

/// Sección que muestra las características de accesibilidad de un lugar.
/// 
/// Muestra las medallas o insignias que el lugar ha recibido basadas
/// en sus características de accesibilidad (rampas, ascensores, etc.).
class AccessibilityMedalsSection extends StatelessWidget {
  /// Lista de medallas de accesibilidad del lugar.
  final List<String> medals;

  const AccessibilityMedalsSection({
    super.key,
    required this.medals,
  });

  @override
  Widget build(BuildContext context) {
    if (medals.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle(),
        const SizedBox(height: 12),
        _buildMedalsList(),
      ],
    );
  }

  /// Construye el título de la sección.
  Widget _buildTitle() {
    return const Text(
      'Características de Accesibilidad',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColor.neutralDarkDarker,
      ),
    );
  }

  /// Construye la lista de medallas en formato Wrap.
  Widget _buildMedalsList() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: medals.map((medal) => _MedalChip(medal: medal)).toList(),
    );
  }
}

/// Chip individual que representa una medalla de accesibilidad.
class _MedalChip extends StatelessWidget {
  final String medal;

  const _MedalChip({required this.medal});

  @override
  Widget build(BuildContext context) {
    AccessibilityMedal? realMedal;
    final upperMedal = medal.toUpperCase();
    for (final m in AccessibilityMedalsHelper.orderedMedals) {
      if (m.apiName.toUpperCase() == upperMedal || m.displayName.toUpperCase() == upperMedal) {
        realMedal = m;
        break;
      }
    }
    
    final icon = realMedal?.icon ?? _getMedalIcon(medal);
    final labelText = realMedal?.displayName ?? medal;

    return Chip(
      avatar: Icon(icon, size: 18, color: AppColor.primaryNormal),
      label: Text(
        labelText,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: AppColor.primaryLight,
      side: BorderSide.none,
    );
  }

  /// Obtiene el ícono apropiado según el tipo de medalla.
  IconData _getMedalIcon(String medal) {
    final medalLower = medal.toLowerCase();

    if (medalLower.contains('rampa') || medalLower.contains('ramp')) {
      return Icons.accessible;
    }
    if (medalLower.contains('elevator') || medalLower.contains('ascensor')) {
      return Icons.elevator;
    }
    if (medalLower.contains('parking') || medalLower.contains('estacionamiento')) {
      return Icons.local_parking;
    }
    if (medalLower.contains('bathroom') || medalLower.contains('baño')) {
      return Icons.wc;
    }
    return Icons.check_circle;
  }
}