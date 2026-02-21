import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inclusive_app/core/theme/app_color.dart';
import 'package:inclusive_app/features/places/domain/entities/place_search_result.dart';
import 'package:inclusive_app/features/places/presentation/bloc/place_bloc.dart';
import 'package:inclusive_app/features/spot/presentation/widgets/recent_place_item.dart';
import 'package:inclusive_app/features/spot/presentation/widgets/spot_search_field.dart';

/// Widget para la vista de búsqueda de lugares.
class SpotSearchView extends StatelessWidget {
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final Function(PlaceSearchResult) onPlaceSelected;
  final VoidCallback onSearchChanged;

  const SpotSearchView({
    super.key,
    required this.searchController,
    required this.searchFocusNode,
    required this.onPlaceSelected,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Campo de búsqueda
        SpotSearchField(
          controller: searchController,
          focusNode: searchFocusNode,
          onChanged: (_) => onSearchChanged(),
        ),

        // Resultados de búsqueda
        Expanded(
          child: _buildSearchResults(),
        ),
      ],
    );
  }

  /// Construye la sección de resultados según el estado del PlaceBloc.
  Widget _buildSearchResults() {
    return BlocBuilder<PlaceBloc, PlacesState>(
      builder: (context, state) {
        if (state is PlacesLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColor.primaryNormal,
            ),
          );
        }

        if (state is PlacesLoaded) {
          final suggestions = state.suggestions;

          if (suggestions.isEmpty) {
            return const _EmptySearchResults(
              message: 'No se encontraron resultados',
            );
          }

          return _SearchResultsList(
            suggestions: suggestions,
            onPlaceSelected: onPlaceSelected,
          );
        }

        if (state is PlacesError) {
          return _EmptySearchResults(
            message: state.message,
            isError: true,
          );
        }

        // Estado inicial
        return const _EmptySearchResults(
          message: 'Busca un lugar para guardar',
          icon: Icons.search,
        );
      },
    );
  }
}

/// Widget para mostrar la lista de resultados de búsqueda.
class _SearchResultsList extends StatelessWidget {
  final List<PlaceSearchResult> suggestions;
  final Function(PlaceSearchResult) onPlaceSelected;

  const _SearchResultsList({
    required this.suggestions,
    required this.onPlaceSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final place = suggestions[index];
        return RecentPlaceItem(
          title: place.description,
          subtitle: place.address,
          onTap: () => onPlaceSelected(place),
        );
      },
    );
  }
}

/// Widget para mostrar mensaje cuando no hay resultados.
class _EmptySearchResults extends StatelessWidget {
  final String message;
  final IconData icon;
  final bool isError;

  const _EmptySearchResults({
    required this.message,
    this.icon = Icons.search,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: isError 
                  ? AppColor.accentNormal 
                  : AppColor.neutralDarkNormal,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: isError 
                    ? AppColor.accentNormal 
                    : AppColor.secondaryNormal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
