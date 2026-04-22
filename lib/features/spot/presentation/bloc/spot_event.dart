part of 'spot_bloc.dart';

/// Clase base para todos los eventos del SpotBloc.
abstract class SpotEvent extends Equatable {
  const SpotEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para crear un nuevo spot.
class CreateSpotEvent extends SpotEvent {
  final Spot spot;

  const CreateSpotEvent({required this.spot});

  @override
  List<Object?> get props => [spot];
}

/// Evento para cargar los spots del usuario.
class LoadUserSpotsEvent extends SpotEvent {
  final String userId;

  const LoadUserSpotsEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Evento para eliminar un spot.
class DeleteSpotEvent extends SpotEvent {
  final double latitude;
  final double longitude;

  const DeleteSpotEvent({
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [latitude, longitude];
}

/// Evento para crear una lista personalizada de spots.
class CreateCustomSpotEvent extends SpotEvent {
  final CustomSpot customSpot;

  const CreateCustomSpotEvent({required this.customSpot});

  @override
  List<Object?> get props => [customSpot];
}

/// Evento para cargar todas las listas personalizadas.
class LoadCustomSpotsEvent extends SpotEvent {
  const LoadCustomSpotsEvent();
}

/// Evento para agregar un spot a una lista personalizada.
class AddSpotToListEvent extends SpotEvent {
  final String listName;
  final Spot spot;

  const AddSpotToListEvent({
    required this.listName,
    required this.spot,
  });

  @override
  List<Object?> get props => [listName, spot];
}

/// Evento para eliminar una lista personalizada completa.
class DeleteCustomSpotListEvent extends SpotEvent {
  final String listName;

  const DeleteCustomSpotListEvent({required this.listName});

  @override
  List<Object?> get props => [listName];
}

/// Evento para eliminar un spot de una lista personalizada.
class DeleteSpotFromListEvent extends SpotEvent {
  final String listName;
  final double latitude;
  final double longitude;

  const DeleteSpotFromListEvent({
    required this.listName,
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [listName, latitude, longitude];
}

/// Evento para obtener los detalles de Google Places de un spot
/// (foto, rating, medallas) sin interferir con el PlaceBloc global.
class FetchSpotPlaceDetailsEvent extends SpotEvent {
  final String placeId;

  const FetchSpotPlaceDetailsEvent(this.placeId);

  @override
  List<Object?> get props => [placeId];
}
