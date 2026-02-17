import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inclusive_app/core/theme/app_color.dart';
import 'package:inclusive_app/core/utils/polyline_decoder.dart';
import 'package:inclusive_app/features/routing/presentation/bloc/route_bloc.dart';
import 'package:inclusive_app/features/routing/presentation/widgets/route_info_card.dart';

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

  @override
  void initState() {
    super.initState();
    
    // Generar la ruta al iniciar la pantalla
    context.read<RouteBloc>().add(
      GetMainRouteEvent(
        originLat: widget.originLat,
        originLng: widget.originLng,
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
    // Marcador de origen - círculo azul
    _markers.add(
      Marker(
        markerId: const MarkerId('origin'),
        position: LatLng(widget.originLat, widget.originLng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: InfoWindow(
          title: 'Mi ubicación', 
          snippet: widget.originName,
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

  /// Ajusta la cámara para mostrar toda la ruta
  void _fitRouteBounds() {
    if (_mapController == null) return;
    
    final bounds = LatLngBounds(
      southwest: LatLng(
        widget.originLat < widget.destLat ? widget.originLat : widget.destLat,
        widget.originLng < widget.destLng ? widget.originLng : widget.destLng,
      ),
      northeast: LatLng(
        widget.originLat > widget.destLat ? widget.originLat : widget.destLat,
        widget.originLng > widget.destLng ? widget.originLng : widget.destLng,
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
                if (state is RouteLoaded && state.mainRoute != null) {
                  setState(() {
                    _polylines.clear();
                    
                    final polyline = PolylineDecoder.createPolyline(
                      polylineId: 'main_route',
                      encodedPolyline: state.mainRoute!.encodedPolyline,
                      color: AppColor.primaryNormal,
                      width: 8,
                      isHere: false,
                    );
                    
                    _polylines.add(polyline);
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
                        // Campo de texto separado
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300, width: 1),
                            ),
                            child: Text(
                              widget.originName,
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
                        // Campo de texto separado
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
                          if (state is RouteLoaded && state.mainRoute != null) ...[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Duración con mejor contraste
                                  Text(
                                    state.mainRoute!.formattedDuration,
                                    style: const TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.black87,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  
                                  // Información de distancia y ruta
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          state.mainRoute!.formattedDistance,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Por ${widget.originName.split(',').first}, ${widget.destName.split(',').first}',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black54,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        const Text(
                                          'Mejor ruta, menos incidencias',
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
