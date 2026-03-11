import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:inclusive_app/core/theme/app_color.dart';
import 'package:inclusive_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:inclusive_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:inclusive_app/features/places/domain/entities/place_search_result.dart';
import 'package:inclusive_app/features/places/presentation/bloc/place_bloc.dart';
import 'package:inclusive_app/features/places/presentation/widget/history_list.dart';
import 'package:inclusive_app/features/places/presentation/widget/search_bar.dart' as custom;
import 'package:inclusive_app/features/places/presentation/widget/search_result_list.dart';
import 'package:inclusive_app/features/spot/domain/entities/custom_spot.dart';
import 'package:inclusive_app/features/spot/domain/entities/spot.dart';
import 'package:inclusive_app/features/spot/presentation/bloc/spot_bloc.dart';
import 'package:inclusive_app/features/spot/presentation/pages/saved_spots_page.dart';
import 'package:inclusive_app/features/spot/presentation/widgets/custom_lists_section.dart';
import 'package:inclusive_app/features/spot/presentation/widgets/spot_quick_access_bar.dart';
import 'package:inclusive_app/shared/widgets/grabber.dart';
import 'package:inclusive_app/features/map_view/presentation/bloc/map_bloc.dart' as map_bloc;

/// Página de búsqueda de lugares con panel deslizable.
/// 
/// Muestra una interfaz de búsqueda que reacciona a diferentes estados:
/// - Historial de búsquedas cuando no hay búsqueda activa
/// - Resultados de búsqueda en tiempo real
/// - Estados de carga y error
/// 
/// Diseñada para usarse dentro de un [DraggableScrollableSheet].
class SearchPage extends StatefulWidget {
  /// Controlador para conectar el scroll de la lista con el panel deslizable.
  final ScrollController scrollController;

