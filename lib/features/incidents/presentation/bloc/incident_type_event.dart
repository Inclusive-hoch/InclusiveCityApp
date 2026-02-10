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
