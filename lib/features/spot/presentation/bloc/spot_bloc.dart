import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inclusive_app/core/errors/exceptions.dart';
import 'package:inclusive_app/features/spot/domain/entities/custom_spot.dart';
import 'package:inclusive_app/features/spot/domain/entities/spot.dart';
import 'package:inclusive_app/features/spot/domain/usecases/add_spot_to_list.dart';
import 'package:inclusive_app/features/spot/domain/usecases/create_custom_spot.dart';
import 'package:inclusive_app/features/spot/domain/usecases/delete_custom_spot_list.dart';
import 'package:inclusive_app/features/spot/domain/usecases/delete_spot.dart';
import 'package:inclusive_app/features/spot/domain/usecases/delete_spot_from_list.dart';
import 'package:inclusive_app/features/spot/domain/usecases/get_custom_spots.dart';
import 'package:inclusive_app/features/spot/domain/usecases/get_user_spots.dart';
import 'package:inclusive_app/features/spot/domain/usecases/save_spot.dart';

part 'spot_event.dart';
part 'spot_state.dart';

/// BLoC para gestionar spots del usuario.
/// 
/// Usa use cases del dominio para mantener separación de responsabilidades
/// según Clean Architecture.
class SpotBloc extends Bloc<SpotEvent, SpotState> {
  final SaveSpot saveSpot;
  final GetUserSpots getUserSpots;
  final DeleteSpot deleteSpot;
  final CreateCustomSpot createCustomSpot;
  final GetCustomSpots getCustomSpots;
  final AddSpotToList addSpotToList;
  final DeleteCustomSpotList deleteCustomSpotList;
  final DeleteSpotFromList deleteSpotFromList;

  SpotBloc({
    required this.saveSpot,
    required this.getUserSpots,
    required this.deleteSpot,
    required this.createCustomSpot,
    required this.getCustomSpots,
    required this.addSpotToList,
    required this.deleteCustomSpotList,
    required this.deleteSpotFromList,
  }) : super(SpotInitial()) {
    on<CreateSpotEvent>(_onCreateSpot);
    on<LoadUserSpotsEvent>(_onLoadUserSpots);
    on<DeleteSpotEvent>(_onDeleteSpot);
    on<CreateCustomSpotEvent>(_onCreateCustomSpot);
    on<LoadCustomSpotsEvent>(_onLoadCustomSpots);
    on<AddSpotToListEvent>(_onAddSpotToList);
    on<DeleteCustomSpotListEvent>(_onDeleteCustomSpotList);
    on<DeleteSpotFromListEvent>(_onDeleteSpotFromList);
  }

  /// Maneja la creación de un nuevo spot.
  Future<void> _onCreateSpot(
    CreateSpotEvent event,
    Emitter<SpotState> emit,
  ) async {
    emit(SpotLoading());
    debugPrint('🔵 [SpotBloc] Creando spot: ${event.spot.spotName}');

    try {
      final spot = await saveSpot(event.spot);
      debugPrint('✅ [SpotBloc] Spot creado exitosamente');
      emit(SpotCreated(spot: spot));
    } on ConflictException catch (e) {
      debugPrint('⚠️ [SpotBloc] ConflictException: ${e.message}');
      emit(SpotError(message: e.message));
    } on ServerException catch (e) {
      debugPrint('❌ [SpotBloc] ServerException: ${e.message}');
      emit(SpotError(message: 'Error del servidor: ${e.message}'));
    } on NetworkException catch (e) {
      debugPrint('❌ [SpotBloc] NetworkException: ${e.message}');
      emit(SpotError(message: 'Sin conexión: ${e.message}'));
    } catch (e) {
      debugPrint('❌ [SpotBloc] Error inesperado al crear spot: $e');
      emit(SpotError(message: 'Error desconocido: ${e.toString()}'));
    }
  }

  /// Maneja la carga de los spots del usuario.
  Future<void> _onLoadUserSpots(
    LoadUserSpotsEvent event,
    Emitter<SpotState> emit,
  ) async {
    emit(SpotLoading());

    try {
      final spots = await getUserSpots(event.userId);
      debugPrint('✅ [SpotBloc] ${spots.length} spots cargados');
      emit(SpotsLoaded(spots: spots));
    } on ServerException catch (e) {
      debugPrint('❌ [SpotBloc] Error al cargar spots: ${e.message}');
      emit(SpotError(message: 'Error al cargar spots: ${e.message}'));
    } on NetworkException catch (e) {
      emit(SpotError(message: 'Sin conexión: ${e.message}'));
    } catch (e) {
      debugPrint('❌ [SpotBloc] Error inesperado al cargar spots: $e');
      emit(SpotError(message: 'Error al cargar spots: ${e.toString()}'));
    }
  }

  /// Maneja la eliminación de un spot.
  Future<void> _onDeleteSpot(
    DeleteSpotEvent event,
    Emitter<SpotState> emit,
  ) async {
    emit(SpotLoading());

    try {
      await deleteSpot(event.latitude, event.longitude);
      emit(SpotDeleted());
    } on ServerException catch (e) {
      debugPrint('❌ [SpotBloc] Error al eliminar spot: ${e.message}');
      emit(SpotError(message: 'Error al eliminar spot: ${e.message}'));
    } on NetworkException catch (e) {
      emit(SpotError(message: 'Sin conexión: ${e.message}'));
    } catch (e) {
      debugPrint('❌ [SpotBloc] Error inesperado al eliminar: $e');
      emit(SpotError(message: 'Error al eliminar: ${e.toString()}'));
    }
  }

