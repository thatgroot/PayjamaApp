import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:pyjamaapp/config.dart';
import 'package:pyjamaapp/providers/phantom.dart';
import 'package:pyjamaapp/screens/games.dart';
import 'package:pyjamaapp/services/context_utility.dart';
import 'package:pyjamaapp/services/wallet_service.dart';
import 'package:pyjamaapp/utils/hive.dart';
import 'package:pyjamaapp/utils/navigation.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'models/settings.dart';
import 'models/player_data.dart';
import "package:app_links/app_links.dart";

Future<void> handleDeepLink() async {
  WalletService walletService =
      WalletService(appUrl: appUrl, deepLink: deepLink);
  try {
    final appLinks = AppLinks(); // AppLinks is singleton
    appLinks.uriLinkStream.listen((uri) {
      _processDeepLink(walletService, uri);
    }).onData((uri) {
      _processDeepLink(walletService, uri);
    });
  } catch (e) {
    log('Failed to handle deep link: $e');
  }
}

void _processDeepLink(WalletService walletService, Uri uri) {
  if (walletService.createSession(uri.queryParameters)) {
    final publicKey = walletService.userPublicKey;
    log('User Public Key: $publicKey');
    saveData('publicKey', publicKey);
    saveData("connected", true);
    // Update the PhantomWalletProvider
    Provider.of<PhantomWalletProvider>(ContextUtility.context!, listen: false)
        .setPublicKey(publicKey);

    // Fetch the balance
    Provider.of<PhantomWalletProvider>(ContextUtility.context!, listen: false)
        .fetchBalance();

    getData("connected").then((connected) {
      to(ContextUtility.context!, GamesScreen.route);
    });
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
