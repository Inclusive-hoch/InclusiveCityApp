import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inclusive_app/core/theme/app_color.dart';
import 'package:inclusive_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:inclusive_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:inclusive_app/features/places/domain/entities/place_search_result.dart';
import 'package:inclusive_app/features/places/presentation/bloc/place_bloc.dart';
import 'package:inclusive_app/features/places/presentation/widget/history_list.dart';
import 'package:inclusive_app/features/places/presentation/widget/search_result_list.dart';
import 'package:inclusive_app/features/spot/domain/entities/spot.dart';
import 'package:inclusive_app/features/spot/presentation/bloc/spot_bloc.dart';
import 'package:inclusive_app/features/spot/presentation/widgets/spot_quick_access_bar.dart';
import 'package:inclusive_app/shared/widgets/grabber.dart';

/// Modal bottom sheet para seleccionar la ubicación de origen de una ruta.
///
/// Muestra búsqueda de lugares, acceso rápido a spots guardados (Casa/Trabajo)
/// e historial de búsquedas, replicando la experiencia de la pantalla principal.
class OriginLocationSheet {
  /// Muestra el modal de selección de ubicación.
  ///
  /// [onOriginSelected] se llama con el nombre, latitud y longitud del lugar elegido.
  /// [title] personaliza el título del sheet (por defecto: 'Seleccionar origen').
  static void show(
    BuildContext context, {
    required void Function(String name, double lat, double lng) onOriginSelected,
    String title = 'Seleccionar origen',
  }) {
    final placeBloc = context.read<PlaceBloc>();
    final spotBloc = context.read<SpotBloc>();
    placeBloc.add(LoadSearchHistoryEvent());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => MultiBlocProvider(
        providers: [
          BlocProvider<PlaceBloc>.value(value: placeBloc),
          BlocProvider<SpotBloc>.value(value: spotBloc),
        ],
        child: DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          snap: true,
          snapSizes: const [0.5, 0.75, 0.95],
          builder: (_, scrollController) => _OriginSheetContent(
            scrollController: scrollController,
            onOriginSelected: (name, lat, lng) {
              Navigator.pop(sheetContext);
              onOriginSelected(name, lat, lng);
            },
            authBloc: context.read<AuthBloc>(),
            title: title,
          ),
        ),
      ),
    );
  }
}

/// Contenido interno del sheet de selección de origen.
class _OriginSheetContent extends StatefulWidget {
  final ScrollController scrollController;
  final void Function(String name, double lat, double lng) onOriginSelected;
  final AuthBloc authBloc;
  final String title;

  const _OriginSheetContent({
    required this.scrollController,
    required this.onOriginSelected,
    required this.authBloc,
    required this.title,
  });

  @override
  State<_OriginSheetContent> createState() => _OriginSheetContentState();
}

class _OriginSheetContentState extends State<_OriginSheetContent> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<Spot> _spots = [];

  @override
  void initState() {
    super.initState();
    _loadSpots();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _loadSpots() {
    final authState = widget.authBloc.state;
    if (authState is AuthAuthenticated) {
      context.read<SpotBloc>().add(
            LoadUserSpotsEvent(userId: authState.user.uid),
          );
    }
  }

  /// Maneja selección de un resultado de búsqueda.
  void _onSearchResultSelected(PlaceSearchResult result) {
    final lat = result.latitude;
    final lng = result.longitude;

    if (lat != null && lng != null) {
      // Coords disponibles directamente en el resultado de búsqueda
      widget.onOriginSelected(result.description, lat, lng);
    } else {
      // Solicitar detalles para obtener coords
      context.read<PlaceBloc>().add(SelectPlaceEvent(result.placeId));
    }
  }

  /// Maneja selección desde el historial (placeId sin coords).
  void _onHistoryPlaceSelected(String placeId) {
    // SelectPlaceEvent y el unfocus ya son manejados internamente por HistoryList.
    // El BlocListener interceptará PlaceDetailsLoaded y disparará el callback.
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SpotBloc, SpotState>(
      listener: (context, state) {
        if (state is SpotsLoaded) {
          setState(() {
            _spots = state.spots;
          });
        }
      },
      child: BlocListener<PlaceBloc, PlacesState>(
        listener: (context, state) {
          // Cuando se obtienen los detalles del lugar (coords), llamar callback
          if (state is PlaceDetailsLoaded) {
            final place = state.placeDetails;
            widget.onOriginSelected(place.name, place.latitude, place.longitude);
          }
        },
        child: Container(
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
            controller: widget.scrollController,
            padding: EdgeInsets.zero,
            children: [
              const Center(child: Grabber()),

              // Título del sheet
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),

              // Barra de búsqueda personalizada
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: '¿Desde dónde partes?',
                    hintStyle:
                        const TextStyle(color: AppColor.neutralDarkNormal),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(
                      Icons.my_location,
                      color: AppColor.primaryNormal,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear,
                                color: AppColor.neutralDarkNormal),
                            onPressed: () {
                              _searchController.clear();
                              context
                                  .read<PlaceBloc>()
                                  .add(ClearSearchEvent());
                              setState(() {});
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                  onChanged: (value) {
                    setState(() {});
                    if (value.trim().isEmpty) {
                      context.read<PlaceBloc>().add(ClearSearchEvent());
                    } else {
                      context
                          .read<PlaceBloc>()
                          .add(SearchPlacesEvent(value.trim()));
                    }
                  },
                ),
              ),

              const SizedBox(height: 8),

              // Acceso rápido: Casa y Trabajo
              SpotQuickAccessBar(
                spots: _spots,
                onSpotTap: (spot) => widget.onOriginSelected(
                  spot.spotName,
                  spot.latitude,
                  spot.longitude,
                ),
                onAddTap: null,
              ),

              // Resultados de búsqueda / Historial
              BlocBuilder<PlaceBloc, PlacesState>(
                builder: (context, state) {
                  if (state is PlacesLoading || state is PlaceDetailsLoading) {
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColor.primaryNormal,
                        ),
                      ),
                    );
                  }

                  if (state is PlacesLoaded) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SearchResultsList(
                        results: state.suggestions,
                        onSuggestionSelected: _onSearchResultSelected,
                      ),
                    );
                  }

                  if (state is SearchHistoryLoaded || state is PlacesInitial) {
                    final List<PlaceSearchResult> history =
                        state is SearchHistoryLoaded ? state.history : [];

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: HistoryList(
                        history: history,
                        onPlaceSelected: _onHistoryPlaceSelected,
                      ),
                    );
                  }

                  if (state is PlacesError) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
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
        ),
      ),
    );
  }
}
