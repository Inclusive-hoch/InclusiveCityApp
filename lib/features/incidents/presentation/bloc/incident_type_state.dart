import 'package:equatable/equatable.dart';

/// Los pasos del flujo de registro de incidencia.
enum IncidentStep { selectingType, selectingSubType, photoPrompt }

class IncidentTypeState extends Equatable {
  final String? selectedType;
  final String? selectedSubType;
  final String? temporaryType;
  final String? temporarySubType;
  final String? photoPath;
  final IncidentStep currentStep;

  const IncidentTypeState({
    this.selectedType,
    this.selectedSubType,
    this.temporaryType,
    this.temporarySubType,
    this.photoPath,
    this.currentStep = IncidentStep.selectingType,
  });

  bool get hasType => selectedType != null;
  bool get hasSubType => selectedSubType != null;
  bool get hasTemporaryType => temporaryType != null;
  bool get hasTemporarySubType => temporarySubType != null;

  IncidentTypeState copyWith({
    String? selectedType,
    String? selectedSubType,
    String? temporaryType,
    String? temporarySubType,
    String? photoPath,
    IncidentStep? currentStep,
    bool clearTemporaryType = false,
    bool clearTemporarySubType = false,
    bool clearPhoto = false,
  }) {
    return IncidentTypeState(
      selectedType: selectedType ?? this.selectedType,
      selectedSubType: selectedSubType ?? this.selectedSubType,
      temporaryType: clearTemporaryType
          ? null
          : (temporaryType ?? this.temporaryType),
      temporarySubType: clearTemporarySubType
          ? null
          : (temporarySubType ?? this.temporarySubType),
      photoPath: clearPhoto ? null : (photoPath ?? this.photoPath),
      currentStep: currentStep ?? this.currentStep,
    );
  }

  factory IncidentTypeState.initial() => const IncidentTypeState();

  @override
  List<Object?> get props => [
    selectedType,
    selectedSubType,
    temporaryType,
    temporarySubType,
    photoPath,
    currentStep,
  ];
}
