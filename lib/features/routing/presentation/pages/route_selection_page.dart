import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inclusive_app/core/theme/app_color.dart';
import 'package:inclusive_app/core/utils/polyline_decoder.dart';
import 'package:inclusive_app/features/routing/presentation/bloc/route_bloc.dart';
import 'package:inclusive_app/features/routing/presentation/widgets/origin_location_sheet.dart';

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

  // Estado mutable para el origen (puede cambiar si el usuario lo edita)
  late double _originLat;
  late double _originLng;
  late String _originName;

  @override
  void initState() {
    super.initState();

    // Inicializar origen desde los parámetros del widget
    _originLat = widget.originLat;
    _originLng = widget.originLng;
    _originName = widget.originName;
    
    // Obtener la ruta segura al iniciar la pantalla (evita incidencias)
    context.read<RouteBloc>().add(
      GetAlternativeRouteEvent(
        originLat: _originLat,
        originLng: _originLng,
        destLat: widget.destLat,
        destLng: widget.destLng,
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

  /// Configura los marcadores de origen y destino en el mapa
  void _setupMarkers() {
    _markers.clear();

    // Marcador de origen - círculo azul
    _markers.add(
      Marker(
        markerId: const MarkerId('origin'),
        position: LatLng(_originLat, _originLng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: InfoWindow(
          title: 'Origen', 
          snippet: _originName,
        ),
      ),
    );
    
    // Marcador de destino - bandera roja
    _markers.add(
      Marker(
        markerId: const MarkerId('destination'),
        position: LatLng(widget.destLat, widget.destLng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: 'Destino', 
          snippet: widget.destName,
        ),
      ),
    );
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
        destLat: widget.destLat,
        destLng: widget.destLng,
      ),
    );
  }

  /// Abre el selector de ubicación de origen.
  void _showOriginSelector() {
    OriginLocationSheet.show(
      context,
      onOriginSelected: _onOriginSelected,
    );
  }

  /// Ajusta la cámara para mostrar toda la ruta
  void _fitRouteBounds() {
    if (_mapController == null) return;
    
    final bounds = LatLngBounds(
      southwest: LatLng(
        _originLat < widget.destLat ? _originLat : widget.destLat,
        _originLng < widget.destLng ? _originLng : widget.destLng,
      ),
      northeast: LatLng(
        _originLat > widget.destLat ? _originLat : widget.destLat,
        _originLng > widget.destLng ? _originLng : widget.destLng,
      ),
    );
    
    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 100),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Mapa con la ruta
          Positioned.fill(
            child: BlocConsumer<RouteBloc, RouteState>(
              listener: (context, state) {
                if (state is RouteLoaded && state.alternativeRoute != null) {
                  setState(() {
                    _polylines.clear();

                    // Ruta segura (ORS) → evita incidencias
                    _polylines.add(PolylineDecoder.createPolyline(
                      polylineId: 'secure_route',
                      encodedPolyline: state.alternativeRoute!.encodedPolyline,
                      color: AppColor.primaryNormal,
                      width: 8,
                      isHere: false,
                      zIndex: 1,
                    ));
                  });

                  // Ajustar la cámara para mostrar toda la ruta
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _fitRouteBounds();
                  });
                }
                
                if (state is RouteError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
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
                  zoomControlsEnabled: false,
                );
              },
            ),
          ),
          
          // Widget flotante con origen y destino
          Positioned(
            top: 60,
            left: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Fila de origen - icono separado
                    Row(
                      children: [
                        // Icono de origen separado
                        Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: AppColor.primaryNormal,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.my_location,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Campo de texto de origen (tappable)
                        Expanded(
                          child: GestureDetector(
                            onTap: _showOriginSelector,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColor.primaryNormal.withOpacity(0.4), width: 1.5),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _originName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.edit_location_alt_outlined,
                                    size: 18,
                                    color: AppColor.primaryNormal.withOpacity(0.7),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Fila de destino - icono separado
                    Row(
                      children: [
                        // Icono de destino separado
                        Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.place,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Campo de texto de destino
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300, width: 1),
                            ),
                            child: Text(
                              widget.destName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Información de la ruta y botón cancelar en la parte inferior
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BlocBuilder<RouteBloc, RouteState>(
              builder: (context, state) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Información de la ruta - sin icono de flecha
                          // Mostrar info de la ruta segura (HERE) cuando esté disponible
                          if (state is RouteLoaded && state.alternativeRoute != null) ...[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Duración con mejor contraste
                                  Text(
                                    state.alternativeRoute!.formattedDuration,
                                    style: const TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.black87,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(width: 20),

                                  // Información de distancia y ruta segura
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          state.alternativeRoute!.formattedDistance,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Por ${_originName.split(',').first}, ${widget.destName.split(',').first}',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black54,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        const Text(
                                          'Ruta segura, sin incidencias',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          
                          // Indicador de carga
                          if (state is RouteLoading)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 24.0),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          
                          // Botón Cancelar con mejor accesibilidad
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // Limpiar las rutas al cancelar
                                context.read<RouteBloc>().add(ClearRoutesEvent());
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColor.primaryNormal,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 2,
                                shadowColor: AppColor.primaryNormal.withOpacity(0.3),
                              ),
                              child: const Text(
                                'Cancelar',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
