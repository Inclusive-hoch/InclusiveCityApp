import 'package:flutter/material.dart';
import 'package:inclusive_app/core/theme/app_color.dart';

/// Widget para mostrar cuando no hay lugares guardados.
/// 
/// Muestra un mensaje informativo y sugiere al usuario agregar lugares.
class EmptySavedPlaces extends StatelessWidget {
  /// Callback cuando se presiona el botón de agregar.
  final VoidCallback? onAddPlace;

  const EmptySavedPlaces({
    super.key,
    this.onAddPlace,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColor.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_on_outlined,
                size: 64,
                color: AppColor.primaryNormal,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No tienes lugares guardados',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColor.secondaryDarker,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Agrega lugares que visitas frecuentemente para acceder a ellos rápidamente',
              style: TextStyle(
                fontSize: 14,
                color: AppColor.secondaryNormal,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (onAddPlace != null)
              ElevatedButton.icon(
                onPressed: onAddPlace,
                icon: const Icon(Icons.add),
                label: const Text('Agregar lugar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryNormal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
