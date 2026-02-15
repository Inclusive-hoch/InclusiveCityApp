import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inclusive_app/core/errors/exceptions.dart';
import 'package:inclusive_app/features/spot/data/models/spot_model.dart';
import 'package:inclusive_app/features/spot/domain/entities/custom_spot.dart';
import 'package:inclusive_app/features/spot/domain/entities/spot.dart';
import 'package:inclusive_app/features/spot/domain/repositories/spot_repository.dart';

part 'spot_event.dart';
part 'spot_state.dart';

/// BLoC para gestionar la creación y carga de spots del usuario.
class SpotBloc extends Bloc<SpotEvent, SpotState> {
  final SpotRepository repository;

  SpotBloc({
    required this.repository,
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
      final spot = await repository.createSpot(event.spot);
      debugPrint('✅ [SpotBloc] Spot creado exitosamente');
      emit(SpotCreated(spot: spot));
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
      final spots = await repository.getUserSpots(event.userId);
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
      await repository.deleteSpot(event.latitude, event.longitude);
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
      final customSpot = await repository.createCustomSpot(event.customSpot);
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
      final customSpots = await repository.getCustomSpots();
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
      final spotModel = SpotModel.fromEntity(event.spot);
      final updatedList = await repository.addSpotToList(
        event.listName,
        spotModel,
      );
      emit(SpotAddedToList(updatedList: updatedList));
    } on ServerException catch (e) {
      debugPrint('❌ [SpotBloc] Error al agregar spot: ${e.message}');
      emit(SpotError(message: 'Error al agregar spot: ${e.message}'));
    } on NetworkException catch (e) {
      emit(SpotError(message: 'Sin conexión: ${e.message}'));
    } catch (e) {
      debugPrint('❌ [SpotBloc] Error inesperado al agregar spot: $e');
      emit(SpotError(message: 'Error al agregar spot: ${e.toString()}'));
    }
  }

  /// Maneja la eliminación de una lista personalizada.
  Future<void> _onDeleteCustomSpotList(
    DeleteCustomSpotListEvent event,
    Emitter<SpotState> emit,
  ) async {
    emit(SpotLoading());

    try {
      final deletedCount = await repository.deleteCustomSpotList(event.listName);
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
      final deletedCount = await repository.deleteSpotFromList(
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