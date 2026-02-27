import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inclusive_app/core/theme/app_color.dart';
import 'package:inclusive_app/features/routing/presentation/widgets/location_field.dart';

/// Widget flotante que muestra los campos de origen y destino de la ruta
class RouteLocationCard extends StatelessWidget {
  final String originName;
  final String destName;
  final VoidCallback onOriginTap;
  final VoidCallback onDestTap;

  const RouteLocationCard({
    super.key,
    required this.originName,
    required this.destName,
    required this.onOriginTap,
    required this.onDestTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 60,
      left: 16,
      right: 16,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Fila del origen
            Row(
              children: [
                // Icono de origen
                SizedBox(
                  width: 24,
                  height: 24,
                  child: SvgPicture.asset(
                    'assets/routeLogo/inicio_ruta.svg',
                    width: 24,
                    height: 24,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 12),
                // Campo de origen
                Expanded(
                  child: GestureDetector(
                    onTap: onOriginTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColor.primaryNormal.withOpacity(0.4),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              originName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.edit_location_alt_outlined,
                            size: 18,
                            color: AppColor.primaryNormal.withOpacity(0.7),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Tres puntos conectores
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Row(
                children: [
                  Column(
                    children: List.generate(
                      3,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Fila del destino
            Row(
              children: [
                // Icono de destino
                SizedBox(
                  width: 24,
                  height: 24,
                  child: SvgPicture.asset(
                    'assets/routeLogo/llegada_logo.svg',
                    width: 24,
                    height: 24,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 12),
                // Campo de destino
                Expanded(
                  child: GestureDetector(
                    onTap: onDestTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColor.primaryNormal.withOpacity(0.4),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              destName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.edit_location_alt_outlined,
                            size: 18,
                            color: AppColor.primaryNormal.withOpacity(0.7),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
