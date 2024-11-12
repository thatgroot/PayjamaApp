import 'dart:developer';

import 'package:app_links/app_links.dart';
import 'package:provider/provider.dart';
import 'package:pyjamaapp/config.dart';
import 'package:pyjamaapp/providers/wallet.dart';
import 'package:pyjamaapp/screens/pyjama/character_display.dart';
import 'package:pyjamaapp/screens/referrals_screen.dart';
import 'package:pyjamaapp/screens/web3/marketplace.dart';
import 'package:pyjamaapp/services/context_utility.dart';
import 'package:pyjamaapp/services/solana_wallet_service.dart';
import 'package:pyjamaapp/services/hive.dart';
import 'package:pyjamaapp/utils/navigation.dart';

String debugKey = "lib/services/linking.dart";

class LinkingService {
  static final appLinks = AppLinks(); // AppLinks is singleton

  static Future<void> init() async {
    try {
      appLinks.uriLinkStream.listen(
        (uri) {
          _processDeepLink(uri);
        },
        onDone: () => {},
        onError: (e) => {},
        cancelOnError: true,
      );
    } catch (e) {
      log('Failed to handle deep link: $e');
    }
  }

  static Future<void> _processDeepLink(Uri uri) async {
    log("_processDeepLink uri  ${uri.toString()} path ${uri.pathSegments.toString()}");
    log("_processDeepLink uri all query params ${uri.queryParametersAll.toString()}");

    String route = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : '';
    log("$debugKey route $route , ${route == WalletConfig.toConnected}");
    if (route == WalletConfig.toMarketplace) {
      to(ContextUtility.context!, MarketPlace.route);
    } else if (route == WalletConfig.toReferral) {
      to(ContextUtility.context!, ReferralsScreen.route);
    } else if (route == WalletConfig.toConnected &&
        await SolanaWalletService.verifySession(uri)) {
      final userPublicKey = SolanaWalletService.userPublicKey;
      log('User Public Key: $userPublicKey');

      HiveService.setData(HiveKeys.userPublicKey, userPublicKey);
      HiveService.setData(HiveKeys.userPublicKey, userPublicKey);
      HiveService.setData(HiveKeys.connected, true);

      WalletProvider walletProvider =
          Provider.of<WalletProvider>(ContextUtility.context!, listen: false);

      walletProvider.setPublicKey(SolanaWalletService.userPublicKey!);
      walletProvider.fetchBalance();

      HiveService.getData(HiveKeys.connected).then((connected) {
        to(
          ContextUtility.context!,
          CharacterDisplayScreen.route,
        );
      });
    } else {
      log('Failed to connect to Phantom Wallet');
    }
  }
}
