import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:inclusive_app/features/auth/data/datasources/auth_firebase_datasource.dart';
import 'package:inclusive_app/features/auth/data/datasources/auth_firebase_datasource_impl.dart';
import 'package:inclusive_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:inclusive_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:inclusive_app/features/auth/domain/usecases/get_current_user.dart';
import 'package:inclusive_app/features/auth/domain/usecases/login_with_email.dart';
import 'package:inclusive_app/features/auth/domain/usecases/login_with_google.dart';
import 'package:inclusive_app/features/auth/domain/usecases/logout.dart';
import 'package:inclusive_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:inclusive_app/features/map_view/application/map_bloc.dart';

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

  // Auth - DataSource
  sl.registerLazySingleton<AuthFirebaseDataSource>(
    () => AuthFirebaseDataSourceImpl(sl()),
  );

  // Auth - Repository
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));

  // Auth - UseCases
  sl.registerLazySingleton(() => LoginWithEmail(sl()));
  sl.registerLazySingleton(() => LoginWithGoogle(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerLazySingleton(() => Logout(sl()));

  // Auth - Bloc (GLOBAL)
  sl.registerLazySingleton<AuthBloc>(
    () => AuthBloc(
      loginWithEmail: sl(),
      loginWithGoogle: sl(),
      getCurrentUser: sl(),
      logout: sl(),
    ),
  );

  // Map
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => InternetConnectionChecker());

  // Core services
  sl.registerLazySingleton<TempAuthService>(
    () => TempAuthService(prefs: sl(), client: sl()),
  );

  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // Data sources
  sl.registerLazySingleton<PlaceRemoteDataSource>(
    () => PlaceRemoteDataSourceImpl(
      client: sl(),
      getToken: () => sl<TempAuthService>().getToken(),
    ),
  );
  sl.registerLazySingleton<PlaceLocalDataSource>(
    () => PlaceLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // Repositories
  sl.registerLazySingleton<PlaceRepository>(
    () => PlaceRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => SearchPlaces(sl()));
  sl.registerLazySingleton(() => GetPlaceDetails(sl()));
  sl.registerLazySingleton(() => GetSearchHistory(sl()));
  sl.registerLazySingleton(() => SavePlaceToHistory(sl()));

  // BLoCs
  sl.registerFactory(() => MapBloc());
}
