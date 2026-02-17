import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inclusive_app/core/theme/app_color.dart';
import 'package:inclusive_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:inclusive_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:inclusive_app/features/places/domain/entities/place_search_result.dart';
import 'package:inclusive_app/features/places/presentation/bloc/place_bloc.dart';
import 'package:inclusive_app/features/places/presentation/widget/history_list.dart';
import 'package:inclusive_app/features/places/presentation/widget/search_bar.dart' as custom;
import 'package:inclusive_app/features/places/presentation/widget/search_result_list.dart';
import 'package:inclusive_app/features/spot/domain/entities/spot.dart';
import 'package:inclusive_app/features/spot/presentation/bloc/spot_bloc.dart';
import 'package:inclusive_app/features/spot/presentation/pages/add_place_page.dart';
import 'package:inclusive_app/features/spot/presentation/widgets/spot_quick_access_bar.dart';
import 'package:inclusive_app/shared/widgets/grabber.dart';

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
  // Referencias a spots de Casa y Trabajo
  Spot? homeSpot;
  Spot? workSpot;

  @override
  void initState() {
    super.initState();
    // Cargar spots del usuario si está disponible
    _loadUserSpots();
  }

  /// Carga los spots del usuario para detectar Casa y Trabajo.
  void _loadUserSpots() {
    // Obtener el userId del usuario autenticado
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final userId = authState.user.uid;
      context.read<SpotBloc>().add(LoadUserSpotsEvent(userId: userId));
    }
  }

  /// Maneja el tap en la píldora Casa.
  void _onHomeTap() {
    if (homeSpot != null) {
      // Seleccionar el lugar de casa
      context.read<PlaceBloc>().add(SelectPlaceEvent(homeSpot!.placeId));
    }
  }

  /// Maneja el tap en la píldora Trabajo.
  void _onWorkTap() {
    if (workSpot != null) {
      // Seleccionar el lugar de trabajo
      context.read<PlaceBloc>().add(SelectPlaceEvent(workSpot!.placeId));
    }
  }

  /// Maneja el tap en la píldora Añadir.
  void _onAddTap() {
    // Obtener el userId del usuario autenticado
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final userId = authState.user.uid;
      
      // Navegar a la página de agregar lugar
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddPlacePage(userId: userId),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SpotBloc, SpotState>(
      listener: (context, state) {
        // Actualizar referencias de Casa y Trabajo
        if (state is SpotsLoaded) {
          setState(() {
            try {
              homeSpot = state.spots.firstWhere(
                (spot) => spot.type?.toLowerCase() == 'home' || 
                         spot.type?.toLowerCase() == 'casa',
              );
            } catch (e) {
              homeSpot = null;
            }
            
            try {
              workSpot = state.spots.firstWhere(
                (spot) => spot.type?.toLowerCase() == 'work' || 
                         spot.type?.toLowerCase() == 'trabajo',
              );
            } catch (e) {
              workSpot = null;
            }
          });
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

            // Barra de acceso rápido (Casa, Trabajo, Añadir)
            SpotQuickAccessBar(
              onHomeTap: _onHomeTap,
              onWorkTap: _onWorkTap,
              onAddTap: _onAddTap,
              hasHome: homeSpot != null,
              hasWork: workSpot != null,
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
      ),
    );
  }
}