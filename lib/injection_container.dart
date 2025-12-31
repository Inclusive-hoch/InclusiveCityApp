import 'package:get_it/get_it.dart';
import 'package:inclusive_app/features/map_view/presentation/application/map_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerFactory(() => MapBloc());

}