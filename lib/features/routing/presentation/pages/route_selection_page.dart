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
    _markers.add(
      Marker(
        markerId: const MarkerId('origin'),
        position: LatLng(widget.originLat, widget.originLng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: InfoWindow(title: widget.originName),
      ),
    );
    
    _markers.add(
      Marker(
        markerId: const MarkerId('destination'),
        position: LatLng(widget.destLat, widget.destLng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(title: widget.destName),
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
                      width: 6,
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
          
          // Panel superior con origen y destino
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Fila de origen
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.originName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      
                      // Línea vertical
                      Padding(
                        padding: const EdgeInsets.only(left: 5.5, top: 4, bottom: 4),
                        child: Container(
                          width: 1,
                          height: 20,
                          color: Colors.grey.shade300,
                        ),
                      ),
                      
                      // Fila de destino
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.destName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Información de la ruta
                          if (state is RouteLoaded && state.mainRoute != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Row(
                                children: [
                                  // Duración
                                  Text(
                                    state.mainRoute!.formattedDuration,
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: AppColor.neutralDarkNormal,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  
                                  // Distancia
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        state.mainRoute!.formattedDistance,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppColor.neutralDarkNormal,
                                        ),
                                      ),
                                      const Text(
                                        'Mejor ruta, menos incidencias',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColor.neutralDarkLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  const Spacer(),
                                  
                                  // Icono de navegación
                                  Icon(
                                    Icons.navigation,
                                    color: AppColor.primaryNormal,
                                    size: 28,
                                  ),
                                ],
                              ),
                            ),
                          
                          // Indicador de carga
                          if (state is RouteLoading)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 16.0),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          
                          // Botón Cancelar
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
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Cancelar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
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
