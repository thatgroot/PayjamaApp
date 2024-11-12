import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:pyjamaapp/config.dart';
import 'package:pyjamaapp/services/linking.dart';
import 'package:pyjamaapp/services/hive.dart';
import 'package:pyjamaapp/services/solana_wallet_service.dart';

import 'providers/config.dart';
import 'firebase_options.dart';

//
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

  await HiveService.init();
  await LinkingService.init();
  SolanaWalletService.init();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: appProviders,
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: appTitle,
        theme: themeData,
        routerConfig: goRouter,
      ),
    ),
  );
}
