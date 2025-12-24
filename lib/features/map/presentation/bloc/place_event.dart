part of 'place_bloc.dart';

abstract class PlacesEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class SearchPlacesEvent extends PlacesEvent {
  final String query;
  SearchPlacesEvent(this.query);
  @override
  List<Object> get props => [query];
}

class ClearSearchEvent extends PlacesEvent {}

class SelectPlaceEvent extends PlacesEvent {
  final String placeId;
  SelectPlaceEvent(this.placeId);
  @override
  List<Object> get props => [placeId];
}

class GetUserLocationEvent extends PlacesEvent {}

class GetNearbyPlacesEvent extends PlacesEvent {
  final double latitude;
  final double longitude;
  GetNearbyPlacesEvent(this.latitude, this.longitude);
  @override
  List<Object> get props => [latitude, longitude];
}

class LoadSearchHistoryEvent extends PlacesEvent {}

class SaveToHistoryEvent extends PlacesEvent {
  final PlaceSuggestion place;
  SaveToHistoryEvent(this.place);
  @override
  List<Object> get props => [place];
}