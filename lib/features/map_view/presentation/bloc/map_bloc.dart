import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc() : super(MapInitial()) {
    on<GetUserLocationEvent>(_onGetUserLocation);
  }

  /// Maneja el evento de obtención de ubicación del usuario
  /// Valida permisos, obtiene la posición GPS actual y emite el estado correspondiente:
  ///  - [MapLoading] mientras procesa
  ///  - [MapLocationLoaded] si obtiene la ubicación exitosamente
  ///  - [MapError] si hay algún error o falta de permisos
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

  
  /// Obtiene la posición actual del dispositivo
  Future<Position> _getCurrentPosition() async {
    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high
    );

    return await Geolocator.getCurrentPosition(
      locationSettings: locationSettings
    );
  }

  /// Valida que los servicios de ubicación estén activos y los permisos concedidos
  /// Retorna:
  ///  - `null` si todo está correcto
  ///  - Un mensaje de error específico si hay algún problema
  Future<String?> _validateLocationPermissions() async {
    final serviceError = await _checkLocationService();
    if (serviceError != null) return serviceError;

    final permissionError = await _checkAndRequestPermission();
    if (permissionError != null) return permissionError;

    return null;
  }

  
  ///  Verifica si el servicio de ubicación está habilitado
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
