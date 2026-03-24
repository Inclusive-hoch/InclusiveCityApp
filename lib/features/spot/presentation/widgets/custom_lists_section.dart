import 'package:flutter/material.dart';
import 'package:inclusive_app/core/theme/app_color.dart';
import 'package:inclusive_app/features/spot/domain/entities/custom_spot.dart';
import 'package:inclusive_app/features/spot/presentation/widgets/list_detail_bottom_sheet.dart';

/// Sección que muestra las listas personalizadas del usuario.
/// 
/// Incluye:
/// - Título "Mis listas"
/// - Lista de custom spots (Destacados, Favoritos, etc.)
/// - Botón "Agregar lista"
class CustomListsSection extends StatelessWidget {
  final List<CustomSpot> customSpots;
  final VoidCallback? onAddListTap;

  const CustomListsSection({
    super.key,
    required this.customSpots,
    this.onAddListTap,
  });

  @override
  Widget build(BuildContext context) {
    // Listas predeterminadas que siempre deben aparecer
    const destacadosName = 'Destacados';
    const favoritosName = 'Favoritos';
    
    // Buscar si existen en customSpots (con manejo defensivo)
    CustomSpot? destacadosSpot;
    CustomSpot? favoritosSpot;
    
    try {
      destacadosSpot = customSpots.firstWhere(
        (spot) => spot.listName == destacadosName,
      );
    } catch (_) {
      // No existe, crear uno temporal
      destacadosSpot = const CustomSpot(
        userId: '',
        listName: destacadosName,
        spotList: [],
      );
    }
    
    try {
      favoritosSpot = customSpots.firstWhere(
        (spot) => spot.listName == favoritosName,
      );
    } catch (_) {
      // No existe, crear uno temporal
      favoritosSpot = const CustomSpot(
        userId: '',
        listName: favoritosName,
        spotList: [],
      );
    }
    
    // Otras listas (que no sean predeterminadas)
    final otherSpots = customSpots.where(
      (spot) => spot.listName != destacadosName && spot.listName != favoritosName,
    ).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Mis listas',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColor.neutralDarkDark,
            ),
          ),
        ),
        
        // Listas predeterminadas (siempre visibles)
        _CustomListItem(
          customSpot: destacadosSpot,
          onTap: () {
            ListDetailBottomSheet.show(context, destacadosName);
          },
        ),
        _CustomListItem(
          customSpot: favoritosSpot,
          onTap: () {
            ListDetailBottomSheet.show(context, favoritosName);
          },
        ),
        
        // Otras listas personalizadas
        ...otherSpots.map((customSpot) => _CustomListItem(
          customSpot: customSpot,
          onTap: () {
            ListDetailBottomSheet.show(context, customSpot.listName);
          },
        )),
        
        // Botón Agregar lista
        _AddListButton(onTap: onAddListTap),
      ],
    );
  }
}

/// Widget individual de item de lista personalizada.
class _CustomListItem extends StatelessWidget {
  final CustomSpot customSpot;
  final VoidCallback? onTap;

  const _CustomListItem({
    required this.customSpot,
    this.onTap,
  });

  /// Obtiene el icono según el nombre de la lista.
  IconData _getIconForList(String listName) {
    final lowerName = listName.toLowerCase();
    if (lowerName.contains('destacado')) {
      return Icons.star;
    } else if (lowerName.contains('favorito')) {
      return Icons.favorite;
    } else {
      return Icons.bookmark;
    }
  }

  /// Obtiene el color según el nombre de la lista.
  Color _getColorForList(String listName) {
    final lowerName = listName.toLowerCase();
    if (lowerName.contains('destacado')) {
      return const Color(0xFFFFC107); // Amarillo/dorado
    } else if (lowerName.contains('favorito')) {
      return const Color(0xFFE91E63); // Rosa
    } else {
      return AppColor.primaryNormal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final icon = _getIconForList(customSpot.listName);
    final color = _getColorForList(customSpot.listName);
    final placeCount = customSpot.spotList.length;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Icono de la lista
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(width: 16),
            
            // Nombre y contador
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customSpot.listName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColor.neutralDarkDark,
                    ),
                  ),
                  Text(
                    '$placeCount ${placeCount == 1 ? 'lugar' : 'lugares'}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColor.neutralDarkNormal,
                    ),
                  ),
                ],
              ),
            ),
            
            // Flecha de navegación
            const Icon(
              Icons.chevron_right,
              color: AppColor.neutralDarkNormal,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

/// Botón para agregar nueva lista.
class _AddListButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _AddListButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Icono de agregar
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              child: const Icon(
                Icons.add,
                color: AppColor.primaryNormal,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            
            // Texto
            const Text(
              'Agregar lista',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColor.primaryNormal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
