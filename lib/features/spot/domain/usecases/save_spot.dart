import 'package:inclusive_app/features/spot/domain/entities/spot.dart';
import 'package:inclusive_app/features/spot/domain/repositories/spot_repository.dart';

class SaveSpot {
  final SpotRepository repository;

  SaveSpot(this.repository);

  Future<Spot> call(Spot spot) async {
    return await repository.createSpot(spot);
  }
}
