import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart' as places_api;
import 'package:inclusivecity_frontend/constants/app_colors.dart';
import 'package:inclusivecity_frontend/features/map/presentation/bloc/place_bloc.dart';
import 'package:inclusivecity_frontend/features/map/presentation/widget/search_bottom_sheet.dart';
import 'package:inclusivecity_frontend/features/map/presentation/widget/place_details_bottom_sheet.dart';
import 'package:inclusivecity_frontend/features/map/domain/entities/place_details.dart';



class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _mapController;
  final ValueNotifier<double> _sheetSizeNotifier = ValueNotifier<double>(0.15);
  final Set<Marker> _markers = {};
  PlaceDetails? _selectedPlaceDetails;
  bool _showDetailsSheet = false;
  bool _isCenteredOnUser = false; // Nuevo: rastrea si el mapa está centrado en el usuario
  late places_api.GoogleMapsPlaces _placesApi;

  @override
  void initState() {
    super.initState();
    // Inicializar la API de Google Places con la API Key desde .env
    final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
    _placesApi = places_api.GoogleMapsPlaces(apiKey: apiKey);
    // Disparar el evento para obtener la ubicación del usuario al iniciar
    context.read<PlacesBloc>().add(GetUserLocationEvent());
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _sheetSizeNotifier.dispose();
    super.dispose();
  }

  // Ajusta la cámara para mostrar todos los marcadores
  void _fitMarkersInView() {
    if (_markers.isEmpty || _mapController == null) return;
    
    if (_markers.length == 1) {
      // Si solo hay un marcador, centrar en él
      final marker = _markers.first;
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(marker.position, 17.0),
      );
    } else {
      // Si hay múltiples marcadores, calcular bounds
      double minLat = _markers.first.position.latitude;
      double maxLat = _markers.first.position.latitude;
      double minLng = _markers.first.position.longitude;
      double maxLng = _markers.first.position.longitude;

      for (var marker in _markers) {
        if (marker.position.latitude < minLat) minLat = marker.position.latitude;
        if (marker.position.latitude > maxLat) maxLat = marker.position.latitude;
        if (marker.position.longitude < minLng) minLng = marker.position.longitude;
        if (marker.position.longitude > maxLng) maxLng = marker.position.longitude;
      }

      final bounds = LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      );

      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 50.0), // 50 px de padding
      );
    }
  }

  // Buscar POIs cercanos a una posición específica
  Future<void> _findNearbyPOI(LatLng position) async {
    try {
      // Buscar lugares en un radio de 50 metros alrededor del tap
      final response = await _placesApi.searchNearbyWithRadius(
        places_api.Location(lat: position.latitude, lng: position.longitude),
        50, // Radio de 50 metros
        // Buscar solo tipos de establecimientos (excluir direcciones, calles, etc.)
      );

      if (!mounted) return; // Verificar que el widget sigue montado

      if (response.isOkay && response.results.isNotEmpty) {
        // Filtrar solo lugares que sean establecimientos/instituciones
        // Excluir: rutas, direcciones, áreas geográficas, etc.
        final establishments = response.results.where((place) {
          // Verificar que tenga un nombre (los POIs siempre tienen nombre)
          if (place.name.isEmpty) return false;
          
          // Verificar que tenga tipos de establecimiento
          final types = place.types;
          
          // Excluir tipos que NO son establecimientos
          final excludedTypes = [
            'route', 'street_address', 'premise', 'subpremise',
            'neighborhood', 'locality', 'administrative_area_level_1',
            'administrative_area_level_2', 'administrative_area_level_3',
            'country', 'political', 'postal_code', 'intersection',
          ];
          
          // Si contiene algún tipo excluido, no es un establecimiento
          if (types.any((type) => excludedTypes.contains(type))) {
            return false;
          }
          
          // Incluir solo si tiene tipos de establecimiento válidos
          final validTypes = [
            'establishment', 'point_of_interest', 'store', 'restaurant',
            'cafe', 'bar', 'food', 'shopping_mall', 'park', 'museum',
            'school', 'university', 'hospital', 'pharmacy', 'bank',
            'atm', 'gym', 'library', 'church', 'mosque', 'synagogue',
            'hindu_temple', 'movie_theater', 'stadium', 'zoo',
            'amusement_park', 'aquarium', 'art_gallery', 'beauty_salon',
            'book_store', 'bowling_alley', 'bus_station', 'campground',
            'car_dealer', 'car_rental', 'car_repair', 'car_wash',
            'casino', 'cemetery', 'city_hall', 'clothing_store',
            'convenience_store', 'courthouse', 'dentist', 'department_store',
            'doctor', 'drugstore', 'electrician', 'electronics_store',
            'embassy', 'fire_station', 'florist', 'funeral_home',
            'furniture_store', 'gas_station', 'grocery_or_supermarket',
            'hair_care', 'hardware_store', 'home_goods_store',
            'insurance_agency', 'jewelry_store', 'laundry', 'lawyer',
            'liquor_store', 'local_government_office', 'locksmith',
            'lodging', 'meal_delivery', 'meal_takeaway', 'night_club',
            'painter', 'parking', 'pet_store', 'physiotherapist',
            'plumber', 'police', 'post_office', 'primary_school',
            'real_estate_agency', 'roofing_contractor', 'rv_park',
            'secondary_school', 'shoe_store', 'spa', 'storage',
            'subway_station', 'supermarket', 'taxi_stand', 'tourist_attraction',
            'train_station', 'transit_station', 'travel_agency',
            'veterinary_care',
          ];
          
          // Es un establecimiento si tiene al menos un tipo válido
          return types.any((type) => validTypes.contains(type));
        }).toList();
        
        if (establishments.isEmpty) {
          // No hay establecimientos cercanos, cerrar el sheet si está abierto
          if (_showDetailsSheet) {
            setState(() {
              _showDetailsSheet = false;
              _selectedPlaceDetails = null;
              _markers.clear();
            });
            context.read<PlacesBloc>().add(LoadSearchHistoryEvent());
          }
          return;
        }
        
        // Tomar el establecimiento más cercano
        final nearestPlace = establishments.first;
        
        // Obtener los detalles del lugar usando nuestro backend
        debugPrint('POI (establecimiento) encontrado: ${nearestPlace.name} - ${nearestPlace.placeId}');
        context.read<PlacesBloc>().add(SelectPlaceEvent(nearestPlace.placeId));
      } else {
        // No hay POI cercano, cerrar el sheet si está abierto
        if (_showDetailsSheet) {
          setState(() {
            _showDetailsSheet = false;
            _selectedPlaceDetails = null;
            _markers.clear();
          });
          context.read<PlacesBloc>().add(LoadSearchHistoryEvent());
        }
      }
    } catch (e) {
      debugPrint('Error al buscar POI cercano: $e');
      
      if (!mounted) return; // Verificar que el widget sigue montado
      
      // Si hay error, comportamiento normal de cerrar sheet
      if (_showDetailsSheet) {
        setState(() {
          _showDetailsSheet = false;
          _selectedPlaceDetails = null;
          _markers.clear();
        });
        context.read<PlacesBloc>().add(LoadSearchHistoryEvent());
      }
    }
  }

  // Posición inicial del mapa
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(0, 0), // Se actualizará a la ubicación del usuario
    zoom: 2.0,
  );

  @override
  Widget build(BuildContext context) {
    return BlocListener<PlacesBloc, PlacesState>(
      listener: (context, state) {
        if (state is UserLocationLoaded) {
          // Mover la cámara a la ubicación del usuario
          _mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(
              LatLng(state.latitude, state.longitude),
              16.0,
            ),
          );
          setState(() {
            _isCenteredOnUser = true;
          });
        } else if (state is PlacesLoaded && state.suggestions.isNotEmpty) {
          // Cuando hay resultados de búsqueda, agregar marcadores en el mapa
          setState(() {
            _isCenteredOnUser = false;
            _markers.clear();
            for (var suggestion in state.suggestions) {
              if (suggestion.latitude != null && suggestion.longitude != null) {
                _markers.add(
                  Marker(
                    markerId: MarkerId(suggestion.placeId),
                    position: LatLng(suggestion.latitude!, suggestion.longitude!),
                    infoWindow: InfoWindow(
                      title: suggestion.description,
                      snippet: suggestion.address ?? '',
                    ),
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                    onTap: () {
                      // Cuando se toca un marcador de búsqueda, obtener detalles completos
                      context.read<PlacesBloc>().add(SelectPlaceEvent(suggestion.placeId));
                    },
                  ),
                );
              }
            }
            
            // Si hay marcadores, ajustar la cámara para mostrarlos todos
            if (_markers.isNotEmpty) {
              _fitMarkersInView();
            }
          });
        } else if (state is PlaceDetailsLoaded) {
          // Mover la cámara al lugar seleccionado y agregar marcador
          final placeDetails = state.placeDetails;
          final latLng = LatLng(placeDetails.latitude, placeDetails.longitude);
          
          _mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(latLng, 17.0),
          );
          
          // Agregar/actualizar marcador
          setState(() {
            _isCenteredOnUser = false;
            _markers.clear();
            _markers.add(
              Marker(
                markerId: MarkerId(placeDetails.placeId),
                position: latLng,
                infoWindow: InfoWindow(
                  title: placeDetails.name,
                  snippet: placeDetails.address,
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                onTap: () {
                  // Cuando se toca el marcador, mostrar los detalles nuevamente
                  setState(() {
                    _selectedPlaceDetails = placeDetails;
                    _showDetailsSheet = true;
                  });
                },
              ),
            );
            
            // Mostrar el bottom sheet de detalles
            _selectedPlaceDetails = placeDetails;
            _showDetailsSheet = true;
          });
        } else if (state is PlacesError) {
          // Mostrar mensaje de error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            //El Mapa de Google
            GoogleMap(
              initialCameraPosition: _initialPosition,
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              markers: _markers,
              myLocationButtonEnabled: false,
              myLocationEnabled: true,
              zoomControlsEnabled: false,
              onTap: (LatLng position) async {
                // Buscar POIs cercanos a donde se hizo tap
                await _findNearbyPOI(position);
              },
            ),

            // Bottom sheet de búsqueda (solo cuando no hay detalles)
            if (!_showDetailsSheet)
              SearchBottomSheet(sheetSizeNotifier: _sheetSizeNotifier),
            
            // Bottom sheet de detalles del lugar
            if (_showDetailsSheet && _selectedPlaceDetails != null)
              PlaceDetailsBottomSheet(
                placeDetails: _selectedPlaceDetails!,
                onClose: () {
                  setState(() {
                    _showDetailsSheet = false;
                    _selectedPlaceDetails = null;
                    _markers.clear();
                  });
                  // Recargar el historial de búsqueda
                  context.read<PlacesBloc>().add(LoadSearchHistoryEvent());
                },
              ),

            ValueListenableBuilder<double>(
              valueListenable: _sheetSizeNotifier,
              builder: (context, sheetSize, child) {
                // Oculta el botón cuando el sheet es mayor al 30% o cuando se muestra el sheet de detalles
                final shouldShow = sheetSize < 0.3 && !_showDetailsSheet;
                return AnimatedPositioned(
                  duration: const Duration(milliseconds: 200),
                  top: shouldShow ? 50.0 : -100.0, // Mueve fuera de pantalla
                  left: 16.0,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: shouldShow ? 1.0 : 0.0,
                    child: Container(
                      width: 64.0,
                      height: 64.0,
                      decoration: BoxDecoration(
                        color: AppColors.primaryNormal,
                        borderRadius: BorderRadius.circular(14.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8.0,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(14.0),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14.0),
                          onTap: () {
                            // TODO: Implementar la apertura del Drawer/Menú lateral
                            print("Botón de menú presionado");
                          },
                          child: const Center(
                            child: Icon(
                              Icons.menu,
                              color: AppColors.surface,
                              size: 32.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),


            // Botón de GPS (azul) - lado izquierdo
            ValueListenableBuilder<double>(
              valueListenable: _sheetSizeNotifier,
              builder: (context, sheetSize, child) {
                final shouldShow = sheetSize < 0.3 && !_showDetailsSheet;
                return AnimatedPositioned(
                  duration: const Duration(milliseconds: 200),
                  bottom: shouldShow ? 148.0 : -100.0,
                  left: 16.0,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: shouldShow ? 1.0 : 0.0,
                    child: Container(
                      width: 64.0,
                      height: 64.0,
                      decoration: BoxDecoration(
                        color: AppColors.primaryNormal,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8.0,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(32.0),
                          onTap: () {
                            context.read<PlacesBloc>().add(GetUserLocationEvent());
                          },
                          child: const Center(
                            child: Icon(
                              Icons.navigation_rounded,
                              color: AppColors.surface,
                              size: 32.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            // Botón de incidencias (amarillo) - lado derecho, solo cuando está centrado en el usuario
            ValueListenableBuilder<double>(
              valueListenable: _sheetSizeNotifier,
              builder: (context, sheetSize, child) {
                final shouldShow = sheetSize < 0.3 && !_showDetailsSheet && _isCenteredOnUser;
                return AnimatedPositioned(
                  duration: const Duration(milliseconds: 200),
                  bottom: shouldShow ? 148.0 : -100.0,
                  right: 16.0,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: shouldShow ? 1.0 : 0.0,
                    child: Container(
                      width: 64.0,
                      height: 64.0,
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8.0,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(32.0),
                          onTap: () {
                            // TODO: Implementar la funcionalidad de incidencias
                            print("Botón de incidencias presionado");
                          },
                          child: const Center(
                            child: Icon(
                              Icons.warning_amber_rounded,
                              color: AppColors.surface,
                              size: 32.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}