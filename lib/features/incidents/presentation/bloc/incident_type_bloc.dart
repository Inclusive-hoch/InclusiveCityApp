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
        ),
      );
    });

    on<IncidentSubTypeConfirmed>((event, emit) {
      emit(
        state.copyWith(
          selectedSubType: state.temporarySubType,
          clearTemporarySubType: true,
        ),
      );
    });

    on<IncidentTypeGoBack>((event, emit) {
      emit(IncidentTypeState.initial());
    });

    on<IncidentTypeReset>((event, emit) {
      emit(IncidentTypeState.initial());
    });
  }
}
