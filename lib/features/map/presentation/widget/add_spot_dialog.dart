import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inclusivecity_frontend/constants/app_colors.dart';
import 'package:inclusivecity_frontend/core/auth/auth_service.dart';
import 'package:inclusivecity_frontend/features/map/domain/entities/place_suggestion.dart';
import 'package:inclusivecity_frontend/features/map/domain/entities/spot_entity.dart';
import 'package:inclusivecity_frontend/features/map/presentation/bloc/place_bloc.dart';
import 'package:inclusivecity_frontend/features/map/presentation/bloc/spots_bloc.dart';

/// Diálogo estilo Waze para agregar un spot personalizado
/// Permite buscar direcciones usando el mismo buscador que search_bottom_sheet
class AddSpotDialog extends StatefulWidget {
  final SpotsBloc spotsBloc;
  final PlacesBloc placesBloc;
  
  const AddSpotDialog({
    super.key, 
    required this.spotsBloc,
    required this.placesBloc,
  });

  @override
  State<AddSpotDialog> createState() => _AddSpotDialogState();
}

class _AddSpotDialogState extends State<AddSpotDialog> {
  final _nameController = TextEditingController();
  final _searchController = TextEditingController();
  
  String _selectedType = 'Casa';
  PlaceSuggestion? _selectedPlace;
  bool _showResults = false; // Control manual de visibilidad

  final List<Map<String, dynamic>> _spotTypes = [
    {'value': 'Casa', 'icon': Icons.home},
    {'value': 'Trabajo', 'icon': Icons.work},
    {'value': 'Otro', 'icon': Icons.place},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (query.trim().isEmpty) {
      // Limpiar resultados si está vacío
      setState(() {
        _selectedPlace = null;
        _showResults = false;
      });
      return;
    }
    
    setState(() => _showResults = true);
    
    // Disparar búsqueda usando PlacesBloc (igual que search_bottom_sheet)
    widget.placesBloc.add(SearchPlacesEvent(query.trim()));
  }

  void _selectPlace(PlaceSuggestion place) {
    setState(() {
      _selectedPlace = place;
      _searchController.text = place.description; // description es solo el nombre
      _showResults = false; // Ocultar resultados después de seleccionar
    });
  }

  void _saveSpot() async {
    // Solo validar nombre si tipo es "Otro"
    if (_selectedType == 'Otro' && _nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa un nombre personalizado'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedPlace == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Busca y selecciona una dirección'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final userId = AuthService().requireUserId();
    
    // Usar el nombre personalizado si es "Otro", sino usar el tipo
    final spotName = _selectedType == 'Otro' 
        ? _nameController.text.trim() 
        : _selectedType;
    
    final spot = SpotEntity(
      userId: userId,
      spotName: spotName,
      placeId: _selectedPlace!.placeId,
      address: _selectedPlace!.address ?? _selectedPlace!.description, // Usar address, no description
      latitude: _selectedPlace!.latitude ?? 0,
      longitude: _selectedPlace!.longitude ?? 0,
      type: _selectedType,
    );

    widget.spotsBloc.add(SaveSpotEvent(spot));

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$spotName agregado'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.primaryNormal,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.add_location, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Agregar Lugar',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tipo de lugar (ahora primero)
                    const Text(
                      'Tipo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _spotTypes.map((type) {
                        final isSelected = _selectedType == type['value'];
                        return FilterChip(
                          selected: isSelected,
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                type['icon'] as IconData,
                                size: 18,
                                color: isSelected ? Colors.white : Colors.grey[700],
                              ),
                              const SizedBox(width: 6),
                              Text(type['value'] as String),
                            ],
                          ),
                          onSelected: (_) {
                            setState(() => _selectedType = type['value'] as String);
                          },
                          selectedColor: AppColors.primaryNormal,
                          backgroundColor: Colors.grey[100],
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[800],
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                          checkmarkColor: Colors.white,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Nombre personalizado (solo si tipo es "Otro")
                    if (_selectedType == 'Otro') ...[
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Nombre personalizado',
                          hintText: 'Ej: Gimnasio favorito, Casa de mamá',
                          prefixIcon: const Icon(Icons.label_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Buscar dirección
                    TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        labelText: 'Buscar dirección',
                        hintText: 'Escribe una dirección...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _selectedPlace = null;
                                    _showResults = false;
                                  });
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),

                    // Mostrar lugar seleccionado
                    if (_selectedPlace != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primaryNormal, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryNormal,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Lugar seleccionado',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryNormal,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _selectedPlace!.description,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.neutralDarkDarker,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (_selectedPlace!.address != null && _selectedPlace!.address!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Row(
                                        children: [
                                          Icon(Icons.place, size: 13, color: Colors.grey[700]),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              _selectedPlace!.address!,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[700],
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Resultados de búsqueda usando BlocBuilder (igual que search_bottom_sheet)
                    if (_showResults)
                      BlocBuilder<PlacesBloc, PlacesState>(
                        bloc: widget.placesBloc,
                        builder: (context, state) {
                          // Mostrar loading
                          if (state is PlacesLoading) {
                            return Container(
                              margin: const EdgeInsets.only(top: 8),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          // Mostrar resultados
                          if (state is PlacesLoaded && state.suggestions.isNotEmpty) {
                          return Container(
                            margin: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            constraints: const BoxConstraints(maxHeight: 250),
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemCount: state.suggestions.length,
                              separatorBuilder: (_, __) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final place = state.suggestions[index];
                                
                                return ListTile(
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.location_on,
                                      color: AppColors.primaryNormal,
                                      size: 20,
                                    ),
                                  ),
                                  title: Text(
                                    place.description,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      color: AppColors.neutralDarkDarker,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: place.address != null && place.address!.isNotEmpty
                                      ? Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Row(
                                            children: [
                                              Icon(Icons.place, size: 14, color: Colors.grey[600]),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  place.address!,
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey[700],
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : null,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  onTap: () => _selectPlace(place),
                                );
                              },
                            ),
                          );
                        }

                        // Mensaje cuando no hay resultados
                        if (state is PlacesEmpty) {
                          return Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.search_off, color: Colors.grey[600]),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'No se encontraron lugares',
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Footer con botón
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(top: BorderSide(color: Colors.grey[200]!)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveSpot,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryNormal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Guardar lugar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
