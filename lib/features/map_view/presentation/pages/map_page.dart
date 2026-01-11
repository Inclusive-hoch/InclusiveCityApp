import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inclusive_app/features/map_view/presentation/bloc/map_bloc.dart';
import 'package:inclusive_app/shared/widgets/custom_floating_action_button.dart';
import 'package:inclusive_app/features/map_view/presentation/controller/map_page_controller.dart';
import 'package:inclusive_app/features/places/presentation/screen/search_page.dart';

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
    context.read<MapBloc>().add(GetUserLocationEvent());
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
          BlocListener<MapBloc, MapState>(
            listener: (context, state) {
              if (state is MapLocationLoaded) {
                _mapController?.animateCamera(
                  CameraUpdate.newLatLngZoom(
                    LatLng(state.latitude, state.longitude),
                    _userLocationZoom,
                  ),
                );
              }
              if (state is MapError) {
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

          Positioned(
            top: 48,
            left: 16,
            child: CustomFloatingActionButton.square(
              icon: Icons.menu,
              onPressed: () => log('Abrir menu'),
            ),
          ),

          Positioned(
            bottom: 30,
            left: 20,
            child: CustomFloatingActionButton.primary(
              icon: Icons.navigation,
              onPressed: () {
                _controller.startCentering();
                context.read<MapBloc>().add(GetUserLocationEvent());
              },
            ),
          ),

          ValueListenableBuilder<bool>(
            valueListenable: _controller.isCenteredOnUser,
            builder: (context, isCentered, _) {
              if (!isCentered) return const SizedBox.shrink();

              return Positioned(
                bottom: 30,
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
                0.2, // Empieza ocupando el 20% de la pantalla (abajo)
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
}
