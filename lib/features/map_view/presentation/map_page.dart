import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inclusive_app/features/map_view/application/map_bloc.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<StatefulWidget> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _mapController;
  bool _isCenteredOnUser = false;

  static const CameraPosition _defaultPosition = CameraPosition(
    target: LatLng(0, 0),
    zoom: 2,
  );

  @override
void initState() {
  super.initState();
  context.read<MapBloc>().add(GetUserLocationEvent());
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<MapBloc, MapState>(
        listener: (context, state) => {
          if (state is MapLocationLoaded)
            {
              _mapController?.animateCamera(
                CameraUpdate.newLatLngZoom(
                  LatLng(state.latitude, state.longitude),
                  15,
                ),
              ),
            },
          if (state is MapError)
            {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message))),
            },
        },
        child: GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(0, 0),
            zoom: 2,
          ),
          onMapCreated: (controller) => _mapController = controller,
          myLocationEnabled: true,
        ),
      ),
    );
  }
}
