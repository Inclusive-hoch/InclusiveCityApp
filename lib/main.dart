import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:inclusive_app/core/auth/temp_auth_service.dart';
import 'package:inclusive_app/features/map_view/presentation/bloc/map_bloc.dart';
import 'package:inclusive_app/features/places/presentation/bloc/place_bloc.dart';
import 'package:inclusive_app/features/map_view/presentation/pages/map_page.dart';
import 'package:inclusive_app/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Cargar variables de entorno desde .env
  await dotenv.load(fileName: ".env");
  
  await di.init();
  
  // TODO: TEMPORAL - Login hardcodeado mientras Auth real está en desarrollo
  // Eliminar cuando el servicio de autenticación esté listo
  await di.sl<TempAuthService>().loginHardcoded();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => di.sl<MapBloc>(),
          ),
          BlocProvider(
            create: (context) => di.sl<PlaceBloc>(),
          ),
        ],
        child: const MapPage(),
      ),
    );
  }
}