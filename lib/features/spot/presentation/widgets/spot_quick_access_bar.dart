import 'package:flutter/material.dart';
import 'package:inclusive_app/core/theme/app_color.dart';
import 'package:inclusive_app/features/spot/domain/entities/spot.dart';

/// Barra de acceso rápido con píldoras para spots guardados.
/// 
/// Casa y Trabajo siempre son visibles. Otros spots se muestran dinámicamente.
class SpotQuickAccessBar extends StatelessWidget {
  final List<Spot> spots;
  final Function(Spot)? onSpotTap;
  final VoidCallback? onAddHomeTap;
  final VoidCallback? onAddWorkTap;
  final VoidCallback? onAddTap;

  const SpotQuickAccessBar({
    super.key,
    required this.spots,
    this.onSpotTap,
    this.onAddHomeTap,
    this.onAddWorkTap,
    this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    // Buscar spots de Casa y Trabajo
    final homeSpot = _findSpotByType(['home', 'casa']);
    final workSpot = _findSpotByType(['work', 'trabajo']);
    
    // Filtrar otros spots (que no sean casa ni trabajo)
    final otherSpots = spots.where((spot) {
      final type = spot.type?.toLowerCase();
      return type != 'home' && type != 'casa' && type != 'work' && type != 'trabajo';
    }).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Píldora Casa (siempre visible)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _SpotPill(
              icon: Icons.home,
              label: 'Casa',
              onTap: homeSpot != null 
                  ? () => onSpotTap?.call(homeSpot)
                  : onAddHomeTap,
              isActive: homeSpot != null,
            ),
          ),
          
          // Píldora Trabajo (siempre visible)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _SpotPill(
              icon: Icons.work,
              label: 'Trabajo',
              onTap: workSpot != null 
                  ? () => onSpotTap?.call(workSpot)
                  : onAddWorkTap,
              isActive: workSpot != null,
            ),
          ),
          
          // Píldoras de otros spots guardados
          ...otherSpots.map((spot) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _SpotPill(
                  icon: Icons.location_on,
                  label: spot.spotName,
                  onTap: () => onSpotTap?.call(spot),
                  isActive: true,
                ),
              )),
          
          // Píldora Añadir
          _SpotPill(
            icon: Icons.add,
            label: 'Añadir',
            onTap: onAddTap,
            isActive: true,
            isAddButton: true,
          ),
        ],
      ),
    );
  }

  /// Busca un spot por tipo (case-insensitive).
  Spot? _findSpotByType(List<String> types) {
    try {
      return spots.firstWhere(
        (spot) => types.contains(spot.type?.toLowerCase()),
      );
    } catch (e) {
      return null;
    }
  }
}

/// Widget individual de píldora/chip.
class _SpotPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isActive;
  final bool isAddButton;

  const _SpotPill({
    required this.icon,
    required this.label,
    this.onTap,
    this.isActive = false,
    this.isAddButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24), // Radio suavizado
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Padding más amplio
          decoration: BoxDecoration(
            color: isActive 
                ? AppColor.secondaryDark.withOpacity(0.1)
                : AppColor.neutralLight,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isActive 
                  ? AppColor.secondaryDark.withOpacity(0.3)
                  : AppColor.neutralDarkNormal.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 24, // Ícono más grande para mayor visibilidad
                color: isActive 
                    ? AppColor.secondaryDarker 
                    : AppColor.secondaryNormal,
              ),
              const SizedBox(width: 8), // Más separación
              Text(
                label,
                style: TextStyle(
                  fontSize: 16, // Fuente más grande para legibilidad
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive 
                      ? AppColor.secondaryDarker 
                      : AppColor.secondaryNormal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
