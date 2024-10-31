import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:pyjamaapp/services/linking.dart';
import 'package:pyjamaapp/services/hive.dart';

import 'providers/config.dart';
import 'screens/app.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

  await HiveService.init();
  await LinkingService.init();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MultiProvider(providers: appProviders, child: const App()));
}
