import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pyjamaapp/screens/web3/buy_nfts.dart';
import 'package:solana/solana.dart';

import 'games/brick_breaker/brick_breaker.dart';
import 'games/fruit_ninja/fruit_ninja.dart';

import 'services/context_utility.dart';

import 'screens/account/user_profile.dart';
import 'screens/referrals.dart';
import 'screens/pyjama/character_display.dart';
import 'screens/pyjama/character_selection.dart';
import 'screens/brick_breaker/brick_breaker_screen.dart';
import 'screens/loading_screen.dart';
import 'screens/brick_breaker/brick_breaker_levels.dart';
import 'screens/games.dart';
import 'screens/splash_screen.dart';
import 'screens/wallet_screen.dart';
import 'screens/name_input_screen.dart';
import 'screens/pyjama/daily_tasks.dart';
import 'screens/welcome_screen.dart';

const String appTitle = "PyjamaCoin";
const String appUrl = "https://orionplus.io";
const String deepLink = "pyjamaapp://connect";

ThemeData themeData = ThemeData(
  primaryColor: const Color(0xFF1F1B35),
  scaffoldBackgroundColor: const Color(0xFF1F1B35),
);

GoRoute _route(String path, Widget screen) {
  return GoRoute(
    path: path,
    builder: (context, state) => screen,
  );
}

// GoRouter configuration
final goRouter = GoRouter(
  navigatorKey: ContextUtility.navigatorKey,
  initialLocation: SplashScreen.route,
  routes: [
    _route(SplashScreen.route, const SplashScreen()),
    _route(WelcomeScreen.route, const WelcomeScreen()),
    _route(LoadingScreen.route, const LoadingScreen()),
    _route(WalletScreen.route, const WalletScreen()),
    _route(GamesScreen.route, const GamesScreen()),
    _route(CharacterSelectionScreen.route, const CharacterSelectionScreen()),
    _route(CharacterDisplayScreen.route, const CharacterDisplayScreen()),
    _route(BrickBreakerScreen.route, const BrickBreakerScreen()),
    _route(FruitNinja.route, const FruitNinja()),
    _route(BrickBreakerLevelsScreen.route, const BrickBreakerLevelsScreen()),
    _route(BrickBreaker.route, const BrickBreaker()),
    _route(NameInputScreen.route, const NameInputScreen()),
    _route(UserProfile.route, const UserProfile()),
    _route(DailyTasks.route, const DailyTasks()),
    _route(BuyNfts.route, const BuyNfts()),
    _route(Referrals.route, const Referrals()),
  ],
);

class SolanaConfig {
  static const String nftAddress =
      'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA0';
  static const String testnetRpcUrl = 'https://api.testnet.solana.com';
  static const String testnetWsUrl = 'wss://api.testnet.solana.com';
  static const String testnetCluster = 'testnet';
  static const String devnetRpcUrl = 'https://api.devnet.solana.com';
  static const String devnetWsUrl = 'wss://api.devnet.solana.com';
  static const String devnetCluster = 'devnet';
  static const String mainnetRpcUrl = 'https://api.mainnet-beta.solana.com';
  static const String mainnetWsUrl = 'wss://api.mainnet-beta.solana.com';
  static const String mainnetCluster = 'mainnet-beta';
}

enum SolanaCluster { devnet, mainnet }

class WalletConfig {
  static SolanaClient client() {
    String rpc = cluster == SolanaCluster.devnet
        ? SolanaConfig.devnetRpcUrl
        : SolanaConfig.mainnetRpcUrl;

    String ws = cluster == SolanaCluster.devnet
        ? SolanaConfig.devnetWsUrl
        : SolanaConfig.mainnetWsUrl;

    SolanaClient solanaClient = SolanaClient(
      rpcUrl: Uri.parse(rpc),
      websocketUrl: Uri.parse(ws),
    );
    return solanaClient;
  }

  static const String scheme = "https";
  static const String host = "phantom.app";
  static const SolanaCluster cluster = SolanaCluster.devnet;

  static String appUrl = "https://orionplus.io";
  static String connectDeepLink = "pyjamaapp://product?handleQuery=onConnect";

  // Paths
  static const String connect = '/ul/v1/connect';
  static const String connected = '/connected';
  static const String signAndSendTransaction = '/ul/v1/signAndSendTransaction';
  static const String disconnect = '/ul/v1/disconnect';
  static const String signTransaction = '/ul/v1/signTransaction';
  static const String signAllTransactions = '/ul/v1/signAllTransactions';
  static const String signMessage = 'ul/v1/signMessage';
}
