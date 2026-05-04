import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:inclusive_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:inclusive_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:inclusive_app/features/routing/utils/route_icon_cache.dart';
import 'package:inclusive_app/features/routing/data/datasources/route_local_datasource.dart';

import 'injection_container.dart' as di;
import 'core/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await dotenv.load(fileName: ".env");
  await di.init();
  
  di.sl<AuthBloc>().add(AuthStarted());

  // Limpiar rutas antiguas del caché (mayores a 24 horas)
  try {
    await di.sl<RouteLocalDataSource>().clearOldRoutes();
    dev.log('Caché de rutas antiguas limpiado', name: 'AppStart');
  } catch (e) {
    dev.log('Error al limpiar caché de rutas: $e', name: 'AppStart');
  }

  RouteIconCache().preloadIcons();
  runApp(const MyApp());
}
