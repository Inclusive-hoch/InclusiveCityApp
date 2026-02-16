import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inclusive_app/features/routing/domain/entities/route_info.dart';
import 'package:inclusive_app/features/routing/domain/usecases/get_main_route.dart';
import 'package:inclusive_app/features/routing/domain/usecases/get_alternative_route.dart';

part 'route_event.dart';
part 'route_state.dart';

/// BLoC para gestionar el estado de las rutas en el mapa.
/// 
/// Maneja la obtención de rutas principales (Google) y alternativas (HERE),
/// permitiendo visualizar ambas en paralelo en el mapa.
class RouteBloc extends Bloc<RouteEvent, RouteState> {
  final GetMainRoute getMainRoute;
  final GetAlternativeRoute getAlternativeRoute;

  RouteBloc({
    required this.getMainRoute,
    required this.getAlternativeRoute,
  }) : super(RouteInitial()) {
    on<GetMainRouteEvent>(_onGetMainRoute);
    on<GetAlternativeRouteEvent>(_onGetAlternativeRoute);
    on<GetBothRoutesEvent>(_onGetBothRoutes);
    on<ClearRoutesEvent>(_onClearRoutes);
  }

  /// Maneja el evento para obtener solo la ruta principal.
  Future<void> _onGetMainRoute(
    GetMainRouteEvent event,
    Emitter<RouteState> emit,
  ) async {
    emit(RouteLoading());

    try {
      final mainRoute = await getMainRoute(
        originLat: event.originLat,
        originLng: event.originLng,
        destLat: event.destLat,
        destLng: event.destLng,
      );

      emit(RouteLoaded(
        mainRoute: mainRoute,
        alternativeRoute: null,
      ));
    } catch (e) {
      emit(RouteError('Error al obtener ruta principal: ${e.toString()}'));
    }
  }

  /// Maneja el evento para obtener solo la ruta alternativa.
  Future<void> _onGetAlternativeRoute(
    GetAlternativeRouteEvent event,
    Emitter<RouteState> emit,
  ) async {
    // Mantener la ruta principal si existe
    final currentState = state;
    RouteInfo? currentMainRoute;
    
    if (currentState is RouteLoaded) {
      currentMainRoute = currentState.mainRoute;
    }

    emit(RouteLoading());

    try {
      final alternativeRoute = await getAlternativeRoute(
        originLat: event.originLat,
        originLng: event.originLng,
        destLat: event.destLat,
        destLng: event.destLng,
      );

      emit(RouteLoaded(
        mainRoute: currentMainRoute,
        alternativeRoute: alternativeRoute,
      ));
    } catch (e) {
      // Si hay error, restaurar la ruta principal si existía
      if (currentMainRoute != null) {
        emit(RouteLoaded(
          mainRoute: currentMainRoute,
          alternativeRoute: null,
        ));
      } else {
        emit(RouteError('Error al obtener ruta alternativa: ${e.toString()}'));
      }
    }
  }

  /// Maneja el evento para obtener ambas rutas en paralelo.
  Future<void> _onGetBothRoutes(
    GetBothRoutesEvent event,
    Emitter<RouteState> emit,
  ) async {
    emit(RouteLoading());

    try {
      // Ejecutar ambas peticiones en paralelo
      final results = await Future.wait([
        getMainRoute(
          originLat: event.originLat,
          originLng: event.originLng,
          destLat: event.destLat,
          destLng: event.destLng,
        ),
        getAlternativeRoute(
          originLat: event.originLat,
          originLng: event.originLng,
          destLat: event.destLat,
          destLng: event.destLng,
        ),
      ]);

      emit(RouteLoaded(
        mainRoute: results[0],
        alternativeRoute: results[1],
      ));
    } catch (e) {
      emit(RouteError('Error al obtener rutas: ${e.toString()}'));
    }
  }

  /// Maneja el evento para limpiar las rutas del mapa.
  void _onClearRoutes(
    ClearRoutesEvent event,
    Emitter<RouteState> emit,
  ) {
    emit(RouteInitial());
  }
}
