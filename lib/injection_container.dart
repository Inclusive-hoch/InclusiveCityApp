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
  sl.registerFactory(() => MapBloc());
}
