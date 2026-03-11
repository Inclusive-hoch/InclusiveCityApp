import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:inclusive_app/core/theme/app_color.dart';
import 'package:inclusive_app/features/spot/domain/entities/spot.dart';
import 'package:inclusive_app/features/spot/presentation/bloc/spot_bloc.dart';
import 'package:inclusive_app/features/spot/presentation/widgets/place_list_item_card.dart';
import 'package:inclusive_app/features/places/presentation/screen/place_details_page.dart';

/// Página que muestra el detalle de una lista personalizada.
/// 
/// Muestra todos los lugares guardados en la lista con opciones
/// para ver detalles o eliminar lugares de la lista.
class ListDetailPage extends StatefulWidget {
  final String listName;

  const ListDetailPage({
    super.key,
    required this.listName,
  });

  @override
  State<ListDetailPage> createState() => _ListDetailPageState();
}

class _ListDetailPageState extends State<ListDetailPage> {
  List<Spot> _spots = [];

  @override
  void initState() {
    super.initState();
    _loadListData();
  }

  void _loadListData() {
    // Cargar las listas para obtener los spots de esta lista
    context.read<SpotBloc>().add(const LoadCustomSpotsEvent());
  }

  void _onDeleteSpotFromList(Spot spot) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar lugar'),
        content: Text(
          '¿Eliminar "${spot.spotName}" de esta lista?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<SpotBloc>().add(
                    DeleteSpotFromListEvent(
                      listName: widget.listName,
                      latitude: spot.latitude,
                      longitude: spot.longitude,
                    ),
                  );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _onPlaceTap(
    Spot spot, {
    required List<String> photoReferences,
    required double rating,
    required List<String> medals,
  }) {
    final sheetController = DraggableScrollableController();

    sheetController.addListener(() {
      if (sheetController.isAttached && sheetController.size <= 0.31) {
        Navigator.pop(context);
      }
    });

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (innerContext) => DraggableScrollableSheet(
        controller: sheetController,
        initialChildSize: 0.9,
        minChildSize: 0.3,
        maxChildSize: 0.95,
        snap: true,
        snapSizes: const [0.3, 0.9],
        builder: (innerContext, scrollController) => PlaceDetailsPage(
          placeId: spot.placeId,
          placeName: spot.spotName,
          address: spot.address,
          photoReferences: photoReferences,
          rating: rating,
          medals: medals,
          latitude: spot.latitude,
          longitude: spot.longitude,
        ),
      ),
    ).whenComplete(sheetController.dispose);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.listName),
        backgroundColor: AppColor.primaryNormal,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<SpotBloc, SpotState>(
        listener: (context, state) {
          if (state is SpotDeletedFromList) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lugar eliminado (${state.deletedCount} registros)'),
                backgroundColor: Colors.green,
              ),
            );
            _loadListData();
          }

          if (state is CustomSpotsLoaded) {
            // Encontrar la lista actual y actualizar los spots
            try {
              final currentList = state.customSpots.firstWhere(
                (list) => list.listName == widget.listName,
              );
              setState(() {
                _spots = currentList.spotList;
              });
            } catch (e) {
              // Lista no encontrada
              // Verificar si es una lista predeterminada (no hacer pop)
              const predefinedLists = ['Destacados', 'Favoritos'];
              if (predefinedLists.contains(widget.listName)) {
                // Lista predeterminada vacía, mostrar estado vacío
                setState(() {
                  _spots = [];
                });
              } else {
                // Lista personalizada que fue eliminada, volver atrás
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Esta lista ya no existe'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  context.pop();
                }
              }
            }
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

          if (state is SpotError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 80,
                      color: Colors.red[300],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Error al cargar lugares',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _loadListData,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (_spots.isEmpty) {
            // Determinar el ícono según el tipo de lista
            IconData emptyIcon;
            Color iconColor = Colors.grey[300]!;
            
            if (widget.listName == 'Destacados') {
              emptyIcon = Icons.star_outline;
              iconColor = const Color(0xFFFFC107);
            } else if (widget.listName == 'Favoritos') {
              emptyIcon = Icons.favorite_border;
              iconColor = const Color(0xFFE91E63);
            } else {
              emptyIcon = Icons.location_off_outlined;
            }
            
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      emptyIcon,
                      size: 120,
                      color: iconColor,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'No tienes lugares guardados en esta lista',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Explora el mapa y guarda tus lugares favoritos.\nAparece aquí cada vez que los guardes en "${widget.listName}".',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.go('/map');
                      },
                      icon: const Icon(Icons.explore),
                      label: const Text('Explorar lugares'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primaryNormal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _spots.length,
            separatorBuilder: (context, index) => const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
            itemBuilder: (context, index) {
              final spot = _spots[index];
              return PlaceListItemCard(
                spot: spot,
                onTap: ({
                  required List<String> photoReferences,
                  required double rating,
                  required List<String> medals,
                }) => _onPlaceTap(
                  spot,
                  photoReferences: photoReferences,
                  rating: rating,
                  medals: medals,
                ),
                onDelete: () => _onDeleteSpotFromList(spot),
              );
            },
          );
        },
      ),
    );
  }
}
