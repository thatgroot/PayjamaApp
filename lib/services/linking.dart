import 'dart:developer';

import 'package:app_links/app_links.dart';
import 'package:provider/provider.dart';
import 'package:pyjamaapp/providers/wallet.dart';
import 'package:pyjamaapp/screens/games.dart';
import 'package:pyjamaapp/services/context_utility.dart';
import 'package:pyjamaapp/services/solana_wallet_service.dart';
import 'package:pyjamaapp/services/hive.dart';
import 'package:pyjamaapp/utils/navigation.dart';

class LinkingService {
  static final appLinks = AppLinks(); // AppLinks is singleton

  static Future<void> init() async {
    try {
      appLinks.uriLinkStream.listen((uri) {
        log("processing deep link data");

        _processDeepLink(uri);
      }).onData((uri) {
        log("processing deep link data");
        _processDeepLink(uri);
      });
    } catch (e) {
      log('Failed to handle deep link: $e');
    }
  }

  static void _processDeepLink(Uri uri) {
    log("uri all query params ${uri.queryParametersAll.toString()}");
    if (SolanaWalletService.verifySession(uri)) {
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
        to(ContextUtility.context!, GamesScreen.route);
      });
    } else {
      log('Failed to connect to Phantom Wallet');
    }
  }
}
