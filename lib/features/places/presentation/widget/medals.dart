import 'package:flutter/material.dart';
import 'package:inclusive_app/core/theme/app_color.dart';
import 'package:inclusive_app/core/utils/accessibility_medals.dart';

/// Sección que muestra las características de accesibilidad de un lugar.
///
/// Muestra las medallas o insignias que el lugar ha recibido, deduplicadas
/// y usando el sistema estándar de medallas de accesibilidad.
class AccessibilityMedalsSection extends StatelessWidget {
  /// Lista de medallas de accesibilidad del lugar (strings del backend).
  final List<String> medals;

  const AccessibilityMedalsSection({
    super.key,
    required this.medals,
  });

  /// Convierte la lista de strings del backend en medallas únicas y ordenadas.
  ///
  /// Deduplica usando el [AccessibilityMedal.apiName] como clave, de modo que
  /// si el backend envía "BANOS" dos veces, solo se muestra una vez.
  List<AccessibilityMedal> get _uniqueMedals {
    final seen = <String>{};
    final result = <AccessibilityMedal>[];
    for (final apiName in medals) {
      final medal = AccessibilityMedalsHelper.fromApiName(apiName);
      if (medal == null) continue;
      // Usamos el apiName de la medalla resuelta para deduplicar
      // (banosLimpios y banos comparten el mismo apiName "BANOS")
      final key = medal.apiName;
      if (seen.add(key)) {
        result.add(medal);
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final uniqueMedals = _uniqueMedals;
    if (uniqueMedals.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle(),
        const SizedBox(height: 12),
        _buildMedalsList(uniqueMedals),
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
  Widget _buildMedalsList(List<AccessibilityMedal> uniqueMedals) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: uniqueMedals.map((medal) => _MedalChip(medal: medal)).toList(),
    );
  }
}

/// Ícono circular que representa una medalla de accesibilidad.
///
/// Usa el mismo estilo visual que las tarjetas de evaluaciones del perfil:
/// círculo con fondo [AppColor.primaryLight] e ícono [AppColor.primaryNormal].
/// El [Tooltip] muestra el nombre al mantener presionado.
class _MedalChip extends StatelessWidget {
  final AccessibilityMedal medal;

  const _MedalChip({required this.medal});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: medal.displayName,
      child: Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColor.primaryLight,
        ),
        child: Icon(medal.icon, color: AppColor.primaryNormal, size: 26),
      ),
    );
  }
}