  /// Maneja la creación de una lista personalizada.
  Future<void> _onCreateCustomSpot(
    CreateCustomSpotEvent event,
    Emitter<SpotState> emit,
  ) async {
    emit(SpotLoading());
    debugPrint('🔵 [SpotBloc] Creando lista: ${event.customSpot.listName}');

    try {
      final customSpot = await createCustomSpot(event.customSpot);
      debugPrint('✅ [SpotBloc] Lista creada exitosamente');
      emit(CustomSpotCreated(customSpot: customSpot));
    } on ServerException catch (e) {
      debugPrint('❌ [SpotBloc] Error al crear lista: ${e.message}');
      emit(SpotError(message: 'Error al crear lista: ${e.message}'));
    } on NetworkException catch (e) {
      emit(SpotError(message: 'Sin conexión: ${e.message}'));
    } catch (e) {
      debugPrint('❌ [SpotBloc] Error inesperado al crear lista: $e');
      emit(SpotError(message: 'Error al crear lista: ${e.toString()}'));
    }
  }

  /// Maneja la carga de todas las listas personalizadas.
  Future<void> _onLoadCustomSpots(
    LoadCustomSpotsEvent event,
    Emitter<SpotState> emit,
  ) async {
    emit(SpotLoading());

    try {
      final customSpots = await getCustomSpots();
      debugPrint('✅ [SpotBloc] ${customSpots.length} listas cargadas');
      emit(CustomSpotsLoaded(customSpots: customSpots));
    } on ServerException catch (e) {
      debugPrint('❌ [SpotBloc] Error al cargar listas: ${e.message}');
      emit(SpotError(message: 'Error al cargar listas: ${e.message}'));
    } on NetworkException catch (e) {
      emit(SpotError(message: 'Sin conexión: ${e.message}'));
    } catch (e) {
      debugPrint('❌ [SpotBloc] Error inesperado al cargar listas: $e');
      emit(SpotError(message: 'Error al cargar listas: ${e.toString()}'));
    }
  }

  /// Maneja agregar un spot a una lista personalizada.
  Future<void> _onAddSpotToList(
    AddSpotToListEvent event,
    Emitter<SpotState> emit,
  ) async {
    emit(SpotLoading());

    try {
      final updatedList = await addSpotToList(
        event.listName,
        event.spot,
      );
      debugPrint('✅ [SpotBloc] Spot agregado a lista: ${event.listName}');
      emit(SpotAddedToList(updatedList: updatedList));
    } on ConflictException catch (e) {
      debugPrint('⚠️ [SpotBloc] ConflictException: ${e.message}');
      emit(SpotError(message: e.message));
    } on ServerException catch (e) {
      debugPrint('❌ [SpotBloc] Error al agregar spot: ${e.message}');
      emit(SpotError(message: 'Error del servidor: ${e.message}'));
    } on NetworkException catch (e) {
      emit(SpotError(message: 'Sin conexión: ${e.message}'));
    } catch (e) {
      debugPrint('❌ [SpotBloc] Error inesperado al agregar spot: $e');
      emit(SpotError(message: 'Error al agregar lugar: ${e.toString()}'));
    }
  }

  /// Maneja la eliminación de una lista personalizada.
  Future<void> _onDeleteCustomSpotList(
    DeleteCustomSpotListEvent event,
    Emitter<SpotState> emit,
  ) async {
    emit(SpotLoading());

    try {
      final deletedCount = await deleteCustomSpotList(event.listName);
      emit(CustomSpotListDeleted(deletedCount: deletedCount));
    } on ServerException catch (e) {
      debugPrint('❌ [SpotBloc] Error al eliminar lista: ${e.message}');
      emit(SpotError(message: 'Error al eliminar lista: ${e.message}'));
    } on NetworkException catch (e) {
      emit(SpotError(message: 'Sin conexión: ${e.message}'));
    } catch (e) {
      debugPrint('❌ [SpotBloc] Error inesperado al eliminar lista: $e');
      emit(SpotError(message: 'Error al eliminar lista: ${e.toString()}'));
    }
  }

  /// Maneja la eliminación de un spot de una lista personalizada.
  Future<void> _onDeleteSpotFromList(
    DeleteSpotFromListEvent event,
    Emitter<SpotState> emit,
  ) async {
    emit(SpotLoading());

    try {
      final deletedCount = await deleteSpotFromList(
        event.listName,
        event.latitude,
        event.longitude,
      );
      emit(SpotDeletedFromList(deletedCount: deletedCount));
    } on ServerException catch (e) {
      debugPrint('❌ [SpotBloc] Error al eliminar spot de lista: ${e.message}');
      emit(SpotError(message: 'Error al eliminar spot de lista: ${e.message}'));
    } on NetworkException catch (e) {
      emit(SpotError(message: 'Sin conexión: ${e.message}'));
    } catch (e) {
      debugPrint('❌ [SpotBloc] Error inesperado al eliminar: $e');
      emit(SpotError(message: 'Error al eliminar: ${e.toString()}'));
    }
  }
}