part of 'spot_bloc.dart';

/// Clase base para todos los estados del SpotBloc.
abstract class SpotState extends Equatable {
  const SpotState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial del bloc.
class SpotInitial extends SpotState {}

/// Estado de carga cuando se está procesando una operación.
class SpotLoading extends SpotState {}

/// Estado cuando se ha creado un spot exitosamente.
class SpotCreated extends SpotState {
  final Spot spot;

  const SpotCreated({required this.spot});

  @override
  List<Object?> get props => [spot];
}

/// Estado cuando se han cargado los spots del usuario.
class SpotsLoaded extends SpotState {
  final List<Spot> spots;

  const SpotsLoaded({required this.spots});

  @override
  List<Object?> get props => [spots];
}

/// Estado de error con un mensaje descriptivo.
class SpotError extends SpotState {
  final String message;

  const SpotError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Estado cuando se ha eliminado un spot exitosamente.
class SpotDeleted extends SpotState {}

/// Estado cuando se ha creado una lista personalizada.
class CustomSpotCreated extends SpotState {
  final CustomSpot customSpot;

  const CustomSpotCreated({required this.customSpot});

  @override
  List<Object?> get props => [customSpot];
}

/// Estado cuando se han cargado las listas personalizadas.
class CustomSpotsLoaded extends SpotState {
  final List<CustomSpot> customSpots;

  const CustomSpotsLoaded({required this.customSpots});

  @override
  List<Object?> get props => [customSpots];
}

/// Estado cuando se ha agregado un spot a una lista.
class SpotAddedToList extends SpotState {
  final CustomSpot updatedList;

  const SpotAddedToList({required this.updatedList});

  @override
  List<Object?> get props => [updatedList];
}

/// Estado cuando se ha eliminado una lista personalizada.
class CustomSpotListDeleted extends SpotState {
  final int deletedCount;

  const CustomSpotListDeleted({required this.deletedCount});

  @override
  List<Object?> get props => [deletedCount];
}

/// Estado cuando se ha eliminado un spot de una lista.
class SpotDeletedFromList extends SpotState {
  final int deletedCount;

  const SpotDeletedFromList({required this.deletedCount});

  @override
  List<Object?> get props => [deletedCount];
}
