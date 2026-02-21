import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inclusive_app/core/theme/app_color.dart';
import 'package:inclusive_app/features/places/domain/entities/place_search_result.dart';
import 'package:inclusive_app/features/places/presentation/bloc/place_bloc.dart';
import 'package:inclusive_app/features/spot/domain/entities/spot.dart';
import 'package:inclusive_app/features/spot/domain/utils/spot_helper.dart';
import 'package:inclusive_app/features/spot/presentation/bloc/spot_bloc.dart';
import 'package:inclusive_app/features/spot/presentation/widgets/place_name_dialog.dart';
import 'package:inclusive_app/features/spot/presentation/widgets/saved_places_app_bar.dart';
import 'package:inclusive_app/features/spot/presentation/widgets/spot_search_view.dart';
import 'package:inclusive_app/features/spot/presentation/widgets/spots_list_view.dart';

/// Página para gestionar spots guardados del usuario.
/// 
/// Permite ver, agregar y eliminar lugares con búsqueda integrada.
class SavedPlacesPage extends StatefulWidget {
  final String userId;
  final String? initialSpotType;
  final String? initialSpotName;

  const SavedPlacesPage({
    super.key,
    required this.userId,
    this.initialSpotType,
    this.initialSpotName,
  });

  @override
  State<SavedPlacesPage> createState() => _SavedPlacesPageState();
}

class _SavedPlacesPageState extends State<SavedPlacesPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadUserSpots();
    
    // Si hay tipo/nombre inicial, activar modo búsqueda
    if (widget.initialSpotType != null || widget.initialSpotName != null) {
      _isSearching = true;
      Future.delayed(const Duration(milliseconds: 100), () {
        _searchFocusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
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
  }

  /// Maneja el tap en un lugar guardado.
  void _onPlaceTap(BuildContext context, String placeId) {
    // TODO: Navegar a detalles del lugar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ver detalles de: $placeId'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  /// Maneja el botón de agregar lugar - muestra el buscador.
  void _onAddPlace() {
    setState(() {
      _isSearching = true;
      _searchController.clear();
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      _searchFocusNode.requestFocus();
    });
  }

  /// Cierra el buscador y vuelve a la lista.
  void _closeSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
    });
    _searchFocusNode.unfocus();
  }

  /// Maneja la búsqueda de lugares.
  void _onSearchChanged() {
    final query = _searchController.text;
    if (query.isNotEmpty) {
      context.read<PlaceBloc>().add(SearchPlacesEvent(query));
    }
  }

  /// Maneja la selección de un lugar desde los resultados de búsqueda.
  void _onPlaceSelected(PlaceSearchResult place) {
    _searchFocusNode.unfocus();

    // Usar nombre inicial si está disponible, sino usar descripción del lugar
    final defaultName = widget.initialSpotName ?? place.description;

    showDialog(
      context: context,
      builder: (dialogContext) => PlaceNameDialog(
        initialName: defaultName,
        onConfirm: (name) => _saveSpot(place, name),
      ),
    );
  }

  /// Guarda el lugar como spot del usuario.
  void _saveSpot(PlaceSearchResult place, String name) {
    try {
      // Verificar si ya existe un spot con el mismo placeId
      final spotState = context.read<SpotBloc>().state;
      List<Spot> currentSpots = [];
      
      if (spotState is SpotsLoaded) {
        currentSpots = spotState.spots;
      }
      
      // Buscar spot duplicado por placeId
      Spot? duplicateSpot;
      try {
        duplicateSpot = currentSpots.firstWhere(
          (spot) => spot.placeId == place.placeId,
        );
      } catch (e) {
        // No hay duplicado
        duplicateSpot = null;
      }
      
      if (duplicateSpot != null) {
        // Ya existe un spot con este placeId - preguntar si desea reemplazarlo
        _showDuplicateDialog(duplicateSpot, place, name);
        return;
      }
      
      // No hay duplicado, crear el spot normalmente
      final spot = SpotHelper.createSpotFromPlace(
        place: place,
        name: name,
        userId: widget.userId,
        type: widget.initialSpotType, // Usar tipo predefinido si existe
      );

      // Crear spot a través del BLoC
      context.read<SpotBloc>().add(CreateSpotEvent(spot: spot));

      // Cerrar el buscador
      _closeSearch();
    } on ArgumentError catch (e) {
      // Mostrar error de validación
      _showErrorMessage(e.message.toString());
    }
  }

  /// Muestra un diálogo cuando se intenta guardar un lugar duplicado.
  void _showDuplicateDialog(Spot existingSpot, PlaceSearchResult place, String newName) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Lugar ya guardado'),
        content: Text(
          'Este lugar ya está guardado como "${existingSpot.spotName}".\n\n'
          '¿Deseas reemplazarlo con el nombre "$newName"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _replaceSpot(existingSpot, place, newName);
            },
            child: const Text(
              'Reemplazar',
              style: TextStyle(color: AppColor.accentNormal),
            ),
          ),
        ],
      ),
    );
  }

  /// Reemplaza un spot existente eliminándolo y creando uno nuevo.
  void _replaceSpot(Spot existingSpot, PlaceSearchResult place, String newName) {
    // Eliminar el spot existente
    context.read<SpotBloc>().add(
      DeleteSpotEvent(
        latitude: existingSpot.latitude,
        longitude: existingSpot.longitude,
      ),
    );

    // Crear el nuevo spot después de un breve delay para asegurar que se eliminó
    Future.delayed(const Duration(milliseconds: 500), () {
      final spot = SpotHelper.createSpotFromPlace(
        place: place,
        name: newName,
        userId: widget.userId,
        type: widget.initialSpotType,
      );

      context.read<SpotBloc>().add(CreateSpotEvent(spot: spot));
      _closeSearch();
    });
  }

  /// Muestra un mensaje de error al usuario.
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $message'),
        backgroundColor: AppColor.accentNormal,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Muestra un mensaje de éxito al usuario.
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColor.greenNormal,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SpotBloc, SpotState>(
      listener: _handleSpotBlocState,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(),
        body: _isSearching ? _buildSearchMode() : _buildSpotsListView(),
      ),
    );
  }

  /// Maneja los cambios de estado del SpotBloc.
  void _handleSpotBlocState(BuildContext context, SpotState state) {
    if (state is SpotCreated) {
      _showSuccessMessage('Lugar guardado exitosamente');
      _loadUserSpots();
    }

    if (state is SpotError) {
      _showErrorMessage(state.message);
    }

    // Recargar después de eliminar exitosamente
    if (state is SpotInitial) {
      _loadUserSpots();
    }
  }

  /// Construye el AppBar según el modo actual.
  PreferredSizeWidget _buildAppBar() {
    if (_isSearching) {
      return AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColor.secondaryDarker,
          ),
          onPressed: _closeSearch,
        ),
        title: const Text(
          'Buscar lugar',
          style: TextStyle(
            color: AppColor.secondaryDarker,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      );
    }
    return const SavedPlacesAppBar();
  }

  /// Construye el modo de búsqueda utilizando el widget separado.
  Widget _buildSearchMode() {
    return SpotSearchView(
      searchController: _searchController,
      searchFocusNode: _searchFocusNode,
      onPlaceSelected: _onPlaceSelected,
      onSearchChanged: _onSearchChanged,
    );
  }

  /// Construye la vista de lista de spots guardados.
  Widget _buildSpotsListView() {
    return SpotsListView(
      onAddPlace: _onAddPlace,
      onPlaceTap: (placeId) => _onPlaceTap(context, placeId),
      onDelete: _deleteSpot,
      onRefresh: _loadUserSpots,
    );
  }
}

