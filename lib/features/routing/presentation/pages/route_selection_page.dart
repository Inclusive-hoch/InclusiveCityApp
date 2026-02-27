import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inclusive_app/core/theme/app_color.dart';
import 'package:inclusive_app/core/utils/polyline_decoder.dart';
import 'package:inclusive_app/features/routing/presentation/bloc/route_bloc.dart';
import 'package:inclusive_app/features/routing/presentation/widgets/origin_location_sheet.dart';
import 'package:inclusive_app/features/routing/presentation/widgets/route_location_card.dart';
import 'package:inclusive_app/features/routing/presentation/widgets/route_info_bottom_sheet.dart';
import 'package:inclusive_app/core/utils/bitmap_descriptor.dart'
    as bitmap_utils;

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
  bool _iconsLoaded = false;

  // Estado mutable para el origen y destino (pueden cambiar si el usuario los edita)
  late double _originLat;
  late double _originLng;
  late String _originName;

  late double _destLat;
  late double _destLng;
  late String _destName;

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

  /// Carga los iconos personalizados desde los assets SVG
  Future<void> _loadCustomIcons() async {
  try {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Tamaño para el icono de origen (cuadrado 33x33)
      const double originSize = 33.0; 

      final origin = await bitmap_utils.bitmapDescriptorFromSvgAsset(
        'assets/routeLogo/inicio_ruta.svg',
        const Size(originSize, originSize),
      );
      
      // Tamaño para el icono de destino respetando su aspect ratio original (25:32)
      // El SVG original es 25x32, mantenemos esa proporción
      final dest = await bitmap_utils.bitmapDescriptorFromSvgAsset(
        'assets/routeLogo/llegada_logo.svg',
        const Size(25, 32),
      );
      
      if (mounted) {
        setState(() {
          _originIcon = origin;
          _destIcon = dest;
          _iconsLoaded = true;
          _setupMarkers(); // Refrescamos los marcadores
        });
      }
    });
  } catch (e) {
    debugPrint('Error cargando iconos: $e');
  }
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

  setState(() {
    _markers.clear();
    _markers.addAll(newMarkers);
  });
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
            },
            polylines: _polylines,
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          );
        },
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
