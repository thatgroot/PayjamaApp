import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:pyjama_runner/providers/phantom.dart';
import 'package:pyjama_runner/providers/providers.dart';
import 'package:pyjama_runner/services/context_utility.dart';
import 'package:pyjama_runner/utils/hive.dart';
import 'package:pyjama_runner/utils/phantom_connect.dart';
import 'package:solana/base58.dart';
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

  // Initialize PhantomConnect
  phantomConnect = PhantomConnect(
    appUrl: "https://your-app-url.com",
    deepLink: "yourapp://", // Replace with your app's deep link scheme
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ReferralProvider()),
        ChangeNotifierProvider(create: (_) => ReferralJoinProvider()),
        ChangeNotifierProvider(
            create: (_) => PhantomWalletProvider()), // Add this provider
      ],
      child: const PyjamaCoinApp(),
    ),
  );
  _handleDeepLink();
}

void _handleDeepLink() async {
  try {
    final appLinks = AppLinks(); // AppLinks is singleton

// Subscribe to all events (initial link and further)
    final sub = appLinks.uriLinkStream.listen((uri) {
      _processDeepLink(uri);
    });

    sub.onData((uri) {
      _processDeepLink(uri);
    });
  } catch (e) {
    print('Failed to handle deep link: $e');
  }
}

void _processDeepLink(Uri uri) {
  print("uri query params ${uri.queryParameters}");

  if (phantomConnect.createSession(uri.queryParameters)) {
    print('Connected to Phantom Wallet');
    final publicKey = phantomConnect.userPublicKey;
    print('User Public Key: $publicKey');
    saveData('publicKey', publicKey);

    // Update the PhantomWalletProvider
    Provider.of<PhantomWalletProvider>(ContextUtility.context!, listen: false)
        .setPublicKey(publicKey);

    // Fetch the balance
    Provider.of<PhantomWalletProvider>(ContextUtility.context!, listen: false)
        .fetchBalance();
  } else {
    print('Failed to connect to Phantom Wallet');
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
