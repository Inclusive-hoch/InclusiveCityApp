import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:inclusive_app/core/theme/app_color.dart';
import 'package:inclusive_app/features/spot/presentation/bloc/spot_bloc.dart';
import 'package:inclusive_app/features/spot/presentation/widgets/custom_spot_list_card.dart';

/// Página que muestra todas las listas personalizadas del usuario.
/// 
/// Permite ver, crear y gestionar listas de lugares favoritos.
class CustomSpotsListsPage extends StatefulWidget {
  const CustomSpotsListsPage({super.key});

  @override
  State<CustomSpotsListsPage> createState() => _CustomSpotsListsPageState();
}

class _CustomSpotsListsPageState extends State<CustomSpotsListsPage> {
  @override
  void initState() {
    super.initState();
    _loadCustomSpots();
  }

  void _loadCustomSpots() {
    context.read<SpotBloc>().add(const LoadCustomSpotsEvent());
  }

  void _onListTap(String listName, int spotCount) {
    context.push('/list-detail', extra: {
      'listName': listName,
    });
  }

  void _onDeleteList(String listName) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar lista'),
        content: Text('¿Estás seguro de eliminar la lista "$listName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<SpotBloc>().add(
                    DeleteCustomSpotListEvent(listName: listName),
                  );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Listas'),
        backgroundColor: AppColor.primaryNormal,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<SpotBloc, SpotState>(
        listener: (context, state) {
          if (state is CustomSpotListDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lista eliminada (${state.deletedCount} registros)'),
                backgroundColor: Colors.green,
              ),
            );
            _loadCustomSpots();
          }

          if (state is CustomSpotCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lista "${state.customSpot.listName}" creada'),
                backgroundColor: Colors.green,
              ),
            );
            _loadCustomSpots();
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

          if (state is CustomSpotsLoaded) {
            if (state.customSpots.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bookmarks_outlined,
                        size: 120,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'No tienes listas personalizadas',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Guarda lugares en listas personalizadas\npara organizarlos y acceder fácilmente',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Volver al mapa
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

            return RefreshIndicator(
              onRefresh: () async => _loadCustomSpots(),
              color: AppColor.primaryNormal,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.customSpots.length,
                itemBuilder: (context, index) {
                  final customSpot = state.customSpots[index];
                  return CustomSpotListCard(
                    listName: customSpot.listName,
                    spotCount: customSpot.spotList.length,
                    spots: customSpot.spotList,
                    onTap: () => _onListTap(
                      customSpot.listName,
                      customSpot.spotList.length,
                    ),
                    onDelete: () => _onDeleteList(customSpot.listName),
                  );
                },
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
                      'Error al cargar listas',
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
                      onPressed: _loadCustomSpots,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
