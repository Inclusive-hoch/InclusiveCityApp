import 'package:inclusive_app/features/spot/domain/entities/custom_spot.dart';
import 'package:inclusive_app/features/spot/domain/repositories/spot_repository.dart';

/// Caso de uso para crear una lista personalizada de spots.
class CreateCustomSpot {
  final SpotRepository repository;

  CreateCustomSpot(this.repository);

  Future<CustomSpot> call(CustomSpot customSpot) async {
    return await repository.createCustomSpot(customSpot);
  }
}
