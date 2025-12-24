import 'package:equatable/equatable.dart';
import 'package:inclusivecity_frontend/features/map/domain/entities/spot_entity.dart';

// ========== EVENTS ==========
abstract class SpotsEvent extends Equatable {
  const SpotsEvent();

  @override
  List<Object?> get props => [];
}

class SaveSpotEvent extends SpotsEvent {
  final SpotEntity spot;

  const SaveSpotEvent(this.spot);

  @override
  List<Object?> get props => [spot];
}

class LoadUserSpotsEvent extends SpotsEvent {
  final String userId;

  const LoadUserSpotsEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

// ========== STATES ==========
abstract class SpotsState extends Equatable {
  const SpotsState();

  @override
  List<Object?> get props => [];
}

class SpotsInitial extends SpotsState {}

class SpotsLoading extends SpotsState {}

class SpotSaved extends SpotsState {
  final SpotEntity spot;

  const SpotSaved(this.spot);

  @override
  List<Object?> get props => [spot];
}

class SpotsLoaded extends SpotsState {
  final List<SpotEntity> spots;

  const SpotsLoaded(this.spots);

  @override
  List<Object?> get props => [spots];
}

class SpotsError extends SpotsState {
  final String message;

  const SpotsError(this.message);

  @override
  List<Object?> get props => [message];
}