  const SearchPage({
    super.key,
    required this.scrollController,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // Lista de todos los spots del usuario
  List<Spot> userSpots = [];
  
  // Lista de custom spots (listas personalizadas) del usuario
  List<CustomSpot> customSpots = [];

  // Historial de búsquedas
  List<PlaceSearchResult> _searchHistory = [];

  // FocusNode para la lista de historial
  final FocusNode _historyFocusNode = FocusNode();

  @override
  void dispose() {
    _historyFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Cargar spots del usuario si está disponible
    _loadUserSpots();
    // Cargar custom spots (listas personalizadas)
    _loadCustomSpots();
    // Cargar historial de búsquedas
    context.read<PlaceBloc>().add(LoadSearchHistoryEvent());
  }

  /// Carga los spots del usuario.
  void _loadUserSpots() {
    // Obtener el userId del usuario autenticado
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final userId = authState.user.uid;
      context.read<SpotBloc>().add(LoadUserSpotsEvent(userId: userId));
    }
  }

  /// Carga las listas personalizadas del usuario.
  void _loadCustomSpots() {
    context.read<SpotBloc>().add(LoadCustomSpotsEvent());
  }

  /// Maneja el tap en una píldora de spot - genera ruta automáticamente.
  void _onSpotTap(Spot spot) async {
    // Obtener el MapBloc para verificar ubicación
    final mapBloc = context.read<map_bloc.MapBloc>();
    final mapState = mapBloc.state;

    // Si ya tenemos la ubicación, navegar directamente
    if (mapState is map_bloc.MapLocationLoaded) {
      _navigateToRoute(
        context,
        mapState.latitude,
        mapState.longitude,
        spot,
      );
      return;
    }

    // Si no tenemos ubicación, intentar obtenerla
    // Mostrar indicador de carga
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: AppColor.primaryNormal,
        ),
      ),
    );

    // Disparar el evento para obtener la ubicación
    mapBloc.add(map_bloc.GetUserLocationEvent());

    // Esperar el resultado con timeout para evitar espera indefinida
    try {
      final resultState = await mapBloc.stream
          .firstWhere(
            (s) => s is map_bloc.MapLocationLoaded || s is map_bloc.MapError,
          )
          .timeout(const Duration(seconds: 15));

      if (!mounted) return;
      Navigator.of(context).pop(); // Cerrar diálogo de carga

      if (resultState is map_bloc.MapLocationLoaded) {
        _navigateToRoute(context, resultState.latitude, resultState.longitude, spot);
      } else if (resultState is map_bloc.MapError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resultState.message),
            duration: const Duration(seconds: 4),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Configuración',
              textColor: Colors.white,
              onPressed: () => Geolocator.openLocationSettings(),
            ),
          ),
        );
      }
    } on TimeoutException {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo obtener la ubicación. Verifica tu GPS.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Maneja el tap en la píldora Casa cuando no está asignada.
  void _onAddHomeTap() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final userId = authState.user.uid;
      
      // Navegar a la página de lugares guardados para agregar Casa
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SavedPlacesPage(
            userId: userId,
            initialSpotType: 'casa',
            initialSpotName: 'Casa',
          ),
        ),
      );
    }
  }

  /// Maneja el tap en la píldora Trabajo cuando no está asignada.
  void _onAddWorkTap() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final userId = authState.user.uid;
      
      // Navegar a la página de lugares guardados para agregar Trabajo
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SavedPlacesPage(
            userId: userId,
            initialSpotType: 'trabajo',
            initialSpotName: 'Trabajo',
          ),
        ),
      );
    }
  }

  /// Maneja el tap en la píldora Añadir.
  void _onAddTap() {
    // Obtener el userId del usuario autenticado
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final userId = authState.user.uid;
      
      // Navegar a la página de lugares guardados
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SavedPlacesPage(userId: userId),
        ),
      );
    }
  }

  /// Maneja el tap en "Agregar lista".
  void _onAddListTap() {
    // Mostrar mensaje informativo: no se pueden crear listas vacías
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Crear nueva lista'),
        content: const Text(
          'Para crear una lista personalizada, primero busca un lugar que te guste '
          'y guárdalo. Cuando presiones el ícono de guardar, podrás crear una nueva lista '
          'con ese lugar.\n\n'
          'Las listas predeterminadas "Destacados" y "Favoritos" ya están disponibles.',
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

  /// Navega a la pantalla de selección de ruta.
  void _navigateToRoute(
    BuildContext context,
    double userLat,
    double userLng,
    Spot spot,
  ) {
    // Navegar a la pantalla de selección de ruta
    context.push(
      '/route-selection',
      extra: {
        'originLat': userLat,
        'originLng': userLng,
        'destLat': spot.latitude,
        'destLng': spot.longitude,
        'originName': 'Mi ubicación',
        'destName': spot.spotName,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PlaceBloc, PlacesState>(
      listener: (context, placeState) {
        if (placeState is SearchHistoryLoaded) {
          setState(() {
            _searchHistory = placeState.history;
          });
        }
        if (placeState is PlaceDetailsLoaded || placeState is PlaceDetailsLoading) {
          FocusScope.of(context).unfocus();
        }
      },
      child: BlocListener<SpotBloc, SpotState>(
      listener: (context, state) {
        // Actualizar lista de spots
        if (state is SpotsLoaded) {
          setState(() {
            userSpots = state.spots;
          });
        }
        
        // Actualizar lista de custom spots
        if (state is CustomSpotsLoaded) {
          setState(() {
            customSpots = state.customSpots;
          });
        }
        
        // Mostrar mensaje de éxito al crear lista
        if (state is CustomSpotCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lista "${state.customSpot.listName}" creada'),
              backgroundColor: AppColor.success,
              duration: const Duration(seconds: 2),
            ),
          );
          // Recargar custom spots
          _loadCustomSpots();
        }
        
        // Mostrar error si falla
        if (state is SpotError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColor.error,
              duration: const Duration(seconds: 3),
            ),
          );
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

            const custom.SearchBar(),
            const SizedBox(height: 16),

            // Barra de acceso rápido a spots guardados
            SpotQuickAccessBar(
              spots: userSpots,
              onSpotTap: _onSpotTap,
              onAddHomeTap: _onAddHomeTap,
              onAddWorkTap: _onAddWorkTap,
              onAddTap: _onAddTap,
            ),

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

              if (state is PlacesLoaded && state.suggestions.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SearchResultsList(
                    results: state.suggestions,
                    onSuggestionSelected: (place) {
                      FocusScope.of(context).unfocus();
                      context.read<PlaceBloc>().add(SelectPlaceEvent(place.placeId));
                    },
                  ),
                );
              }
              
              // Mostrar contenido base cuando no hay búsqueda activa o no hay resultados
              if (state is SearchHistoryLoaded || 
                  state is PlacesInitial || 
                  state is PlacesEmpty ||
                  state is PlaceDetailsLoaded ||
                  state is PlaceDetailsLoading ||
                  (state is PlacesLoaded && state.suggestions.isEmpty)) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Historial de búsquedas
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: HistoryList(
                        history: _searchHistory,
                        focusNode: _historyFocusNode,
                        onPlaceSelected: (placeId) {
                          FocusScope.of(context).unfocus();
                          context.read<PlaceBloc>().add(SelectPlaceEvent(placeId));
                        },
                      ),
                    ),
                    
                    // Sección de Mis listas (siempre visible cuando no hay búsqueda)
                    CustomListsSection(
                      customSpots: customSpots,
                      onAddListTap: _onAddListTap,
                    ),
                  ],
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
      ),
      ),
    );
  }
}