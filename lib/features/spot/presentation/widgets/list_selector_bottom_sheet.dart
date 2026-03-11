import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inclusive_app/core/theme/app_color.dart';
import 'package:inclusive_app/core/auth/firebase_auth_service.dart';
import 'package:inclusive_app/features/spot/domain/entities/custom_spot.dart';
import 'package:inclusive_app/features/spot/domain/entities/spot.dart';
import 'package:inclusive_app/features/spot/data/models/spot_model.dart';
import 'package:inclusive_app/features/spot/presentation/bloc/spot_bloc.dart';
import 'package:inclusive_app/features/spot/presentation/widgets/create_list_dialog.dart';
import 'package:inclusive_app/injection_container.dart' as di;

/// Bottom sheet para seleccionar o crear una lista personalizada.
/// 
/// Permite al usuario:
/// - Seleccionar una lista existente para agregar un lugar
/// - Crear una nueva lista personalizada
class ListSelectorBottomSheet extends StatefulWidget {
  final String placeId;
  final String placeName;
  final String address;
  final double latitude;
  final double longitude;
  final String? type;

  const ListSelectorBottomSheet({
    super.key,
    required this.placeId,
    required this.placeName,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.type,
  });

  @override
  State<ListSelectorBottomSheet> createState() =>
      _ListSelectorBottomSheetState();
}

class _ListSelectorBottomSheetState extends State<ListSelectorBottomSheet> {
  List<CustomSpot> _allLists = [];

  @override
  void initState() {
    super.initState();
    // Cargar las listas personalizadas al abrir
    context.read<SpotBloc>().add(const LoadCustomSpotsEvent());
  }

  /// Obtiene el userId del usuario autenticado
  Future<String> _getUserId() async {
    final userId = di.sl<FirebaseAuthService>().getCurrentUserId();
    return userId ?? '';
  }

  /// Verifica si el lugar existe en alguna lista y retorna el nombre de la lista
  String? _findListWithPlace(String placeId) {
    for (final list in _allLists) {
      if (list.spotList.any((spot) => spot.placeId == placeId)) {
        return list.listName;
      }
    }
    return null;
  }

