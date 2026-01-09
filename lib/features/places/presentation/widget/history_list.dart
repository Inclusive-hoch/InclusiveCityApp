import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inclusive_app/core/theme/app_color.dart';
import 'package:inclusive_app/features/places/domain/entities/place_search_result.dart';
import 'package:inclusive_app/features/places/presentation/bloc/place_bloc.dart';

/// Widget que muestra el historial de búsqueda de lugares.
///
/// Presenta una lista de lugares buscados recientemente, permitiendo al usuario
/// seleccionar uno para ver su ubicación en el mapa. Muestra un estado vacío
/// cuando no hay historial disponible.
///
/// Al seleccionar un lugar del historial:
/// - Dispara el evento [SelectPlaceEvent] al BLoC
/// - Quita el foco del campo de búsqueda
/// - Notifica al widget padre mediante el callback [onPlaceSelected]
class HistoryList extends StatelessWidget {
  /// Lista de lugares buscados recientemente.
  final List<PlaceSearchResult> history;
  
  /// Callback ejecutado cuando se selecciona un lugar del historial.
  final Function(String placeId) onPlaceSelected;
  
  /// Nodo de foco del campo de búsqueda para remover el foco al seleccionar.
  final FocusNode focusNode;

  const HistoryList({
    super.key,
    required this.history,
    required this.onPlaceSelected,
    required this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Recientes",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColor.neutralDarkDarker,
          ),
        ),
        const SizedBox(height: 8),

        if (history.isEmpty)
          _buildEmptyState()
        else
          ..._buildHistoryList(context),
      ],
    );
  }

  /// Construye el estado vacío cuando no hay historial de búsqueda.
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        "No hay busquedas recientes",
        style: TextStyle(
          color: AppColor.neutralDarkNormal,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  /// Construye la lista de elementos del historial de búsqueda.
  ///
  /// Retorna una lista de [ListTile] widgets, uno por cada lugar en el historial.
  List<Widget> _buildHistoryList(BuildContext context) {
    return history.map((place) {
      return _buildListTile(
        context: context,
        icon: Icons.history,
        title: place.description,
        subtitle: place.address,
        onTap: () => _handlePlaceSelection(context, place.placeId),
      );
    }).toList();
  }

  /// Maneja la selección de un lugar del historial.
  ///
  /// Parámetros:
  /// - [context]: Contexto de construcción para acceder al BLoC.
  /// - [placeId]: ID del lugar seleccionado.
  ///
  /// Ejecuta las siguientes acciones:
  /// 1. Dispara [SelectPlaceEvent] al BLoC de lugares
  /// 2. Quita el foco del campo de búsqueda
  /// 3. Notifica al widget padre mediante el callback [onPlaceSelected]
  void _handlePlaceSelection(BuildContext context, String placeId) {
    context.read<PlaceBloc>().add(SelectPlaceEvent(placeId));
    focusNode.unfocus();
    onPlaceSelected(placeId); // ✅ Notifica al padre, él decide qué hacer
  }

  /// Construye un [ListTile] personalizado para mostrar un elemento del historial.
  ///
  /// Parámetros:
  /// - [context]: Contexto de construcción.
  /// - [icon]: Icono a mostrar a la izquierda del elemento.
  /// - [title]: Título principal del elemento (nombre del lugar).
  /// - [subtitle]: Subtítulo opcional (dirección del lugar).
  /// - [iconColor]: Color opcional del icono. Por defecto usa [AppColor.neutralDarkNormal].
  /// - [onTap]: Callback ejecutado al tocar el elemento.
  Widget _buildListTile({
    required BuildContext context,
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
