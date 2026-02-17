import 'package:flutter/material.dart';
import 'package:inclusive_app/core/theme/app_color.dart';

/// Barra de acceso rápido con píldoras para Casa, Trabajo y Añadir.
/// 
/// Muestra chips interactivos para:
/// - 🏠 Casa: Navegar a lugar guardado como casa
/// - 💼 Trabajo: Navegar a lugar guardado como trabajo
/// - ➕ Añadir: Agregar nuevo lugar personalizado
class SpotQuickAccessBar extends StatelessWidget {
  /// Callback cuando se presiona la píldora "Casa".
  final VoidCallback? onHomeTap;

  /// Callback cuando se presiona la píldora "Trabajo".
  final VoidCallback? onWorkTap;

  /// Callback cuando se presiona la píldora "Añadir".
  final VoidCallback? onAddTap;

  /// Si tiene lugar guardado como casa.
  final bool hasHome;

  /// Si tiene lugar guardado como trabajo.
  final bool hasWork;

  const SpotQuickAccessBar({
    super.key,
    this.onHomeTap,
    this.onWorkTap,
    this.onAddTap,
    this.hasHome = false,
    this.hasWork = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Píldora Casa
          _SpotPill(
            icon: Icons.home,
            label: 'Casa',
            onTap: onHomeTap,
            isActive: hasHome,
          ),
          const SizedBox(width: 8),
          
          // Píldora Trabajo
          _SpotPill(
            icon: Icons.work,
            label: 'Trabajo',
            onTap: onWorkTap,
            isActive: hasWork,
          ),
          const SizedBox(width: 8),
          
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
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isActive 
                ? AppColor.secondaryDark.withOpacity(0.1)
                : AppColor.neutralLight,
            borderRadius: BorderRadius.circular(20),
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
                size: 18,
                color: isActive 
                    ? AppColor.secondaryDarker 
                    : AppColor.secondaryNormal,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
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
