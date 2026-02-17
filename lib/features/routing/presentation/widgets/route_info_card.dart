import 'package:flutter/material.dart';
import 'package:inclusive_app/core/theme/app_color.dart';
import 'package:inclusive_app/features/routing/domain/entities/route_info.dart';

/// Widget que muestra información de una ruta calculada.
/// 
/// Muestra la distancia y duración estimada de forma compacta.
/// Útil para mostrar en el mapa mientras se visualiza una ruta.
class RouteInfoCard extends StatelessWidget {
  /// La información de la ruta a mostrar
  final RouteInfo routeInfo;
  
  /// Si es verdadero, usa estilo para ruta principal, sino para alternativa
  final bool isPrimary;

  const RouteInfoCard({
    super.key,
    required this.routeInfo,
    this.isPrimary = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Indicador de color de ruta
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: isPrimary ? AppColor.primaryNormal : Colors.orange,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          
          // Información de distancia y tiempo
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                routeInfo.formattedDuration,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColor.neutralDarkNormal,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                routeInfo.formattedDistance,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColor.neutralDarkLight,
                ),
              ),
            ],
          ),
          
          const SizedBox(width: 8),
          
          // Icono de navegación
          Icon(
            Icons.navigation,
            size: 20,
            color: isPrimary ? AppColor.primaryNormal : Colors.orange,
          ),
        ],
      ),
    );
  }
}
