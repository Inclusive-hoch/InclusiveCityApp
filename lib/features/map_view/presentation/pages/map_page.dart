import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inclusive_app/features/map_view/presentation/bloc/map_bloc.dart' as map_bloc;
import 'package:inclusive_app/features/places/presentation/bloc/place_bloc.dart';
import 'package:inclusive_app/shared/widgets/custom_floating_action_button.dart';
import 'package:inclusive_app/features/map_view/presentation/controller/map_page_controller.dart';
import 'package:inclusive_app/features/places/presentation/screen/search_page.dart';
import 'package:inclusive_app/features/places/presentation/screen/place_details_page.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<StatefulWidget> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _mapController;
  late final MapPageController _controller;

  static const double _userLocationZoom = 15;
  static const CameraPosition _defaultPosition = CameraPosition(
    target: LatLng(0, 0),
    zoom: 2,
  );

  @override
  void initState() {
    super.initState();
    _controller = MapPageController();
    context.read<map_bloc.MapBloc>().add(map_bloc.GetUserLocationEvent());
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Listener para centrar el mapa cuando se selecciona un lugar
          BlocListener<PlaceBloc, PlacesState>(
            listener: (context, placeState) {
              if (placeState is PlaceDetailsLoaded) {
                final place = placeState.placeDetails;
                
                // Centrar el mapa en el lugar seleccionado
                _mapController?.animateCamera(
                  CameraUpdate.newLatLngZoom(
                    LatLng(place.latitude, place.longitude),
                    16, // Zoom cercano al lugar
                  ),
                );

                // Mostrar los detalles del lugar en un bottom sheet
                _showPlaceDetails(context, place);
              }
            },
            child: BlocListener<map_bloc.MapBloc, map_bloc.MapState>(
              listener: (context, state) {
                if (state is map_bloc.MapLocationLoaded) {
                  _mapController?.animateCamera(
                    CameraUpdate.newLatLngZoom(
                      LatLng(state.latitude, state.longitude),
                      _userLocationZoom,
                    ),
                  );
                }
                if (state is map_bloc.MapError) {
                  _showError(context, state.message);
                }
              },
              child: GoogleMap(
                initialCameraPosition: _defaultPosition,
                onMapCreated: (controller) => _mapController = controller,
                myLocationEnabled: true,
                zoomControlsEnabled: false,
                onCameraMove: (_) => _controller.handleCameraMove(),
                onCameraIdle: () => _controller.handleCameraIdle(),
              ),
            ),
          ),

          Positioned(
            top: 48,
            left: 16,
            child: CustomFloatingActionButton.square(
              icon: Icons.menu,
              onPressed: () => log('Abrir menu'),
            ),
          ),

          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.18, 
            left: 20,
            child: CustomFloatingActionButton.primary(
              icon: Icons.navigation,
              onPressed: () {
                _controller.startCentering();
                context.read<map_bloc.MapBloc>().add(map_bloc.GetUserLocationEvent());
              },
            ),
          ),

          ValueListenableBuilder<bool>(
            valueListenable: _controller.isCenteredOnUser,
            builder: (context, isCentered, _) {
              if (!isCentered) return const SizedBox.shrink();

              return Positioned(
                bottom: MediaQuery.of(context).size.height * 0.18,
                right: 20,
                child: CustomFloatingActionButton.incidence(
                  icon: Icons.add_location_alt,
                  onPressed: () => log("Nueva incidencia"),
                ),
              );
            },
          ),

          DraggableScrollableSheet(
            initialChildSize:
                0.15, // Empieza ocupando el 20% de la pantalla (abajo)
            minChildSize: 0.15, // Lo mínimo que se puede esconder (15%)
            maxChildSize: 0.9, // Se estira hasta casi arriba (90%)
            builder: (context, scrollController) {
              // Aquí le pasamos el "controlador" mágico a nuestra SearchPage
              return SearchPage(scrollController: scrollController);
            },
          ),
        ],
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  /// Muestra los detalles del lugar en un bottom sheet modal
  void _showPlaceDetails(BuildContext context, place) {
    final sheetController = DraggableScrollableController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => DraggableScrollableSheet(
        controller: sheetController,
        initialChildSize: 0.9,
        minChildSize: 0.3,
        maxChildSize: 0.95,
        snap: true,
        snapSizes: const [0.3, 0.9],
        builder: (context, scrollController) {
          // Escuchar cambios en el tamaño del sheet para cerrar cuando llegue al mínimo
          sheetController.addListener(() {
            if (sheetController.size <= 0.31) {
              Navigator.pop(context);
            }
          });
          
          return PlaceDetailsPage(
            placeId: place.placeId,
            placeName: place.name,
            address: place.address,
            photoReferences: place.photos,
            rating: place.rating,
            medals: place.medals,
          );
        },
      ),
    );
  }
}