  /// Muestra diálogo para mover lugar entre listas
  Future<bool> _showMoveDialog(String currentList, String newList) async {
    return await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Lugar ya guardado'),
        content: Text(
          'Este lugar ya está en "$currentList".\n\n'
          '¿Quieres moverlo a "$newList"?\n\n'
          'Nota: Debido a restricciones del sistema, un lugar solo puede estar en una lista a la vez.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Mover'),
          ),
        ],
      ),
    ) ?? false;
  }

  /// Maneja la selección de una lista existente
  void _onListSelected(CustomSpot customSpot, {required bool needsCreation}) async {
    final userId = await _getUserId();

    // Verificar si el lugar ya existe en esta lista específica
    final isDuplicate = customSpot.spotList.any(
      (spot) => spot.placeId == widget.placeId,
    );

    if (isDuplicate) {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Este lugar ya existe en "${customSpot.listName}"'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Verificar si el lugar existe en OTRA lista (restricción del backend)
    final existingList = _findListWithPlace(widget.placeId);
    if (existingList != null && existingList != customSpot.listName) {
      // Preguntar si quiere mover el lugar
      final shouldMove = await _showMoveDialog(existingList, customSpot.listName);
      
      if (!shouldMove) {
        if (!mounted) return;
        Navigator.of(context).pop();
        return;
      }

      // Mover: primero eliminar de la lista actual
      if (!mounted) return;
      
      // Encontrar el spot en la lista original para obtener lat/lng
      Spot? spotToMove;
      
      for (final list in _allLists) {
        if (list.listName == existingList) {
          spotToMove = list.spotList.firstWhere(
            (s) => s.placeId == widget.placeId,
            orElse: () => SpotModel(
              userId: userId,
              spotName: widget.placeName,
              placeId: widget.placeId,
              address: widget.address,
              latitude: widget.latitude,
              longitude: widget.longitude,
              type: widget.type,
            ),
          );
          break;
        }
      }

      if (spotToMove != null) {
        // Eliminar de la lista original
        context.read<SpotBloc>().add(
              DeleteSpotFromListEvent(
                listName: existingList,
                latitude: spotToMove.latitude,
                longitude: spotToMove.longitude,
              ),
            );

        // Esperar un momento para que se procese la eliminación
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    // Crear el spot para agregar
    final spot = Spot(
      userId: userId,
      spotName: widget.placeName,
      placeId: widget.placeId,
      address: widget.address,
      latitude: widget.latitude,
      longitude: widget.longitude,
      type: widget.type,
    );

    if (!mounted) return;

    // Si la lista no existe en el backend (es predeterminada), crearla primero
    if (needsCreation) {
      final newCustomSpot = CustomSpot(
        userId: userId,
        listName: customSpot.listName,
        spotList: [spot],
      );
      
      context.read<SpotBloc>().add(
            CreateCustomSpotEvent(customSpot: newCustomSpot),
          );
    } else {
      // Agregar el lugar a la lista existente
      context.read<SpotBloc>().add(
            AddSpotToListEvent(
              listName: customSpot.listName,
              spot: spot,
            ),
          );
    }

    Navigator.of(context).pop();

    // Mostrar feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Lugar agregado a "${customSpot.listName}"'),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Muestra el diálogo para crear una nueva lista
  void _showCreateListDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => CreateListDialog(
        onConfirm: (listName) => _createListAndAddPlace(listName),
      ),
    );
  }

  /// Crea una nueva lista y agrega el lugar automáticamente
  void _createListAndAddPlace(String listName) async {
    final userId = await _getUserId();

    // Verificar si el lugar existe en OTRA lista (restricción del backend)
    final existingList = _findListWithPlace(widget.placeId);
    if (existingList != null) {
      // Preguntar si quiere mover el lugar
      final shouldMove = await _showMoveDialog(existingList, listName);
      
      if (!shouldMove) {
        return;
      }

      // Mover: primero eliminar de la lista actual
      if (!mounted) return;
      
      // Encontrar el spot en la lista original para obtener lat/lng
      Spot? spotToMove;
      
      for (final list in _allLists) {
        if (list.listName == existingList) {
          spotToMove = list.spotList.firstWhere(
            (s) => s.placeId == widget.placeId,
            orElse: () => SpotModel(
              userId: userId,
              spotName: widget.placeName,
              placeId: widget.placeId,
              address: widget.address,
              latitude: widget.latitude,
              longitude: widget.longitude,
              type: widget.type,
            ),
          );
          break;
        }
      }

      if (spotToMove != null) {
        // Eliminar de la lista original
        context.read<SpotBloc>().add(
              DeleteSpotFromListEvent(
                listName: existingList,
                latitude: spotToMove.latitude,
                longitude: spotToMove.longitude,
              ),
            );

        // Esperar un momento para que se procese la eliminación
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    // Crear el spot
    final spot = Spot(
      userId: userId,
      spotName: widget.placeName,
      placeId: widget.placeId,
      address: widget.address,
      latitude: widget.latitude,
      longitude: widget.longitude,
      type: widget.type,
    );

    // Crear la lista personalizada con el lugar incluido
    final customSpot = CustomSpot(
      userId: userId,
      listName: listName,
      spotList: [spot],
    );

    if (!mounted) return;

    context.read<SpotBloc>().add(
          CreateCustomSpotEvent(customSpot: customSpot),
        );

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Lista "$listName" creada con el lugar agregado'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Grabber
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Text(
                  'Guardar en una lista',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(),

          // Lista de custom spots
          Flexible(
          child: BlocConsumer<SpotBloc, SpotState>(
            listener: (context, state) {
              if (state is CustomSpotsLoaded) {
                setState(() {
                  _allLists = state.customSpots;
                });
              }
            },
              builder: (context, state) {
                if (state is SpotLoading) {
                  return const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColor.primaryNormal,
                      ),
                    ),
                  );
                }

                if (state is CustomSpotsLoaded) {
                  // Listas predeterminadas
                  const destacadosName = 'Destacados';
                  const favoritosName = 'Favoritos';
                  
                  // Buscar si existen en el backend
                  final destacadosSpot = state.customSpots.firstWhere(
                    (spot) => spot.listName == destacadosName,
                    orElse: () => CustomSpot(
                      userId: '',
                      listName: destacadosName,
                      spotList: [],
                    ),
                  );
                  
                  final favoritosSpot = state.customSpots.firstWhere(
                    (spot) => spot.listName == favoritosName,
                    orElse: () => CustomSpot(
                      userId: '',
                      listName: favoritosName,
                      spotList: [],
                    ),
                  );
                  
                  // Verificar si necesitan creación (no existen en backend)
                  final destacadosNeedsCreation = !state.customSpots.any((s) => s.listName == destacadosName);
                  final favoritosNeedsCreation = !state.customSpots.any((s) => s.listName == favoritosName);
                  
                  // Otras listas personalizadas
                  final otherSpots = state.customSpots.where(
                    (spot) => spot.listName != destacadosName && spot.listName != favoritosName,
                  ).toList();

                  return ListView(
                    shrinkWrap: true,
                    children: [
                      // Destacados (predeterminada)
                      ListTile(
                        leading: const Icon(
                          Icons.star,
                          color: Color(0xFFFFC107),
                        ),
                        title: const Text(destacadosName),
                        trailing: Text(
                          '${destacadosSpot.spotList.length}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        onTap: () => _onListSelected(
                          destacadosSpot,
                          needsCreation: destacadosNeedsCreation,
                        ),
                      ),
                      
                      // Favoritos (predeterminada)
                      ListTile(
                        leading: const Icon(
                          Icons.favorite,
                          color: Color(0xFFE91E63),
                        ),
                        title: const Text(favoritosName),
                        trailing: Text(
                          '${favoritosSpot.spotList.length}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        onTap: () => _onListSelected(
                          favoritosSpot,
                          needsCreation: favoritosNeedsCreation,
                        ),
                      ),
                      
                      // Otras listas personalizadas
                      ...otherSpots.map((customSpot) => ListTile(
                        leading: const Icon(
                          Icons.bookmark,
                          color: AppColor.primaryNormal,
                        ),
                        title: Text(customSpot.listName),
                        trailing: Text(
                          '${customSpot.spotList.length}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        onTap: () => _onListSelected(
                          customSpot,
                          needsCreation: false,
                        ),
                      )),
                    ],
                  );
                }

                if (state is SpotError) {
                  return Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error al cargar listas',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.red[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),

          const Divider(),

          // Botón crear nueva lista
          ListTile(
            leading: const Icon(
              Icons.add,
              color: AppColor.primaryNormal,
            ),
            title: const Text(
              'Crear nueva lista',
              style: TextStyle(
                color: AppColor.primaryNormal,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: _showCreateListDialog,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
