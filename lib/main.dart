import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:pyjama_runner/config.dart';
import 'package:pyjama_runner/providers/phantom.dart';
import 'package:pyjama_runner/providers/providers.dart';
import 'package:pyjama_runner/services/context_utility.dart';
import 'package:pyjama_runner/utils/hive.dart';
import 'package:pyjama_runner/utils/phantom_connect.dart';
import 'firebase_options.dart';
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pyjama_runner/screens/pyjama_coin_app.dart';
import 'package:pyjama_runner/services/link_services.dart';
import 'models/settings.dart';
import 'models/player_data.dart';
import "package:app_links/app_links.dart";

late PhantomConnect phantomConnect;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  LinkServices.init();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initHive();

  phantomConnect = PhantomConnect(appUrl: appUrl, deepLink: deepLink);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ReferralProvider()),
        ChangeNotifierProvider(create: (_) => ReferralJoinProvider()),
        ChangeNotifierProvider(
          create: (_) => PhantomWalletProvider(),
        ),
      ],
      child: const PyjamaCoinApp(),
    ),
  );
  _handleDeepLink();
}

void _handleDeepLink() async {
  try {
    final appLinks = AppLinks(); // AppLinks is singleton

    final sub = appLinks.uriLinkStream.listen((uri) {
      _processDeepLink(uri);
    });

    sub.onData((uri) {
      _processDeepLink(uri);
    });
  } catch (e) {
    log('Failed to handle deep link: $e');
  }
}

void _processDeepLink(Uri uri) {
  log("uri query params ${uri.queryParameters}");

  if (phantomConnect.createSession(uri.queryParameters)) {
    final publicKey = phantomConnect.userPublicKey;
    log('User Public Key: $publicKey');
    saveData('publicKey', publicKey);

    // Update the PhantomWalletProvider
    Provider.of<PhantomWalletProvider>(ContextUtility.context!, listen: false)
        .setPublicKey(publicKey);

    // Fetch the balance
    Provider.of<PhantomWalletProvider>(ContextUtility.context!, listen: false)
        .fetchBalance();
  } else {
    log('Failed to connect to Phantom Wallet');
  }
}

// This function will initilize hive with apps documents directory.
// Additionally it will also register all the hive adapters.
Future<void> initHive() async {
  // For web hive does not need to be initialized.
  if (!kIsWeb) {
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
  }

  Hive.registerAdapter<PlayerData>(PlayerDataAdapter());
  Hive.registerAdapter<Settings>(SettingsAdapter());
}
