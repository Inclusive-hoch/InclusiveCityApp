import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:inclusive_app/core/network/network_info.dart';
import 'package:inclusive_app/core/auth/temp_auth_service.dart';

import 'package:inclusive_app/features/map_view/presentation/bloc/map_bloc.dart';

import 'package:inclusive_app/features/places/data/datasources/place_local_datasource.dart';
import 'package:inclusive_app/features/places/data/datasources/place_remote_datasource.dart';
import 'package:inclusive_app/features/places/data/repositories/place_repository_impl.dart';
import 'package:inclusive_app/features/places/domain/repositories/place_repository.dart';
import 'package:inclusive_app/features/places/domain/usecases/get_place_detail.dart';
import 'package:inclusive_app/features/places/domain/usecases/get_search_history.dart';
import 'package:inclusive_app/features/places/domain/usecases/save_place_to_history.dart';
import 'package:inclusive_app/features/places/domain/usecases/search_places.dart';
import 'package:inclusive_app/features/places/presentation/bloc/place_bloc.dart';

/// Instancia global del contenedor de inyección de dependencias.
final sl = GetIt.instance;

/// Inicializa todas las dependencias del proyecto.
/// 
/// Configura el contenedor de inyección de dependencias siguiendo
/// la arquitectura limpia, registrando las dependencias en orden:
/// 1. Dependencias externas (SharedPreferences, HTTP, etc.)
/// 2. Servicios core (Auth, Network)
/// 3. Data sources (Remote y Local)
/// 4. Repositories
/// 5. Use cases
/// 6. BLoCs
/// 
/// Debe ser llamado antes de iniciar la aplicación.
Future<void> init() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => InternetConnectionChecker());

  // Core services
  sl.registerLazySingleton<TempAuthService>(
      () => TempAuthService(prefs: sl(), client: sl()));

  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // Data sources
  sl.registerLazySingleton<PlaceRemoteDataSource>(
      () => PlaceRemoteDataSourceImpl(
            client: sl(),
            getToken: () => sl<TempAuthService>().getToken(),
          ));
  sl.registerLazySingleton<PlaceLocalDataSource>(
      () => PlaceLocalDataSourceImpl(sharedPreferences: sl()));

  // Repositories
  sl.registerLazySingleton<PlaceRepository>(() => PlaceRepositoryImpl(
        remoteDataSource: sl(),
        localDataSource: sl(),
        networkInfo: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => SearchPlaces(sl()));
  sl.registerLazySingleton(() => GetPlaceDetails(sl()));
  sl.registerLazySingleton(() => GetSearchHistory(sl()));
  sl.registerLazySingleton(() => SavePlaceToHistory(sl()));

  // BLoCs
  sl.registerFactory(() => MapBloc());

  sl.registerFactory(() => PlaceBloc(
        searchPlacesUseCase: sl(),
        getPlaceDetailsUseCase: sl(),
        getSearchHistoryUseCase: sl(),
        savePlaceToHistoryUseCase: sl(),
      ));
}