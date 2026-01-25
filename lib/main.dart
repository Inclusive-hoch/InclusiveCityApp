import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';

import 'injection_container.dart' as di;
import 'core/app.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await dotenv.load(fileName: ".env");
  await di.init();
  //await di.sl<TempAuthService>().loginHardcoded();

  runApp(const MyApp());
}
