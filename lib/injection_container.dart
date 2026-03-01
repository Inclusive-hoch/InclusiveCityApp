import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:inclusive_app/core/auth/firebase_auth_service.dart';
import 'package:inclusive_app/core/network/network_info.dart';
import 'package:inclusive_app/features/auth/data/datasources/auth_firebase_datasource.dart';
import 'package:inclusive_app/features/auth/data/datasources/auth_firebase_datasource_impl.dart';
import 'package:inclusive_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:inclusive_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:inclusive_app/features/auth/domain/usecases/get_current_user.dart';
import 'package:inclusive_app/features/auth/domain/usecases/login_with_email.dart';
import 'package:inclusive_app/features/auth/domain/usecases/login_with_google.dart';
import 'package:inclusive_app/features/auth/domain/usecases/register_with_email.dart';
import 'package:inclusive_app/features/auth/domain/usecases/logout.dart';
import 'package:inclusive_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:inclusive_app/features/incidents/data/datasources/incident_remote_datasource.dart';
import 'package:inclusive_app/features/incidents/data/datasources/incident_remote_datasource_impl.dart';
import 'package:inclusive_app/features/incidents/data/repositories/incident_repository_impl.dart';
import 'package:inclusive_app/features/incidents/domain/repositories/incident_repository.dart';
import 'package:inclusive_app/features/incidents/domain/usecases/get_sector_incidences.dart';
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
import 'package:inclusive_app/features/spot/data/datasources/spot_remote_datasource.dart';
import 'package:inclusive_app/features/spot/data/repositories/spot_repository_impl.dart';
import 'package:inclusive_app/features/spot/domain/repositories/spot_repository.dart';
import 'package:inclusive_app/features/spot/domain/usecases/add_spot_to_list.dart';
import 'package:inclusive_app/features/spot/domain/usecases/create_custom_spot.dart';
import 'package:inclusive_app/features/spot/domain/usecases/delete_custom_spot_list.dart';
import 'package:inclusive_app/features/spot/domain/usecases/delete_spot.dart';
import 'package:inclusive_app/features/spot/domain/usecases/delete_spot_from_list.dart';
import 'package:inclusive_app/features/spot/domain/usecases/get_custom_spots.dart';
import 'package:inclusive_app/features/spot/domain/usecases/get_user_spots.dart';
import 'package:inclusive_app/features/spot/domain/usecases/save_spot.dart';
import 'package:inclusive_app/features/spot/presentation/bloc/spot_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inclusive_app/features/profile/data/datasources/user_evaluation_remote_datasource.dart';
import 'package:inclusive_app/features/profile/data/datasources/user_evaluation_local_datasource.dart';
import 'package:inclusive_app/features/profile/data/datasources/user_evaluation_local_datasource_impl.dart';
import 'package:inclusive_app/features/profile/data/repositories/user_evaluation_repository_impl.dart';
import 'package:inclusive_app/features/profile/domain/repositories/user_evaluation_repository.dart';
import 'package:inclusive_app/features/profile/domain/usecases/get_user_evaluations.dart';
import 'package:inclusive_app/features/profile/application/bloc/user_evaluation_bloc.dart';
import 'package:inclusive_app/features/routing/data/datasources/route_remote_datasource.dart';
import 'package:inclusive_app/features/routing/data/datasources/route_remote_datasource_impl.dart';
import 'package:inclusive_app/features/routing/data/repositories/route_repository_impl.dart';
import 'package:inclusive_app/features/routing/domain/repositories/route_repository.dart';
import 'package:inclusive_app/features/routing/domain/usecases/get_alternative_route.dart';
import 'package:inclusive_app/features/routing/presentation/bloc/route_bloc.dart';

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
  // Firebase
  sl.registerLazySingleton(() => FirebaseAuth.instance);

  // Google Sign-In
  sl.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn());

  // Auth - DataSource
  sl.registerLazySingleton<AuthFirebaseDataSource>(
    () => AuthFirebaseDataSourceImpl(sl(), sl()),
  );

  // Auth - Repository
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));

  // Auth - UseCases
  sl.registerLazySingleton(() => LoginWithEmail(sl()));
  sl.registerLazySingleton(() => LoginWithGoogle(sl()));
  sl.registerLazySingleton(() => RegisterWithEmail(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerLazySingleton(() => Logout(sl()));

  // Auth - Bloc (GLOBAL)
  sl.registerLazySingleton<AuthBloc>(
    () => AuthBloc(
      loginWithEmail: sl(),
      loginWithGoogle: sl(),
      registerWithEmail: sl(),
      getCurrentUser: sl(),
      logout: sl(),
    ),
  );

  // Map
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => InternetConnectionChecker.createInstance());

  // Core services
  sl.registerLazySingleton<FirebaseAuthService>(
    () => FirebaseAuthService(firebaseAuth: sl()),
  );

  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // Data sources - Places
  sl.registerLazySingleton<PlaceRemoteDataSource>(
    () => PlaceRemoteDataSourceImpl(
      client: sl(),
      getToken: () => sl<FirebaseAuthService>().getIdToken(),
    ),
  );
  sl.registerLazySingleton<PlaceLocalDataSource>(
    () => PlaceLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // Data sources - Spots
  sl.registerLazySingleton<SpotRemoteDatasource>(
    () => SpotRemoteDatasourceImpl(
      client: sl(),
      getToken: () => sl<FirebaseAuthService>().getIdToken(),
    ),
  );

  // Repositories - Places
  sl.registerLazySingleton<PlaceRepository>(
    () => PlaceRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Repositories - Spots
  sl.registerLazySingleton<SpotRepository>(
    () => SpotRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases - Places
  sl.registerLazySingleton(() => SearchPlaces(sl()));
  sl.registerLazySingleton(() => GetPlaceDetails(sl()));
  sl.registerLazySingleton(() => GetSearchHistory(sl()));
  sl.registerLazySingleton(() => SavePlaceToHistory(sl()));

  // Use cases - Spots
  sl.registerLazySingleton(() => SaveSpot(sl()));
  sl.registerLazySingleton(() => GetUserSpots(sl()));
  sl.registerLazySingleton(() => DeleteSpot(sl()));
  sl.registerLazySingleton(() => CreateCustomSpot(sl()));
  sl.registerLazySingleton(() => GetCustomSpots(sl()));
  sl.registerLazySingleton(() => AddSpotToList(sl()));
  sl.registerLazySingleton(() => DeleteCustomSpotList(sl()));
  sl.registerLazySingleton(() => DeleteSpotFromList(sl()));

  // BLoCs
  // Incidents - DataSource
  sl.registerLazySingleton<IncidentRemoteDataSource>(
    () => IncidentRemoteDataSourceImpl(
      client: sl(),
      getToken: () => sl<FirebaseAuthService>().getIdToken(),
    ),
  );

  // Incidents - Repository
  sl.registerLazySingleton<IncidentRepository>(
    () => IncidentRepositoryImpl(remoteDataSource: sl()),
  );

  // Incidents - UseCases
  sl.registerLazySingleton(() => GetSectorIncidences(sl()));

  sl.registerFactory(() => MapBloc(getSectorIncidences: sl()));

  sl.registerFactory(
    () => PlaceBloc(
      searchPlacesUseCase: sl(),
      getPlaceDetailsUseCase: sl(),
      getSearchHistoryUseCase: sl(),
      savePlaceToHistoryUseCase: sl(),
    ),
  );

  // User Evaluations - DataSource
  sl.registerLazySingleton<UserEvaluationRemoteDataSource>(
    () => UserEvaluationRemoteDataSourceImpl(
      client: sl(),
      getToken: () => sl<FirebaseAuthService>().getIdToken(),
    ),
  );

  sl.registerLazySingleton<UserEvaluationLocalDatasource>(
    () => UserEvaluationLocalDatasourceImpl(sharedPreferences: sl()),
  );

  // User Evaluations - Repository
  sl.registerLazySingleton<UserEvaluationRepository>(
    () => UserEvaluationRepositoryImpl(
      remoteDataSource: sl(),
      localDatasource: sl(),
      networkInfo: sl(),
    ),
  );

  // User Evaluations - UseCase
  sl.registerLazySingleton(() => GetUserEvaluations(sl()));

  // User Evaluations - Bloc
  sl.registerFactory(
    () => UserEvaluationBloc(getUserEvaluations: sl(), placeRepository: sl()),
  );

  // Routing - DataSource
  sl.registerLazySingleton<RouteRemoteDataSource>(
    () => RouteRemoteDataSourceImpl(
      client: sl(),
      getToken: () => sl<FirebaseAuthService>().getIdToken(),
    ),
  );

  // Routing - Repository
  sl.registerLazySingleton<RouteRepository>(
    () => RouteRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Routing - UseCases
  sl.registerLazySingleton(() => GetAlternativeRoute(sl()));

  // Routing - Bloc
  sl.registerFactory(() => RouteBloc(getAlternativeRoute: sl()));

  sl.registerFactory(
    () => SpotBloc(
      saveSpot: sl(),
      getUserSpots: sl(),
      deleteSpot: sl(),
      createCustomSpot: sl(),
      getCustomSpots: sl(),
      addSpotToList: sl(),
      deleteCustomSpotList: sl(),
      deleteSpotFromList: sl(),
    ),
  );
}
