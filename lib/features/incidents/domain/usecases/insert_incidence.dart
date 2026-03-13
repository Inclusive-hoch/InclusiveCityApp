import '../repositories/incident_repository.dart';

class InsertIncidence {
  final IncidentRepository repository;

  InsertIncidence(this.repository);

  Future<void> call({
    String? placeId,
    required double latitude,
    required double longitude,
    required String incidence,
    String image = '',
  }) {
    final backendIncidence = _toBackendIncidenceName(incidence);
    final resolvedPlaceId = placeId?.trim().isNotEmpty == true
        ? placeId!.trim()
        : _buildPlaceId(latitude, longitude, backendIncidence);

    return repository.insertIncidence(
      placeId: resolvedPlaceId,
      latitude: latitude,
      longitude: longitude,
      incidence: backendIncidence,
      image: image,
    );
  }

  String _toBackendIncidenceName(String incidence) {
    const mapping = {
      'Problema alumbrado público': 'ALUMBRADO_PUBLICO',
      'Obra': 'OBRA',
      'Escombros': 'ESCOMBROS',
      'Bloqueo de ruta': 'BLOQUEDO_RUTA',
      'Falta de rampa': 'NO_RAMPA',
      'Rampa dañada': 'RAMPA_DANADA',
      'Rampa bloqueada': 'RAMPA_BLOQUEADA',
      'ALUMBRADO_PUBLICO': 'ALUMBRADO_PUBLICO',
      'OBRA': 'OBRA',
      'ESCOMBROS': 'ESCOMBROS',
      'BLOQUEDO_RUTA': 'BLOQUEDO_RUTA',
      'NO_RAMPA': 'NO_RAMPA',
      'RAMPA_DANADA': 'RAMPA_DANADA',
      'RAMPA_BLOQUEADA': 'RAMPA_BLOQUEADA',
    };

    final resolved = mapping[incidence.trim()];
    if (resolved != null) return resolved;

    throw ArgumentError(
      'El tipo de incidencia "$incidence" aún no está soportado por el backend.',
    );
  }

  String _buildPlaceId(double latitude, double longitude, String incidence) {
    final lat = latitude.toStringAsFixed(6);
    final lng = longitude.toStringAsFixed(6);
    return 'manual_${lat}_${lng}_$incidence';
  }
}
