part of 'place_bloc.dart';

abstract class PlacesState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PlacesInitial extends PlacesState {}

class PlacesLoading extends PlacesState {}

class PlacesLoaded extends PlacesState {
  final List<PlaceSuggestion> suggestions;

  PlacesLoaded(this.suggestions);

  @override
  List<Object> get props => [suggestions];
}

class PlacesEmpty extends PlacesState {}

class PlacesError extends PlacesState {
  final String message;

  PlacesError(this.message);

  @override
  List<Object> get props => [message];
}

class PlaceDetailsLoading extends PlacesState {}

class PlaceDetailsLoaded extends PlacesState {
  final PlaceDetails placeDetails;

  PlaceDetailsLoaded(this.placeDetails);

  @override
  List<Object> get props => [placeDetails];
}

class UserLocationLoaded extends PlacesState {
  final double latitude;
  final double longitude;

  UserLocationLoaded(this.latitude, this.longitude);

  @override
  List<Object> get props => [latitude, longitude];
}

class NearbyPlacesLoaded extends PlacesState {
  final List<PlaceDetails> places;

  NearbyPlacesLoaded(this.places);

  @override
  List<Object> get props => [places];
}

class SearchHistoryLoaded extends PlacesState {
  final List<PlaceSuggestion> history;

  SearchHistoryLoaded(this.history);

  @override
  List<Object> get props => [history];
}