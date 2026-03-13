import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:markers_cluster_google_maps_flutter/markers_cluster_google_maps_flutter.dart';
import 'package:inclusive_app/core/utils/polyline_decoder.dart';
import 'package:inclusive_app/features/routing/application/bloc/route_bloc.dart';
import 'package:inclusive_app/features/routing/presentation/widgets/origin_location_sheet.dart';
import 'package:inclusive_app/features/routing/presentation/widgets/route_location_card.dart';
import 'package:inclusive_app/features/routing/presentation/widgets/route_info_bottom_sheet.dart';
import 'package:inclusive_app/features/map_view/presentation/bloc/map_bloc.dart' as map_bloc;
import 'package:inclusive_app/features/incidents/domain/entities/sector_incidence_entity.dart';
import 'package:inclusive_app/features/incidents/presentation/constants/incidence_marker_icons.dart';
import 'package:inclusive_app/core/utils/marker_icon_generator.dart';
import 'package:inclusive_app/features/routing/utils/route_icon_cache.dart';

/// Página de selección de ruta que muestra el mapa con la ruta generada.
///
/// Navegación: Se navega aquí al presionar "Generar ruta" en los detalles del lugar.
/// Cierre: Botón "Cancelar" para regresar a la pantalla anterior.
class RouteSelectionPage extends StatefulWidget {
  /// Latitud del origen (ubicación del usuario)
  final double originLat;

  /// Longitud del origen (ubicación del usuario)
  final double originLng;

  /// Latitud del destino
  final double destLat;

  /// Longitud del destino
  final double destLng;

  /// Nombre del lugar de origen (ej: "Av. Alemania")
  final String originName;

  /// Nombre del lugar de destino (ej: "Supermercado Unimarc, Caupolicán")
  final String destName;

  const RouteSelectionPage({
    super.key,
    required this.originLat,
    required this.originLng,
    required this.destLat,
    required this.destLng,
    required this.originName,
    required this.destName,
  });

  @override
  State<RouteSelectionPage> createState() => _RouteSelectionPageState();
}

class _RouteSelectionPageState extends State<RouteSelectionPage> {
  GoogleMapController? _mapController;
  final Set<Polyline> _polylines = {};
  final Set<Marker> _markers = {};
  BitmapDescriptor? _originIcon;
  BitmapDescriptor? _destIcon;

  // Estado mutable para el origen y destino (pueden cambiar si el usuario los edita)
  late double _originLat;
  late double _originLng;
  late String _originName;

  late double _destLat;
  late double _destLng;
  late String _destName;

  /// Cluster manager para agrupar markers de incidencias.
  late MarkersClusterManager _clusterManager;

  /// Zoom actual del mapa.
  double _currentZoom = 14.0;

  /// Color del cluster de incidencias.
  static const Color _clusterColor = Color(0xFFFF8C00);

  @override
  void initState() {
    super.initState();

    // Inicializar origen y destino desde los parámetros del widget
    _originLat = widget.originLat;
    _originLng = widget.originLng;
    _originName = widget.originName;

    _destLat = widget.destLat;
    _destLng = widget.destLng;
    _destName = widget.destName;

    // Inicializar cluster manager
    _clusterManager = _buildClusterManager();

    // Cargar iconos personalizados
    _loadCustomIcons();

    // Obtener la ruta segura al iniciar la pantalla (evita incidencias)
    context.read<RouteBloc>().add(
      GetAlternativeRouteEvent(
        originLat: _originLat,
        originLng: _originLng,
        destLat: _destLat,
        destLng: _destLng,
      ),
    );

    // Configurar marcadores de origen y destino
    _setupMarkers();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

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
    );
  }

  /// Carga los iconos personalizados desde los assets SVG
  Future<void> _loadCustomIcons() async {
  // 1. Esperamos a que el caché termine (si es que aún no terminó de cargar en el main)
  await RouteIconCache().preloadIcons();
  
  // 2. Simplemente pedimos los iconos ya procesados de la memoria RAM
  setState(() {
    _originIcon = RouteIconCache().originIcon;
    _destIcon = RouteIconCache().destIcon;
  });
}

