import 'package:flutter_bloc/flutter_bloc.dart';
import 'incident_type_event.dart';
import 'incident_type_state.dart';

class IncidentTypeBloc extends Bloc<IncidentTypeEvent, IncidentTypeState> {
  IncidentTypeBloc() : super(IncidentTypeState.initial()) {
    on<IncidentTypeTemporarilySelected>((event, emit) {
      emit(state.copyWith(temporaryType: event.type));
    });

    on<IncidentSubTypeTemporarilySelected>((event, emit) {
      emit(state.copyWith(temporarySubType: event.subType));
    });

    on<IncidentTypeConfirmed>((event, emit) {
      emit(
        state.copyWith(
          selectedType: state.temporaryType,
          selectedSubType: null,
          clearTemporaryType: true,
          clearTemporarySubType: true,
          currentStep: IncidentStep.selectingSubType,
        ),
      );
    });

    on<IncidentSubTypeConfirmed>((event, emit) {
      emit(
        state.copyWith(
          selectedSubType: state.temporarySubType,
          clearTemporarySubType: true,
          currentStep: IncidentStep.photoPrompt,
        ),
      );
    });

    // === Foto ===
    on<IncidentPhotoRequested>((event, emit) {
      // La UI abrirá la cámara al detectar este evento
    });

    on<IncidentPhotoCaptured>((event, emit) {
      emit(state.copyWith(photoPath: event.photoPath));
    });

    on<IncidentPhotoSkipped>((event, emit) {
      // La UI cerrará el modal
    });

    on<IncidentPhotoGoBack>((event, emit) {
      emit(
        state.copyWith(
          clearPhoto: true,
          currentStep: IncidentStep.selectingSubType,
          selectedSubType: null,
        ),
      );
    });

    // === Navegación general ===
    on<IncidentTypeGoBack>((event, emit) {
      emit(IncidentTypeState.initial());
    });

    on<IncidentTypeReset>((event, emit) {
      emit(IncidentTypeState.initial());
    });
  }
}
