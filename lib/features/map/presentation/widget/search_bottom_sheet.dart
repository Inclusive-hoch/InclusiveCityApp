import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:inclusivecity_frontend/constants/app_colors.dart';
import 'package:inclusivecity_frontend/core/auth/auth_service.dart';
import 'package:inclusivecity_frontend/features/map/domain/entities/place_suggestion.dart';
import 'package:inclusivecity_frontend/features/map/domain/entities/spot_entity.dart';
import 'package:inclusivecity_frontend/features/map/presentation/bloc/place_bloc.dart';
import 'package:inclusivecity_frontend/features/map/presentation/bloc/spots_bloc.dart';
import 'package:inclusivecity_frontend/features/map/presentation/widget/add_spot_dialog.dart';

/// Un widget deslizable (bottom sheet) que imita el comportamiento de búsqueda
/// de Waze o Google Maps.
///
/// Contiene el campo de búsqueda, atajos (Casa, Trabajo), y muestra
/// los resultados del BLoC o contenido por defecto (Recientes, Mis Listas).
class SearchBottomSheet extends StatefulWidget {
  final ValueNotifier<double>? sheetSizeNotifier;
  
  const SearchBottomSheet({super.key, this.sheetSizeNotifier});

  @override
  State<SearchBottomSheet> createState() => _SearchBottomSheetState();
}

