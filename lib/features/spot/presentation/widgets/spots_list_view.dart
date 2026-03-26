import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inclusive_app/core/theme/app_color.dart';
import 'package:inclusive_app/features/spot/domain/entities/spot.dart';
import 'package:inclusive_app/features/spot/presentation/bloc/spot_bloc.dart';
import 'package:inclusive_app/features/spot/presentation/widgets/add_place_button.dart';
import 'package:inclusive_app/features/spot/presentation/widgets/empty_saved_places.dart';
import 'package:inclusive_app/features/spot/presentation/widgets/saved_place_list_tile.dart';

/// Widget que muestra la lista de spots guardados con sus diferentes estados.
class SpotsListView extends StatelessWidget {
  final VoidCallback onAddPlace;
  final Function(String) onPlaceTap;
  final Function(double, double) onDelete;
  final VoidCallback onRefresh;

  const SpotsListView({
    super.key,
    required this.onAddPlace,
    required this.onPlaceTap,
    required this.onDelete,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SpotBloc, SpotState>(
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
            return EmptySavedPlaces(onAddPlace: onAddPlace);
          }

          return _buildSpotsList(spots);
        }

        if (state is SpotError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: onRefresh,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }

        // Estado inicial
        return EmptySavedPlaces(onAddPlace: onAddPlace);
      },
    );
  }

  /// Construye la lista de spots con RefreshIndicator.
  Widget _buildSpotsList(List<Spot> spots) {
    return RefreshIndicator(
      color: AppColor.primaryNormal,
      onRefresh: () async {
        onRefresh();
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: spots.length + 1, // +1 para el botón de agregar
        itemBuilder: (context, index) {
          // Primer item: Botón de agregar
          if (index == 0) {
            return AddPlaceButton(onPressed: onAddPlace);
          }

          // Items de spots
          final spot = spots[index - 1];
          return SavedPlaceListTile(
            spot: spot,
            showAddress: false,
            onTap: () => onPlaceTap(spot.placeId),
            onDelete: () => onDelete(spot.latitude, spot.longitude),
          );
        },
      ),
    );
  }
}
