import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inclusive_app/features/map_view/presentation/bloc/map_bloc.dart'
    as map_bloc;
import 'package:inclusive_app/features/places/presentation/bloc/place_bloc.dart';
import 'package:inclusive_app/features/routing/presentation/bloc/route_bloc.dart';
import 'package:inclusive_app/shared/widgets/custom_floating_action_button.dart';
import 'package:inclusive_app/features/map_view/presentation/controller/map_page_controller.dart';
import 'package:inclusive_app/features/places/presentation/screen/search_page.dart';
import 'package:inclusive_app/features/places/presentation/screen/place_details_page.dart';
import 'package:inclusive_app/core/utils/polyline_decoder.dart';
import 'package:inclusive_app/core/theme/app_color.dart';
import 'package:inclusive_app/features/incidents/presentation/views/incident_type_container.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _mapController;
  late final MapPageController _controller;
  final Set<Polyline> _polylines = {};

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
          /// MAPA
          Positioned.fill(
            child: BlocListener<PlaceBloc, PlacesState>(
              listener: (context, placeState) {
                if (placeState is PlaceDetailsLoaded) {
                  final place = placeState.placeDetails;

                  _mapController?.animateCamera(
                    CameraUpdate.newLatLngZoom(
                      LatLng(place.latitude, place.longitude),
                      16,
                    ),
                  );

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _showPlaceDetails(context, place);
                  });
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
                child: BlocListener<RouteBloc, RouteState>(
                  listener: (context, routeState) {
                    if (routeState is RouteLoaded &&
                        routeState.alternativeRoute != null) {
                      setState(() {
                        _polylines.clear();

                        // Ruta segura (ORS) → evita incidencias
                        final securePolyline = PolylineDecoder.createPolyline(
                          polylineId: 'secure_route',
                          encodedPolyline:
                              routeState.alternativeRoute!.encodedPolyline,
                          color: const Color(0xFF7878FF), // Color más claro para diferenciarlo
                          width: 6,
                          isHere: false,
                          zIndex: 1,
                        );
                        _polylines.add(securePolyline);
                      });
                    }

                    // Limpiar polylines cuando se cancelen las rutas
                    if (routeState is RouteInitial) {
                      setState(() {
                        _polylines.clear();
                      });
                    }

                    if (routeState is RouteError) {
                      _showError(context, routeState.message);
                    }
                  },
                  child: GoogleMap(
                    initialCameraPosition: _defaultPosition,
                    onMapCreated: (controller) {
                      _mapController = controller;
                    },
                    polylines: _polylines,
                    myLocationEnabled: true,
                    zoomControlsEnabled: false,
                    onCameraMove: (_) => _controller.handleCameraMove(),
                    onCameraIdle: () => _controller.handleCameraIdle(),
                  ),
                ),
              ),
            ),
          ),

          /// BOTÓN MENÚ
          Positioned(
            top: 48,
            left: 16,
            child: CustomFloatingActionButton.square(
              icon: Icons.menu,
              heroTag: 'map_menu_fab',
              onPressed: () => GoRouter.of(context).push('/profile'),
            ),
          ),

          /// BOTÓN CENTRAR USUARIO
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.18,
            left: 20,
            child: CustomFloatingActionButton.primary(
              icon: Icons.navigation,
              heroTag: 'map_center_user_fab',
              onPressed: () {
                _controller.startCentering();
                context.read<map_bloc.MapBloc>().add(
                  map_bloc.GetUserLocationEvent(),
                );
              },
            ),
          ),

          /// BOTÓN INCIDENCIA (CORREGIDO)
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.18,
            right: 20,
            child: ValueListenableBuilder<bool>(
              valueListenable: _controller.isCenteredOnUser,
              builder: (context, isCentered, _) {
                if (!isCentered) return const SizedBox.shrink();

                return CustomFloatingActionButton.incidence(
                  icon: Icons.add_location_alt,
                  heroTag: 'map_incidence_fab',
                  onPressed: () => _showIncidentTypeSelection(context),
                );
              },
            ),
          ),

          /// SEARCH / BOTTOM SHEET
          DraggableScrollableSheet(
            initialChildSize: 0.15,
            minChildSize: 0.15,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
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

  void _showIncidentTypeSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const IncidentTypeContainer(),
    );
  }

  void _showPlaceDetails(BuildContext context, place) {
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
            placeId: place.placeId,
            placeName: place.name,
            address: place.address,
            photoReferences: place.photos,
            rating: place.rating,
            medals: place.medals,
            latitude: place.latitude,
            longitude: place.longitude,
          );
        },
      ),
    );
  }
}
