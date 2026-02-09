import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inclusive_app/core/theme/app_color.dart';
import 'package:inclusive_app/features/places/domain/entities/place_search_result.dart';
import 'package:inclusive_app/features/places/presentation/bloc/place_bloc.dart';
import 'package:inclusive_app/features/spot/domain/entities/spot.dart';
import 'package:inclusive_app/features/spot/presentation/bloc/spot_bloc.dart';
import 'package:inclusive_app/features/spot/presentation/widgets/add_place_app_bar.dart';
import 'package:inclusive_app/features/spot/presentation/widgets/place_name_dialog.dart';
import 'package:inclusive_app/features/spot/presentation/widgets/recent_place_item.dart';

/// Página para agregar un nuevo lugar guardado.
/// 
/// Permite:
/// - Buscar lugares con texto o voz
/// - Seleccionar de lugares recientes
/// - Asignar nombre personalizado
/// - Guardar como spot del usuario
class AddPlacePage extends StatefulWidget {
  /// ID del usuario para guardar el spot.
  final String userId;

  const AddPlacePage({
    super.key,
    required this.userId,
  });

  @override
  State<AddPlacePage> createState() => _AddPlacePageState();
}

class _AddPlacePageState extends State<AddPlacePage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Cargar historial al iniciar
    context.read<PlaceBloc>().add(LoadSearchHistoryEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  /// Maneja la búsqueda de lugares.
  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      context.read<PlaceBloc>().add(LoadSearchHistoryEvent());
    } else {
      context.read<PlaceBloc>().add(SearchPlacesEvent(query));
    }
  }

  /// Maneja la selección de un lugar.
  void _onPlaceSelected(PlaceSearchResult place) {
    // Quitar foco del campo de búsqueda
    _searchFocusNode.unfocus();

    // Mostrar diálogo para ingresar nombre
    showDialog(
      context: context,
      builder: (dialogContext) => PlaceNameDialog(
        initialName: place.description,
        onConfirm: (name) {
          _saveSpot(place, name);
        },
      ),
    );
  }

  /// Guarda el lugar como spot del usuario.
  void _saveSpot(PlaceSearchResult place, String name) {
    final spot = Spot(
      userId: widget.userId,
      spotName: name,
      placeId: place.placeId,
      address: place.address ?? place.description,
      latitude: place.latitude ?? 0.0,
      longitude: place.longitude ?? 0.0,
      type: _detectPlaceType(name),
    );

    // Guardar en historial
    context.read<PlaceBloc>().add(SaveToHistoryEvent(place));

    // Crear spot
    context.read<SpotBloc>().add(CreateSpotEvent(spot: spot));
  }

  /// Detecta el tipo de lugar según el nombre.
  String? _detectPlaceType(String name) {
    final nameLower = name.toLowerCase();
    if (nameLower.contains('casa') || nameLower.contains('home')) {
      return 'home';
    }
    if (nameLower.contains('trabajo') || nameLower.contains('work') || 
        nameLower.contains('oficina')) {
      return 'work';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SpotBloc, SpotState>(
      listener: (context, state) {
        if (state is SpotCreated) {
          // Mostrar mensaje de éxito
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lugar guardado exitosamente'),
              backgroundColor: AppColor.greenNormal,
              duration: Duration(seconds: 2),
            ),
          );

          // Volver a la página anterior
          Navigator.of(context).pop(true); // true indica que se guardó un lugar
        }

        if (state is SpotError) {
          // Mostrar mensaje de error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColor.accentNormal,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: const AddPlaceAppBar(),
        body: Column(
          children: [
            // Campo de búsqueda
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Buscar dirección',
                  hintStyle: const TextStyle(
                    color: AppColor.neutralDarkNormal,
                  ),
                  filled: true,
                  fillColor: AppColor.neutralLight,
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColor.secondaryNormal,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.mic_none,
                      color: AppColor.primaryNormal,
                    ),
                    onPressed: () {
                      // TODO: Implementar reconocimiento de voz
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Función de voz en desarrollo'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // Resultados de búsqueda / Historial
            Expanded(
              child: BlocBuilder<PlaceBloc, PlacesState>(
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
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'No se encontraron resultados',
                            style: TextStyle(
                              color: AppColor.secondaryNormal,
                            ),
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: suggestions.length,
                      itemBuilder: (context, index) {
                        final place = suggestions[index];
                        return RecentPlaceItem(
                          title: place.description,
                          subtitle: place.address,
                          onTap: () => _onPlaceSelected(place),
                        );
                      },
                    );
                  }

                  if (state is SearchHistoryLoaded) {
                    final history = state.history;

                    if (history.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search,
                                size: 64,
                                color: AppColor.neutralDarkNormal,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Busca un lugar para guardar',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColor.secondaryNormal,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final place = history[index];
                        return RecentPlaceItem(
                          title: place.description,
                          subtitle: place.address,
                          onTap: () => _onPlaceSelected(place),
                        );
                      },
                    );
                  }

                  if (state is PlacesError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          state.message,
                          style: const TextStyle(
                            color: AppColor.accentNormal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  // Estado inicial
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search,
                            size: 64,
                            color: AppColor.neutralDarkNormal,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Busca un lugar para guardar',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColor.secondaryNormal,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
