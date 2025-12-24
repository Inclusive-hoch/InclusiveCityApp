import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:inclusivecity_frontend/core/auth/auth_service.dart';
import 'package:inclusivecity_frontend/features/map/presentation/bloc/place_bloc.dart';
import 'package:inclusivecity_frontend/features/map/presentation/bloc/spots_bloc.dart';
import 'package:inclusivecity_frontend/features/map/presentation/pages/map_screen.dart';
import 'package:inclusivecity_frontend/injection_container.dart' as di;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: ".env");
  
  await di.init();
  
  // Configurar usuario temporal para testing
  // TODO: Eliminar esta línea cuando haya login real
  AuthService().setCurrentUser('demo-user-001');
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inclusive City',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => di.sl<PlacesBloc>()),
          BlocProvider(create: (_) => di.sl<SpotsBloc>()),
        ],
        child: const MapPage(),
      ),
    );
  }
}