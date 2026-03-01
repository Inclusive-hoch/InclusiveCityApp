import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:inclusive_app/core/theme/app_color.dart';
import 'package:inclusive_app/features/spot/domain/entities/spot.dart';
import 'package:inclusive_app/features/spot/presentation/bloc/spot_bloc.dart';
import 'package:inclusive_app/features/spot/presentation/widgets/place_list_item_card.dart';
import 'package:inclusive_app/features/places/presentation/screen/place_details_page.dart';
import 'package:inclusive_app/shared/widgets/grabber.dart';

/// Bottom sheet modal que muestra el detalle de una lista personalizada.
/// 
/// Diseño tipo panel deslizable con encabezado personalizado según el tipo de lista.
class ListDetailBottomSheet extends StatefulWidget {
  final String listName;

  const ListDetailBottomSheet({
    super.key,
    required this.listName,
  });

  @override
  State<ListDetailBottomSheet> createState() => _ListDetailBottomSheetState();

  /// Muestra el bottom sheet de forma modal
  static void show(BuildContext context, String listName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ListDetailBottomSheet(listName: listName),
    );
  }
}

class _ListDetailBottomSheetState extends State<ListDetailBottomSheet> {
  List<Spot> _spots = [];

  @override
  void initState() {
    super.initState();
    _loadListData();
  }

  void _loadListData() {
    context.read<SpotBloc>().add(const LoadCustomSpotsEvent());
  }

  void _onDeleteSpotFromList(Spot spot) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        controller: sheetController,
        initialChildSize: 0.9,
        minChildSize: 0.3,
        maxChildSize: 0.95,
        snap: true,
        snapSizes: const [0.3, 0.9],
        builder: (context, scrollController) {
          sheetController.addListener(() {
            if (sheetController.size <= 0.31) {
              Navigator.pop(context);
            }
          });

          return PlaceDetailsPage(
            placeId: spot.placeId,
            placeName: spot.spotName,
            address: spot.address,
            photoReferences: photoReferences,
            rating: rating,
            medals: medals,
            latitude: spot.latitude,
            longitude: spot.longitude,
          );
        },
      ),
    );
  }

  void _onShare() {
    if (_spots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay lugares para compartir'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final String shareText = '''📍 Lista: ${widget.listName}

${_spots.map((spot) => '• ${spot.spotName}\n  ${spot.address}').join('\n\n')}

Compartido desde Inclusive City App 🌍''';

    // Copiar al portapapeles
    Clipboard.setData(ClipboardData(text: shareText));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text('Lista copiada al portapapeles'),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Obtener ícono y color según el tipo de lista
  Map<String, dynamic> _getListStyle() {
    if (widget.listName == 'Destacados') {
      return {
        'icon': Icons.star,
        'color': const Color(0xFFFFC107),
      };
    } else if (widget.listName == 'Favoritos') {
      return {
        'icon': Icons.favorite,
        'color': const Color(0xFFE91E63),
      };
    } else {
      return {
        'icon': Icons.bookmark,
        'color': AppColor.primaryNormal,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final listStyle = _getListStyle();
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Grabber deslizable
          const Grabber(),

          // Encabezado personalizado
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                // Ícono de la lista
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: listStyle['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    listStyle['icon'],
                    color: listStyle['color'],
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),

                // Nombre de la lista
                Expanded(
                  child: Text(
                    widget.listName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Botón de compartir
                IconButton(
                  onPressed: _onShare,
                  icon: const Icon(Icons.share_outlined),
                  color: AppColor.primaryNormal,
                  tooltip: 'Compartir lista',
                ),

                // Botón de cerrar
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  color: Colors.grey[700],
                  tooltip: 'Cerrar',
                ),
              ],
            ),
          ),

          // Contenido de la lista
          Expanded(
            child: BlocConsumer<SpotBloc, SpotState>(
              listener: (context, state) {
                if (state is SpotDeletedFromList) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lugar eliminado (${state.deletedCount} registros)'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
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
                    const predefinedLists = ['Destacados', 'Favoritos'];
                    if (predefinedLists.contains(widget.listName)) {
                      setState(() {
                        _spots = [];
                      });
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Esta lista ya no existe'),
                            backgroundColor: Colors.orange,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        Navigator.of(context).pop();
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

                if (_spots.isEmpty) {
                  return _buildEmptyState();
                }

                if (state is SpotError) {
                  return _buildErrorState(state.message);
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _spots.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
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
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final listStyle = _getListStyle();
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              listStyle['icon'],
              size: 100,
              color: listStyle['color'].withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            const Text(
              'No tienes lugares guardados',
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
                Navigator.of(context).pop();
                context.go('/map');
              },
              icon: const Icon(Icons.explore),
              label: const Text('Explorar lugares'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primaryNormal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
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
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadListData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primaryNormal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
