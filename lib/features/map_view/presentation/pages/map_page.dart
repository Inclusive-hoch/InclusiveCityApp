import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:markers_cluster_google_maps_flutter/markers_cluster_google_maps_flutter.dart';
import 'package:inclusive_app/features/map_view/presentation/bloc/map_bloc.dart'
    as map_bloc;
import 'package:inclusive_app/features/incidents/domain/entities/sector_incidence_entity.dart';
import 'package:inclusive_app/features/incidents/presentation/constants/incidence_marker_icons.dart';
import 'package:inclusive_app/core/utils/marker_icon_generator.dart';
import 'package:inclusive_app/features/places/presentation/bloc/place_bloc.dart';
import 'package:inclusive_app/features/routing/application/bloc/route_bloc.dart';
import 'package:inclusive_app/shared/widgets/custom_floating_action_button.dart';
import 'package:inclusive_app/features/map_view/presentation/controller/map_page_controller.dart';
import 'package:inclusive_app/features/places/presentation/screen/search_page.dart';
import 'package:inclusive_app/features/places/presentation/screen/place_details_page.dart';
import 'package:inclusive_app/core/utils/polyline_decoder.dart';
import 'package:inclusive_app/features/incidents/presentation/views/incident_type_container.dart';
import 'package:inclusive_app/features/incidents/presentation/views/incidence_detail_sheet.dart';
import 'package:inclusive_app/features/incidents/application/bloc/incident_report_bloc.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _mapController;
  late final MapPageController _controller;
  final Set<Polyline> _polylines = {};

  /// Cluster manager para agrupar markers de incidencias.
  late MarkersClusterManager _clusterManager;

  /// Lista de incidencias actualmente cargadas (para lookup al hacer tap).
  List<SectorIncidenceEntity> _loadedIncidences = [];

  /// Zoom actual del mapa, usado por el cluster manager.
  double _currentZoom = 2.0;

  static const double _userLocationZoom = 15;

  /// Umbral de zoom a partir del cual se muestran incidencias.
  static const double _incidenceZoomThreshold = 14.0;

  /// Color del cluster de incidencias.
  static const Color _clusterColor = Color(0xFFFF8C00);

  /// Indica si actualmente se están mostrando incidencias.
  bool _showingIncidences = false;

  static const CameraPosition _defaultPosition = CameraPosition(
    target: LatLng(0, 0),
    zoom: 2,
  );

  /// Crea una nueva instancia del cluster manager con la configuración estándar.
  MarkersClusterManager _buildClusterManager() {
    return MarkersClusterManager(
      clusterColor: _clusterColor,
      clusterBorderThickness: 8.0,
      clusterBorderColor: Colors.white,
      clusterOpacity: 1.0,
      clusterTextStyle: const TextStyle(
        fontSize: 32,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      onMarkerTap: (LatLng position) {
        _onIncidenceMarkerTapped(position);
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = MapPageController();
    _clusterManager = _buildClusterManager();

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
              child: BlocListener<IncidentReportBloc, IncidentReportState>(
                listener: (context, incidentState) {
                  if (incidentState is IncidentReportSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(incidentState.message)),
                    );
                    _checkZoomAndFetchIncidences();
                  }

                  if (incidentState is IncidentReportFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(incidentState.message)),
                    );
                  }
                },
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

                      if (state is map_bloc.SectorIncidencesLoaded) {
                        _handleIncidencesLoaded(state.incidences);
                      }

                      if (state is map_bloc.SectorIncidencesCleared) {
                        _loadedIncidences = [];
                        _clusterManager = _buildClusterManager();
                        _updateClusters();
                      }
                    },
                    child: BlocListener<RouteBloc, RouteState>(
                      listener: (context, routeState) {
                        if (routeState is RouteLoaded &&
                            routeState.alternativeRoute != null) {
                          setState(() {
                            _polylines.clear();

                            final securePolyline =
                                PolylineDecoder.createPolyline(
                                  polylineId: 'secure_route',
                                  encodedPolyline: routeState
                                      .alternativeRoute!
                                      .encodedPolyline,
                                  color: const Color(0xFF7878FF),
                                  width: 6,
                                  isHere: false,
                                  zIndex: 1,
                                );
                            _polylines.add(securePolyline);
                          });
                        }

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
                        markers: {
                          ..._clusterManager.getClusteredMarkers(),
                        },
                        myLocationEnabled: true,
                        zoomControlsEnabled: false,
                        onCameraMove: (position) {
                          _currentZoom = position.zoom;
                          _controller.handleCameraMove();
                        },
                        onCameraIdle: () {
                          _controller.handleCameraIdle();
                          _updateClusters();
                          _checkZoomAndFetchIncidences();
                        },
                      ),
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

            /// BOTÓN INCIDENCIA
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

  /// Procesa las incidencias cargadas: genera íconos personalizados
  /// y los agrega al cluster manager.
  ///
  /// Los iconos se generan con alta resolución (pixelRatio 3.0) para
  /// mejorar la calidad visual en el mapa.
  Future<void> _handleIncidencesLoaded(
    List<SectorIncidenceEntity> incidences,
  ) async {
    // Recrear el cluster manager para limpiar markers anteriores
    _clusterManager = _buildClusterManager();
    _loadedIncidences = incidences;

    for (final incidence in incidences) {
      final iconData = getIncidenceIcon(incidence.incidence);
      // Generar ícono de alta resolución (48px físicos = 16px visual × 3.0)
      final bitmapIcon = await MarkerIconGenerator.fromIconData(
        iconData,
        backgroundColor: _clusterColor,
      );

      _clusterManager.addMarker(
        Marker(
          markerId: MarkerId('incidence_${incidence.placeId}'),
          position: LatLng(incidence.latitude, incidence.longitude),
          icon: bitmapIcon,
          onTap: () => _onIncidenceMarkerTapped(
            LatLng(incidence.latitude, incidence.longitude),
          ),
        ),
      );
    }

    await _updateClusters();
  }

  /// Actualiza los clusters según el nivel de zoom actual.
  Future<void> _updateClusters() async {
    await _clusterManager.updateClusters(zoomLevel: _currentZoom);
    if (mounted) {
      setState(() {});
    }
  }

  /// Verifica el nivel de zoom y obtiene o limpia incidencias del sector.
  Future<void> _checkZoomAndFetchIncidences() async {
    if (_mapController == null) return;

    final zoomLevel = await _mapController!.getZoomLevel();
    final bounds = await _mapController!.getVisibleRegion();

    if (zoomLevel >= _incidenceZoomThreshold) {
      _showingIncidences = true;
      if (!mounted) return;
      context.read<map_bloc.MapBloc>().add(
        map_bloc.FetchSectorIncidencesEvent(
          northEastLat: bounds.northeast.latitude,
          northEastLng: bounds.northeast.longitude,
          southWestLat: bounds.southwest.latitude,
          southWestLng: bounds.southwest.longitude,
        ),
      );
    } else if (_showingIncidences) {
      _showingIncidences = false;
      if (!mounted) return;
      context.read<map_bloc.MapBloc>().add(
        map_bloc.ClearSectorIncidencesEvent(),
      );
    }
  }

  /// Busca las incidencias en la posición del marker y muestra el detalle.
  void _onIncidenceMarkerTapped(LatLng position) {
    // Buscar incidencias cercanas a esta posición (tolerancia por clustering)
    final matching = _loadedIncidences.where((inc) {
      return (inc.latitude - position.latitude).abs() < 0.0001 &&
          (inc.longitude - position.longitude).abs() < 0.0001;
    }).toList();

    if (matching.isEmpty) return;

    _showIncidenceDetail(matching);
  }

  /// Muestra el modal draggable con la lista de imágenes de incidencias.
  void _showIncidenceDetail(List<SectorIncidenceEntity> incidences) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => IncidenceDetailSheet(incidences: incidences),
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showIncidentTypeSelection(BuildContext context) {
    showModalBottomSheet<IncidentSelectionResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const IncidentTypeContainer(),
    ).then((result) async {
      if (result == null || !mounted) return;
      await _reportIncident(result);
    });
  }

  Future<void> _reportIncident(IncidentSelectionResult selection) async {
    if (_mapController == null) {
      _showError(context, 'No se pudo obtener la ubicación del mapa.');
      return;
    }

    final bounds = await _mapController!.getVisibleRegion();
    final latitude =
        (bounds.northeast.latitude + bounds.southwest.latitude) / 2;
    final longitude =
        (bounds.northeast.longitude + bounds.southwest.longitude) / 2;

    if (!mounted) return;
    context.read<IncidentReportBloc>().add(
      ReportIncidentRequested(
        latitude: latitude,
        longitude: longitude,
        incidence: selection.subType,
        image: selection.photoPath ?? '',
      ),
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
