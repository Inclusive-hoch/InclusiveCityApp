import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inclusive_app/features/routing/domain/entities/route_info.dart';
import 'package:inclusive_app/features/routing/domain/usecases/get_alternative_route.dart';

part 'route_event.dart';
part 'route_state.dart';

/// BLoC para gestionar el estado de la ruta segura en el mapa.
/// 
/// Maneja la obtención de la ruta segura (OpenRouteService),
/// que evita incidencias registradas en el sistema.
class RouteBloc extends Bloc<RouteEvent, RouteState> {
  final GetAlternativeRoute getAlternativeRoute;

  RouteBloc({
    required this.getAlternativeRoute,
  }) : super(RouteInitial()) {
    on<GetAlternativeRouteEvent>(_onGetAlternativeRoute);
    on<ClearRoutesEvent>(_onClearRoutes);
  }

  /// Maneja el evento para obtener la ruta segura.
  Future<void> _onGetAlternativeRoute(
    GetAlternativeRouteEvent event,
    Emitter<RouteState> emit,
  ) async {
    emit(RouteLoading());

    try {
      final alternativeRoute = await getAlternativeRoute(
        originLat: event.originLat,
        originLng: event.originLng,
        destLat: event.destLat,
        destLng: event.destLng,
      );

      emit(RouteLoaded(alternativeRoute: alternativeRoute));
    } catch (e) {
      emit(RouteError('Error al obtener ruta segura: ${e.toString()}'));
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
