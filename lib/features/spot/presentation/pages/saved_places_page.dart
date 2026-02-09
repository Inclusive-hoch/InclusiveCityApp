import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inclusive_app/core/theme/app_color.dart';
import 'package:inclusive_app/features/spot/presentation/bloc/spot_bloc.dart';
import 'package:inclusive_app/features/spot/presentation/pages/add_place_page.dart';
import 'package:inclusive_app/features/spot/presentation/widgets/add_place_button.dart';
import 'package:inclusive_app/features/spot/presentation/widgets/empty_saved_places.dart';
import 'package:inclusive_app/features/spot/presentation/widgets/saved_place_list_tile.dart';
import 'package:inclusive_app/features/spot/presentation/widgets/saved_places_app_bar.dart';

/// Página principal para mostrar los lugares guardados del usuario.
/// 
/// Muestra una lista de todos los spots guardados del usuario,
/// permitiendo:
/// - Ver lista de lugares guardados
/// - Eliminar lugares (swipe to delete)
/// - Agregar nuevos lugares
/// - Navegar a detalles de cada lugar
class SavedPlacesPage extends StatefulWidget {
  /// ID del usuario para cargar sus spots.
  final String userId;

  const SavedPlacesPage({
    super.key,
    required this.userId,
  });

  @override
  State<SavedPlacesPage> createState() => _SavedPlacesPageState();
}

class _SavedPlacesPageState extends State<SavedPlacesPage> {
  @override
  void initState() {
    super.initState();
    _loadUserSpots();
  }

  /// Carga los spots del usuario.
  void _loadUserSpots() {
    context.read<SpotBloc>().add(
          LoadUserSpotsEvent(userId: widget.userId),
        );
  }

  /// Maneja la eliminación de un spot.
  void _deleteSpot(double latitude, double longitude) {
    context.read<SpotBloc>().add(
          DeleteSpotEvent(
            latitude: latitude,
            longitude: longitude,
          ),
        );

    // Mostrar mensaje de confirmación
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Lugar eliminado'),
        duration: Duration(seconds: 2),
        backgroundColor: AppColor.greenNormal,
      ),
    );

    // Recargar la lista después de eliminar
    Future.delayed(const Duration(milliseconds: 500), () {
      _loadUserSpots();
    });
  }

  /// Maneja el tap en un lugar guardado.
  void _onPlaceTap(BuildContext context, String placeId) {
    // TODO: Navegar a detalles del lugar
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => PlaceDetailsPage(placeId: placeId),
    //   ),
    // );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ver detalles de: $placeId'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  /// Maneja el botón de agregar lugar.
  void _onAddPlace(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPlacePage(userId: widget.userId),
      ),
    );

    // Si se guardó un lugar exitosamente, recargar la lista
    if (result == true) {
      _loadUserSpots();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const SavedPlacesAppBar(),
      body: BlocConsumer<SpotBloc, SpotState>(
        listener: (context, state) {
          if (state is SpotError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColor.accentNormal,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is SpotLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColor.primaryNormal,
              ),
            );
          }

          if (state is SpotsLoaded) {
            final spots = state.spots;

            if (spots.isEmpty) {
              return EmptySavedPlaces(
                onAddPlace: () => _onAddPlace(context),
              );
            }

            return RefreshIndicator(
              color: AppColor.primaryNormal,
              onRefresh: () async {
                _loadUserSpots();
                // Esperar un poco para que se vea la animación
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: spots.length + 1, // +1 para el botón de agregar
                itemBuilder: (context, index) {
                  // Primer item: Botón de agregar
                  if (index == 0) {
                    return AddPlaceButton(
                      onPressed: () => _onAddPlace(context),
                    );
                  }

                  // Items de spots
                  final spot = spots[index - 1];
                  return SavedPlaceListTile(
                    spot: spot,
                    showAddress: false,
                    onTap: () => _onPlaceTap(context, spot.placeId),
                    onDelete: () => _deleteSpot(
                      spot.latitude,
                      spot.longitude,
                    ),
                  );
                },
              ),
            );
          }

          // Estado inicial o error
          return EmptySavedPlaces(
            onAddPlace: () => _onAddPlace(context),
          );
        },
      ),
    );
  }
}
