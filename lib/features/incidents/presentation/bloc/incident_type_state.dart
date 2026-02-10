import 'package:equatable/equatable.dart';

class IncidentTypeState extends Equatable {
  final String? selectedType;
  final String? selectedSubType;
  final String? temporaryType;
  final String? temporarySubType;

  const IncidentTypeState({
    this.selectedType,
    this.selectedSubType,
    this.temporaryType,
    this.temporarySubType,
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
    bool clearTemporaryType = false,
    bool clearTemporarySubType = false,
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
    );
  }

  factory IncidentTypeState.initial() => const IncidentTypeState();

  @override
  List<Object?> get props => [
    selectedType,
    selectedSubType,
    temporaryType,
    temporarySubType,
  ];
}
