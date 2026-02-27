import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:inclusive_app/features/incidents/domain/entities/sector_incidence_entity.dart';
import 'package:inclusive_app/features/incidents/domain/usecases/get_sector_incidences.dart';

part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final GetSectorIncidences getSectorIncidences;

  MapBloc({required this.getSectorIncidences}) : super(MapInitial()) {
    on<GetUserLocationEvent>(_onGetUserLocation);
    on<FetchSectorIncidencesEvent>(_onFetchSectorIncidences);
    on<ClearSectorIncidencesEvent>(_onClearSectorIncidences);
  }

  /// Maneja el evento de obtención de ubicación del usuario
  Future<void> _onGetUserLocation(
    GetUserLocationEvent event,
    Emitter<MapState> emit,
  ) async {
    emit(MapLoading());

    try {
      final errorMessage = await _validateLocationPermissions();
      if (errorMessage != null) {
        return emit(MapError(errorMessage));
      }

      final position = await _getCurrentPosition();
      emit(MapLocationLoaded(position.latitude, position.longitude));
    } catch (e) {
      emit(MapError('Error inesperado: ${e.toString()}'));
    }
  }

  /// Maneja el evento de obtención de incidencias por sector.
  Future<void> _onFetchSectorIncidences(
    FetchSectorIncidencesEvent event,
    Emitter<MapState> emit,
  ) async {
    try {
      final incidences = await getSectorIncidences(
        northEastLat: event.northEastLat,
        northEastLng: event.northEastLng,
        southWestLat: event.southWestLat,
        southWestLng: event.southWestLng,
      );
      emit(SectorIncidencesLoaded(incidences));
    } catch (e) {
      emit(MapError('Error al cargar incidencias: ${e.toString()}'));
    }
  }

  /// Limpia las incidencias del mapa cuando el zoom baja del umbral.
  void _onClearSectorIncidences(
    ClearSectorIncidencesEvent event,
    Emitter<MapState> emit,
  ) {
    emit(SectorIncidencesCleared());
  }

  /// Obtiene la posición actual del dispositivo
  Future<Position> _getCurrentPosition() async {
    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
    );

    return await Geolocator.getCurrentPosition(
      locationSettings: locationSettings,
    );
  }

  /// Valida que los servicios de ubicación estén activos y los permisos concedidos
  Future<String?> _validateLocationPermissions() async {
    final serviceError = await _checkLocationService();
    if (serviceError != null) return serviceError;

    final permissionError = await _checkAndRequestPermission();
    if (permissionError != null) return permissionError;

    return null;
  }

  /// Verifica si el servicio de ubicación está habilitado
  Future<String?> _checkLocationService() async {
    final isEnabled = await Geolocator.isLocationServiceEnabled();

    if (!isEnabled) {
      return 'El GPS está desactivado. Actívalo en Configuración.';
    }

    return null;
  }

  /// Verifica y solicita los permisos de ubicación necesarios
  Future<String?> _checkAndRequestPermission() async {
    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.deniedForever) {
      return 'InclusiveCity no tiene acceso a tu ubicación. '
          'Activa el acceso desde Configuración del sistema.';
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return 'Permiso de ubicación denegado. '
            'La app necesita tu ubicación para funcionar.';
      }
    }

    return null;
  }
}
