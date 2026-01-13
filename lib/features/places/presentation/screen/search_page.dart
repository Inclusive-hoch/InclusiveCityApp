import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inclusive_app/core/theme/app_color.dart';
import 'package:inclusive_app/features/places/domain/entities/place_search_result.dart';
import 'package:inclusive_app/features/places/presentation/bloc/place_bloc.dart';
import 'package:inclusive_app/features/places/presentation/widget/history_list.dart';
import 'package:inclusive_app/features/places/presentation/widget/search_bar.dart' as custom;
import 'package:inclusive_app/features/places/presentation/widget/search_result_list.dart';
import 'package:inclusive_app/shared/widgets/grabber.dart';

/// Página de búsqueda de lugares con panel deslizable.
/// 
/// Muestra una interfaz de búsqueda que reacciona a diferentes estados:
/// - Historial de búsquedas cuando no hay búsqueda activa
/// - Resultados de búsqueda en tiempo real
/// - Estados de carga y error
/// 
/// Diseñada para usarse dentro de un [DraggableScrollableSheet].
class SearchPage extends StatelessWidget {
  /// Controlador para conectar el scroll de la lista con el panel deslizable.
  final ScrollController scrollController;

  const SearchPage({
    super.key,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColor.neutralLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: ListView(
        controller: scrollController,
        padding: EdgeInsets.zero,
        children: [
          const Center(child: Grabber()),

          const custom.SearchBar(),
          const SizedBox(height: 16),

          BlocBuilder<PlaceBloc, PlacesState>(
            builder: (context, state) {
              if (state is PlacesLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(color: AppColor.primaryNormal),
                  ),
                );
              }

              if (state is PlacesLoaded) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SearchResultsList(
                    results: state.suggestions,
                    onSuggestionSelected: (place) {
                      context.read<PlaceBloc>().add(SelectPlaceEvent(place.placeId));
                    },
                  ),
                );
              }
              if (state is SearchHistoryLoaded || state is PlacesInitial) {
                final List<PlaceSearchResult> history = (state is SearchHistoryLoaded) ? state.history : [];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: HistoryList(
                    history: history,
                    focusNode: FocusNode(),
                    onPlaceSelected: (placeId) {
                      context.read<PlaceBloc>().add(SelectPlaceEvent(placeId));
                    },
                  ),
                );
              }

              if (state is PlacesError) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: AppColor.error),
                    ),
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
          
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}