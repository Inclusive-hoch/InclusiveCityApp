import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inclusive_app/features/incidents/domain/usecases/insert_incidence.dart';

class IncidentReportBloc
    extends Bloc<IncidentReportEvent, IncidentReportState> {
  final InsertIncidence insertIncidence;

  IncidentReportBloc({required this.insertIncidence})
    : super(IncidentReportInitial()) {
    on<ReportIncidentRequested>(_onReportIncidentRequested);
  }

  Future<void> _onReportIncidentRequested(
    ReportIncidentRequested event,
    Emitter<IncidentReportState> emit,
  ) async {
    emit(IncidentReportLoading());

    try {
      await insertIncidence(
        placeId: event.placeId,
        latitude: event.latitude,
        longitude: event.longitude,
        incidence: event.incidence,
        image: event.image,
      );

      emit(const IncidentReportSuccess('Incidencia reportada correctamente'));
    } catch (e) {
      if (e is ArgumentError) {
        emit(IncidentReportFailure(e.message.toString()));
        return;
      }

      emit(const IncidentReportFailure('No se pudo crear la incidencia'));
    }
  }
}

abstract class IncidentReportEvent extends Equatable {
  const IncidentReportEvent();

  @override
  List<Object?> get props => [];
}

class ReportIncidentRequested extends IncidentReportEvent {
  final String? placeId;
  final double latitude;
  final double longitude;
  final String incidence;
  final String image;

  const ReportIncidentRequested({
    this.placeId,
    required this.latitude,
    required this.longitude,
    required this.incidence,
    this.image = '',
  });

  @override
  List<Object?> get props => [placeId, latitude, longitude, incidence, image];
}

abstract class IncidentReportState extends Equatable {
  const IncidentReportState();

  @override
  List<Object?> get props => [];
}

class IncidentReportInitial extends IncidentReportState {}

class IncidentReportLoading extends IncidentReportState {}

class IncidentReportSuccess extends IncidentReportState {
  final String message;

  const IncidentReportSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class IncidentReportFailure extends IncidentReportState {
  final String message;

  const IncidentReportFailure(this.message);

  @override
  List<Object?> get props => [message];
}
