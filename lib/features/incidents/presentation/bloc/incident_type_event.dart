import 'package:equatable/equatable.dart';

abstract class IncidentTypeEvent extends Equatable {
  const IncidentTypeEvent();

  @override
  List<Object?> get props => [];
}

class IncidentTypeTemporarilySelected extends IncidentTypeEvent {
  final String type;

  const IncidentTypeTemporarilySelected(this.type);

  @override
  List<Object?> get props => [type];
}

class IncidentSubTypeTemporarilySelected extends IncidentTypeEvent {
  final String subType;

  const IncidentSubTypeTemporarilySelected(this.subType);

  @override
  List<Object?> get props => [subType];
}

class IncidentTypeConfirmed extends IncidentTypeEvent {}

class IncidentSubTypeConfirmed extends IncidentTypeEvent {}

class IncidentTypeGoBack extends IncidentTypeEvent {}

class IncidentTypeReset extends IncidentTypeEvent {}

/// El usuario quiere tomar una foto → abre cámara.
class IncidentPhotoRequested extends IncidentTypeEvent {}

/// Foto capturada exitosamente.
class IncidentPhotoCaptured extends IncidentTypeEvent {
  final String photoPath;

  const IncidentPhotoCaptured(this.photoPath);

  @override
  List<Object?> get props => [photoPath];
}

/// El usuario omite la foto.
class IncidentPhotoSkipped extends IncidentTypeEvent {}

/// Volver del paso de foto al paso de subtipos.
class IncidentPhotoGoBack extends IncidentTypeEvent {}
