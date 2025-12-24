import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:inclusivecity_frontend/core/network/network_info.dart';
import 'package:inclusivecity_frontend/features/map/data/datasources/place_remote_data_source.dart';
import 'package:inclusivecity_frontend/features/map/data/datasources/place_remote_data_source_impl.dart';
import 'package:inclusivecity_frontend/features/map/data/datasources/place_local_data_source.dart';
import 'package:inclusivecity_frontend/features/map/data/datasources/spot_remote_data_source.dart';
import 'package:inclusivecity_frontend/features/map/data/repositories/place_repository_impl.dart';
import 'package:inclusivecity_frontend/features/map/data/repositories/spot_repository_impl.dart';
import 'package:inclusivecity_frontend/features/map/domain/repositories/place_repository.dart';
import 'package:inclusivecity_frontend/features/map/domain/repositories/spot_repository.dart';
import 'package:inclusivecity_frontend/features/map/domain/usecases/get_place_detail.dart';
import 'package:inclusivecity_frontend/features/map/domain/usecases/search_places.dart';
import 'package:inclusivecity_frontend/features/map/domain/usecases/get_search_history.dart';
import 'package:inclusivecity_frontend/features/map/domain/usecases/save_place_to_history.dart';
import 'package:inclusivecity_frontend/features/map/domain/usecases/save_spot.dart';
import 'package:inclusivecity_frontend/features/map/domain/usecases/get_user_spots.dart';
import 'package:inclusivecity_frontend/features/map/presentation/bloc/place_bloc.dart';
import 'package:inclusivecity_frontend/features/map/presentation/bloc/spots_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';


// Service Locator
final sl = GetIt.instance;

Future<void> init() async {
  // --- Features: Places ---

  // BLoC
  sl.registerFactory(
    () => PlacesBloc(
      searchPlacesUseCase: sl<SearchPlaces>(),
      getPlaceDetailsUseCase: sl<GetPlaceDetails>(),
      getSearchHistoryUseCase: sl<GetSearchHistory>(),
      savePlaceToHistoryUseCase: sl<SavePlaceToHistory>(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => SearchPlaces(sl<PlaceRepository>()));
  sl.registerLazySingleton(() => GetPlaceDetails(sl<PlaceRepository>()));
  sl.registerLazySingleton(() => GetSearchHistory(sl<PlaceRepository>()));
  sl.registerLazySingleton(() => SavePlaceToHistory(sl<PlaceRepository>()));

  // Repository
  sl.registerLazySingleton<PlaceRepository>(
    () => PlaceRepositoryImpl(
      remoteDataSource: sl<PlaceRemoteDataSource>(),
      localDataSource: sl<PlaceLocalDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // Data Sources
  sl.registerLazySingleton<PlaceRemoteDataSource>(
    () => BackendPlacesDataSourceImpl(client: sl<http.Client>()),
  );

  sl.registerLazySingleton<PlaceLocalDataSource>(
    () => PlaceLocalDataSourceImpl(sharedPreferences: sl<SharedPreferences>()),
  );

  // --- Features: Spots ---

  // BLoC
  sl.registerFactory(
    () => SpotsBloc(
      saveSpot: sl<SaveSpot>(),
      getUserSpots: sl<GetUserSpots>(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => SaveSpot(sl<SpotRepository>()));
  sl.registerLazySingleton(() => GetUserSpots(sl<SpotRepository>()));

  // Repository
  sl.registerLazySingleton<SpotRepository>(
    () => SpotRepositoryImpl(
      remoteDataSource: sl<SpotRemoteDataSource>(),
    ),
  );

  // Data Sources
  sl.registerLazySingleton<SpotRemoteDataSource>(
    () => SpotRemoteDataSourceImpl(client: sl<http.Client>()),
  );

  // --- Core ---
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl<InternetConnectionChecker>()));

  // --- Externas ---
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => InternetConnectionChecker());
}