class _SearchBottomSheetState extends State<SearchBottomSheet> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  final _sheetController = DraggableScrollableController();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  List<PlaceSuggestion> _history = [];
  List<SpotEntity> _savedSpots = [];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _focusNode.addListener(_onFocusChange);
    _sheetController.addListener(_onSheetSizeChange);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlacesBloc>().add(LoadSearchHistoryEvent());
      // Cargar spots guardados del usuario autenticado
      final userId = AuthService().requireUserId();
      context.read<SpotsBloc>().add(LoadUserSpotsEvent(userId));
    });
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _sheetController.animateTo(
        0.9, // Expande al 90% de la pantalla
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onSheetSizeChange() {
    widget.sheetSizeNotifier?.value = _sheetController.size;
    
    if (_sheetController.size < 0.3) {
      _focusNode.unfocus();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _sheetController.removeListener(_onSheetSizeChange);
    _sheetController.dispose();
    super.dispose();
  }

  Future<void> _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() => _isListening = false);
        }
      },
      onError: (error) {
        setState(() => _isListening = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error de reconocimiento de voz: ${error.errorMsg}'),
            backgroundColor: AppColors.error,
          ),
        );
      },
    );

    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
          setState(() {
            _searchController.text = result.recognizedWords;
          });
          // Disparar la búsqueda automáticamente
          if (result.finalResult) {
            context.read<PlacesBloc>().add(SearchPlacesEvent(_searchController.text));
          }
        },
        localeId: 'es_ES', // Español
        listenMode: stt.ListenMode.confirmation,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reconocimiento de voz no disponible. Verifica los permisos.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SpotsBloc, SpotsState>(
      listener: (context, state) {
        // Recargar spots cuando se guarde uno nuevo
        if (state is SpotSaved) {
          final userId = AuthService().requireUserId();
          context.read<SpotsBloc>().add(LoadUserSpotsEvent(userId));
        }
      },
      child: DraggableScrollableSheet(
        controller: _sheetController,
        initialChildSize: 0.15,
        minChildSize: 0.15,
        maxChildSize: 0.9,
        builder: (BuildContext context, ScrollController scrollController) {
        return BlocBuilder<PlacesBloc, PlacesState>(
          builder: (context, state) {
            if (state is SearchHistoryLoaded) {
              _history = state.history;
            }
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: ListView(
                controller: scrollController,
                padding: EdgeInsets.zero,
                children: [
                  _buildGrabber(),
                  
                  //Barra de búsqueda
                  _buildSearchTextField(state),
                  
                  _buildShortcutButtons(),
                  
                  if (state is PlacesLoading)
                    const SizedBox(
                      height: 4.0,
                      child: LinearProgressIndicator(
                        color: AppColors.primaryNormal,
                        backgroundColor: AppColors.neutralLight,
                      ),
                    ),

                  const Divider(height: 1, thickness: 1, color: AppColors.neutralLight),
                  _buildContent(state),
                ],
              ),
            );
          },
        );
        },
      ),
    );
  }

  /// Construye el widget que se muestra basado en el estado del BLoC
  Widget _buildContent(PlacesState state) {
    if (state is PlacesLoaded) {
      return _buildResultsList(state.suggestions);
    }
    if (state is PlacesEmpty) {
      return _buildInfoMessage(Icons.search_off, "No se encontraron resultados");
    }
    if (state is PlacesError) {
      return _buildInfoMessage(Icons.error_outline, state.message, isError: true);
    }
    if (state is SearchHistoryLoaded) {
      return _buildDefaultContent(state.history);
    }
    if (state is PlaceDetailsLoaded || state is PlacesInitial) {
      return _buildDefaultContent(_history);
    }
    return _buildDefaultContent(_history);
  }

  /// Barra gris para indicar que el sheet es deslizable
  Widget _buildGrabber() {
    return Container(
      width: 40.0,
      height: 5.0,
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      decoration: BoxDecoration(
        color: AppColors.neutralNormal,
        borderRadius: BorderRadius.circular(2.5),
      ),
    );
  }

  /// El campo de texto para la búsqueda
  Widget _buildSearchTextField(PlacesState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        controller: _searchController,
        focusNode: _focusNode,
        decoration: InputDecoration(
          hintText: "¿Adónde vas?",
          hintStyle: const TextStyle(color: AppColors.neutralDarkNormal),
          filled: true,
          fillColor: AppColors.neutralLight,
          prefixIcon: const Icon(Icons.search, color: AppColors.primaryNormal),
          suffixIcon: IconButton(
            icon: Icon(
              _isListening ? Icons.mic : Icons.mic_none,
              color: _isListening ? AppColors.error : AppColors.primaryNormal,
            ),
            onPressed: () {
              if (_isListening) {
                _stopListening();
              } else {
                _startListening();
              }
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
        ),
        onChanged: (query) {
          if (query.isEmpty) {
            // Si el campo está vacío, cargar historial
            context.read<PlacesBloc>().add(LoadSearchHistoryEvent());
          } else {
            // Dispara el evento de búsqueda
            context.read<PlacesBloc>().add(SearchPlacesEvent(query));
          }
        },
      ),
    );
  }

  /// Los botones de atajo en carrusel horizontal (Casa, Trabajo, otros spots, + Añadir)
  Widget _buildShortcutButtons() {
    return BlocBuilder<SpotsBloc, SpotsState>(
      builder: (context, spotsState) {
        // Actualizar spots guardados cuando se cargan
        if (spotsState is SpotsLoaded) {
          _savedSpots = spotsState.spots;
        }

        // Crear lista de todos los spots incluyendo predeterminados
        final List<Map<String, dynamic>> allSpots = [];

        // 1. Casa
        final homeSpot = _savedSpots.firstWhere(
          (spot) => spot.type?.toLowerCase() == 'casa',
          orElse: () => const SpotEntity(
            userId: '',
            spotName: '',
            placeId: '',
            address: '',
            latitude: 0,
            longitude: 0,
          ),
        );
        allSpots.add({
          'label': homeSpot.spotName.isEmpty ? 'Casa' : homeSpot.spotName,
          'icon': Icons.home,
          'isActive': homeSpot.placeId.isNotEmpty,
          'spot': homeSpot,
          'type': 'casa',
        });

        // 2. Trabajo
        final workSpot = _savedSpots.firstWhere(
          (spot) => spot.type?.toLowerCase() == 'trabajo',
          orElse: () => const SpotEntity(
            userId: '',
            spotName: '',
            placeId: '',
            address: '',
            latitude: 0,
            longitude: 0,
          ),
        );
        allSpots.add({
          'label': workSpot.spotName.isEmpty ? 'Trabajo' : workSpot.spotName,
          'icon': Icons.work,
          'isActive': workSpot.placeId.isNotEmpty,
          'spot': workSpot,
          'type': 'trabajo',
        });

        // 3. Otros spots (no Casa ni Trabajo)
        final otherSpots = _savedSpots.where(
          (spot) => spot.type?.toLowerCase() != 'casa' && 
                    spot.type?.toLowerCase() != 'trabajo',
        ).toList();

        for (var spot in otherSpots) {
          allSpots.add({
            'label': spot.spotName,
            'icon': _getSpotIcon(spot.type),
            'isActive': true,
            'spot': spot,
            'type': 'other',
          });
        }

        return SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            itemCount: allSpots.length + 1, // +1 para el botón añadir
            itemBuilder: (context, index) {
              // Último elemento es el botón añadir
              if (index == allSpots.length) {
                return Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: _buildChipButton(
                    label: "Añadir",
                    icon: Icons.add,
                    isActive: true,
                    onPressed: () => _showAddSpotDialog(context),
                  ),
                );
              }

              final spotData = allSpots[index];
              final spot = spotData['spot'] as SpotEntity;
              final type = spotData['type'] as String;

              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: _buildChipButton(
                  label: spotData['label'] as String,
                  icon: spotData['icon'] as IconData,
                  isActive: spotData['isActive'] as bool,
                  onPressed: () => _handleSpotPress(context, spot, type),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _handleSpotPress(BuildContext context, SpotEntity spot, String type) {
    if (spot.placeId.isEmpty) {
      // No existe spot guardado - mostrar opciones para crear
      _showCreateSpotDialog(context, type);
    } else {
      // Existe spot - navegar y mostrar detalles
      context.read<PlacesBloc>().add(SelectPlaceEvent(spot.placeId));
    }
  }

  void _showCreateSpotDialog(BuildContext context, String type) {
    final typeName = type == 'casa' ? 'Casa' : 'Trabajo';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Agregar $typeName'),
        content: Text(
          'Aún no has guardado tu $typeName.\n\n'
          'Busca un lugar en el mapa y guárdalo como "$typeName" '
          'usando el botón de bookmark en los detalles del lugar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _showAddSpotDialog(BuildContext context) {
    // Limpiar el estado del BLoC antes de abrir el diálogo
    context.read<PlacesBloc>().add(LoadSearchHistoryEvent());
    
    showDialog(
      context: context,
      builder: (dialogContext) => AddSpotDialog(
        spotsBloc: context.read<SpotsBloc>(),
        placesBloc: context.read<PlacesBloc>(),
      ),
    );
  }

  /// Un botón de atajo individual
  Widget _buildChipButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required bool isActive,
  }) {
    return ElevatedButton.icon(
      icon: Icon(
        icon,
        color: isActive ? AppColors.primaryNormal : Colors.grey,
        size: 20,
      ),
      label: Text(
        label,
        style: TextStyle(
          color: isActive ? AppColors.neutralDarkDarker : Colors.grey[600],
          fontWeight: FontWeight.w600,
        ),
      ),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? AppColors.neutralLight : Colors.grey[200],
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
    );
  }

  IconData _getSpotIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'escuela':
        return Icons.school;
      case 'gimnasio':
        return Icons.fitness_center;
      case 'casa':
        return Icons.home;
      case 'trabajo':
        return Icons.work;
      default:
        return Icons.place;
    }
  }

  /// Muestra el contenido por defecto (Recientes, Mis Listas)
  Widget _buildDefaultContent(List<PlaceSuggestion> history) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        // --- Sección Recientes ---
        Text(
          "Recientes",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.neutralDarkDarker,
          ),
        ),
        const SizedBox(height: 10),
        if (history.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              "No hay búsquedas recientes",
              style: TextStyle(
                color: AppColors.neutralDarkNormal,
                fontStyle: FontStyle.italic,
              ),
            ),
          )
        else
          ...history.map((place) {
            return _buildListTile(
              icon: Icons.history,
              title: place.description,
              subtitle: place.address,
              onTap: () {
                context.read<PlacesBloc>().add(SelectPlaceEvent(place.placeId));
                _focusNode.unfocus();
                _sheetController.animateTo(
                  0.15,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            );
          }).toList(),
        const Divider(height: 32),

        // --- Sección Mis Listas ---
        Text(
          "Mis listas",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.neutralDarkDarker,
          ),
        ),
        const SizedBox(height: 10),
        _buildListTile(
          icon: Icons.star,
          title: "Destacados",
          subtitle: "2 lugares",
          iconColor: AppColors.yellowNormal,
          onTap: () {
            // TODO: Implementar navegación a la vista "Destacados"
          },
        ),
        _buildListTile(
          icon: Icons.favorite,
          title: "Favoritos",
          subtitle: "1 lugares",
          iconColor: AppColors.accentNormal,
          onTap: () {
            // TODO: Implementar navegación a la vista "Favoritos"
          },
        ),
        _buildListTile(
          icon: Icons.add,
          title: "Agregar lista",
          onTap: () {
            // TODO: Implementar lógica para crear una nueva lista
          },
        ),
      ],
    ),
    );
  }

  /// Muestra la lista de resultados de búsqueda
  Widget _buildResultsList(List<PlaceSuggestion> suggestions) {
    return Column(
      children: List.generate(suggestions.length, (index) {
        final suggestion = suggestions[index];
        
        return _buildListTile(
          icon: Icons.location_on,
          title: suggestion.description,
          subtitle: suggestion.address,
          onTap: () {
            // Guardar en historial
            context.read<PlacesBloc>().add(SaveToHistoryEvent(suggestion));
            
            // Disparar evento para obtener detalles del lugar y mover el mapa
            context.read<PlacesBloc>().add(SelectPlaceEvent(suggestion.placeId));
            
            // Limpiar campo de búsqueda
            _searchController.clear();
            
            // Cargar historial para la próxima vez
            context.read<PlacesBloc>().add(LoadSearchHistoryEvent());
            
            _focusNode.unfocus(); // Ocultar teclado
            _sheetController.animateTo(
              0.15,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
        );
      }),
    );
  }

  /// Un widget reutilizable para las filas de la lista
  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppColors.neutralDarkNormal),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.neutralDarkDarker,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle, style: const TextStyle(color: AppColors.neutralDarkNormal))
          : null,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
    );
  }

  /// Muestra un mensaje de "No hay resultados" o "Error"
  Widget _buildInfoMessage(IconData icon, String message, {bool isError = false}) {
    final color = isError ? AppColors.error : AppColors.neutralDarkNormal;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}