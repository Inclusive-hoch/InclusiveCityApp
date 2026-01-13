import 'package:flutter/material.dart';
import 'package:inclusive_app/core/theme/app_color.dart';
import 'package:inclusive_app/features/places/domain/entities/place_search_result.dart';

/// Widget que muestra los resultados de búsqueda de lugares en tiempo real.
///
/// Presenta una lista de sugerencias de lugares obtenidas de la API de búsqueda
/// mientras el usuario escribe en el campo de búsqueda. Cada resultado muestra
/// el nombre y dirección del lugar, permitiendo al usuario seleccionar uno.
///
/// Cuando se selecciona un resultado, notifica al widget padre mediante el
/// callback [onSuggestionSelected] para que maneje la selección.
class SearchResultsList extends StatelessWidget {
  /// Lista de resultados de búsqueda obtenidos de la API.
  final List<PlaceSearchResult> results;
  
  /// Callback ejecutado cuando el usuario selecciona una sugerencia.
  final Function(PlaceSearchResult results) onSuggestionSelected;

  const SearchResultsList({
    super.key,
    required this.results,
    required this.onSuggestionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: results.map((suggestion) {
        return _buildListTile(
          icon: Icons.location_on,
          title: suggestion.description,
          subtitle: suggestion.address,
          onTap: () => onSuggestionSelected(suggestion),
        );
      }).toList(),
    );
  }

  /// Construye un [ListTile] personalizado para mostrar un resultado de búsqueda.
  ///
  /// Parámetros:
  /// - [icon]: Icono a mostrar a la izquierda del elemento.
  /// - [title]: Título principal del elemento (nombre/descripción del lugar).
  /// - [subtitle]: Subtítulo opcional (dirección del lugar).
  /// - [iconColor]: Color opcional del icono. Por defecto usa [AppColor.neutralDarkNormal].
  /// - [onTap]: Callback ejecutado al tocar el elemento.
  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppColor.neutralDarkNormal),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColor.neutralDarkDarker,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(color: AppColor.neutralDarkNormal),
            )
          : null,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
    );
  }
}