void _setupMarkers() {
  // Solo crear marcadores si tenemos los datos necesarios
  final Set<Marker> newMarkers = {};

  newMarkers.add(
    Marker(
      markerId: const MarkerId('origin'),
      position: LatLng(_originLat, _originLng),
      icon: _originIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      anchor: const Offset(0.5, 0.5),
      infoWindow: InfoWindow(title: 'Origen', snippet: _originName),
    ),
  );

  newMarkers.add(
    Marker(
      markerId: const MarkerId('destination_v2'),
      position: LatLng(_destLat, _destLng),
      icon: _destIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      anchor: const Offset(0.5, 0.7),
      infoWindow: InfoWindow(title: 'Destino', snippet: _destName),
    ),
  );

  // Agregar marcadores de incidencias del cluster manager
  newMarkers.addAll(_clusterManager.getClusteredMarkers());

  setState(() {
    _markers.clear();
    _markers.addAll(newMarkers);
  });
}

  /// Procesa las incidencias cargadas: genera íconos personalizados
  /// y los agrega al cluster manager.
  /// 
  /// Los iconos se generan con alta resolución (pixelRatio 3.0) para
  /// mejorar la calidad visual en las rutas.
  Future<void> _handleIncidencesLoaded(
    List<SectorIncidenceEntity> incidences,
  ) async {
    // Recrear el cluster manager para limpiar markers anteriores
    _clusterManager = _buildClusterManager();

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
        ),
      );
    }

    await _updateClusters();
  }

  /// Actualiza los clusters según el nivel de zoom actual.
  Future<void> _updateClusters() async {
    await _clusterManager.updateClusters(zoomLevel: _currentZoom);
    if (mounted) {
      _setupMarkers(); // Refrescar marcadores
    }
  }

  /// Carga las incidencias del sector visible en el mapa.
  Future<void> _fetchSectorIncidences() async {
    if (_mapController == null) return;

    try {
      final bounds = await _mapController!.getVisibleRegion();
      
      if (!mounted) return;
      context.read<map_bloc.MapBloc>().add(
        map_bloc.FetchSectorIncidencesEvent(
          northEastLat: bounds.northeast.latitude,
          northEastLng: bounds.northeast.longitude,
          southWestLat: bounds.southwest.latitude,
          southWestLng: bounds.southwest.longitude,
        ),
      );
    } catch (e) {
      debugPrint('Error fetching sector incidences: $e');
    }
  }

  /// Actualiza el origen y recalcula la ruta.
  void _onOriginSelected(String name, double lat, double lng) {
    setState(() {
      _originLat = lat;
      _originLng = lng;
      _originName = name;
      _polylines.clear();
      _setupMarkers();
    });

    context.read<RouteBloc>().add(
      GetAlternativeRouteEvent(
        originLat: _originLat,
        originLng: _originLng,
        destLat: _destLat,
        destLng: _destLng,
      ),
    );
  }

  /// Abre el selector de ubicación de origen.
  void _showOriginSelector() {
    OriginLocationSheet.show(
      context,
      onOriginSelected: _onOriginSelected,
      title: 'Seleccionar origen',
    );
  }

  /// Actualiza el destino y recalcula la ruta.
  void _onDestSelected(String name, double lat, double lng) {
    setState(() {
      _destLat = lat;
      _destLng = lng;
      _destName = name;
      _polylines.clear();
      _setupMarkers();
    });

    context.read<RouteBloc>().add(
      GetAlternativeRouteEvent(
        originLat: _originLat,
        originLng: _originLng,
        destLat: _destLat,
        destLng: _destLng,
      ),
    );
  }

  /// Abre el selector de ubicación de destino.
  void _showDestSelector() {
    OriginLocationSheet.show(
      context,
      onOriginSelected: _onDestSelected,
      title: 'Seleccionar destino',
    );
  }

  /// Ajusta la cámara para mostrar toda la ruta
  void _fitRouteBounds() {
    if (_mapController == null) return;

    final bounds = LatLngBounds(
      southwest: LatLng(
        _originLat < _destLat ? _originLat : _destLat,
        _originLng < _destLng ? _originLng : _destLng,
      ),
      northeast: LatLng(
        _originLat > _destLat ? _originLat : _destLat,
        _originLng > _destLng ? _originLng : _destLng,
      ),
    );

    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Mapa con la ruta
          _buildMap(),

          // Widget flotante con origen y destino
          RouteLocationCard(
            originName: _originName,
            destName: _destName,
            onOriginTap: _showOriginSelector,
            onDestTap: _showDestSelector,
          ),

          // Panel inferior con información y botón cancelar
          RouteInfoBottomSheet(
            originName: _originName,
            destName: _destName,
            onCancel: _handleCancel,
          ),
        ],
      ),
    );
  }

  /// Construye el GoogleMap con las rutas y marcadores
  Widget _buildMap() {
    return Positioned.fill(
      child: BlocListener<map_bloc.MapBloc, map_bloc.MapState>(
        listener: (context, mapState) {
          if (mapState is map_bloc.SectorIncidencesLoaded) {
            _handleIncidencesLoaded(mapState.incidences);
          }
        },
        child: BlocConsumer<RouteBloc, RouteState>(
          listener: _handleRouteStateChange,
          builder: (context, state) {
            return GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(widget.destLat, widget.destLng),
                zoom: 14,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
                _fitRouteBounds();
                // Cargar incidencias al crear el mapa
                _fetchSectorIncidences();
              },
              onCameraMove: (position) {
                _currentZoom = position.zoom;
              },
              onCameraIdle: () {
                _updateClusters();
                _fetchSectorIncidences();
              },
              polylines: _polylines,
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
            );
          },
        ),
      ),
    );
  }

  /// Maneja los cambios de estado de la ruta
  void _handleRouteStateChange(BuildContext context, RouteState state) {
    if (state is RouteLoaded && state.alternativeRoute != null) {
      _updatePolylines(state);
      _scheduleRouteFit();
    } else if (state is RouteError) {
      _showErrorSnackBar(context, state.message);
    }
  }

  /// Actualiza las polylines con la ruta recibida
  void _updatePolylines(RouteLoaded state) {
    setState(() {
      _polylines.clear();
      _polylines.add(
        PolylineDecoder.createPolyline(
          polylineId: 'secure_route',
          encodedPolyline: state.alternativeRoute!.encodedPolyline,
          color: const Color(0xFF7878FF), // Color más claro para diferenciarlo del icono de origen
          width: 8,
          isHere: false,
          zIndex: 1,
        ),
      );
    });
  }

  /// Programa el ajuste de la cámara después del frame actual
  void _scheduleRouteFit() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fitRouteBounds();
    });
  }

  /// Muestra un mensaje de error
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  /// Maneja el evento de cancelar
  void _handleCancel() {
    context.read<RouteBloc>().add(ClearRoutesEvent());
    Navigator.of(context).pop();
  }
}
