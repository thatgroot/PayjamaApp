import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pyjamaapp/games/pyjama_game/pyjama_runner.dart';
import 'package:pyjamaapp/screens/web3/marketplace.dart';

import 'games/brick_breaker/brick_breaker.dart';
import 'games/fruit_ninja/fruit_ninja.dart';

import 'services/context_utility.dart';

import 'screens/account/user_profile.dart';
import 'screens/referrals_screen.dart';
import 'screens/app_screen.dart';
import 'screens/pyjama/character_screen.dart';
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
    _route(PyjamaCharacterScreen.route, const PyjamaCharacterScreen()),
    _route(PyjamaAppScreen.route, const PyjamaAppScreen()),
    _route(BrickBreakerScreen.route, const BrickBreakerScreen()),
    _route(BrickBreakerLevelsScreen.route, const BrickBreakerLevelsScreen()),
    _route(BrickBreaker.route, const BrickBreaker()),
    _route(NameInputScreen.route, const NameInputScreen()),
    _route(UserProfile.route, const UserProfile()),
    _route(DailyTasks.route, const DailyTasks()),
    _route(MarketPlace.route, const MarketPlace()),
    _route(ReferralsScreen.route, const ReferralsScreen()),
    _route(PyjamaRunner.route, const PyjamaRunner()),
    _route(FruitNinja.route, const FruitNinja()),
    _route(BrickBreaker.route, const BrickBreaker()),
  ],
);

class WalletConfig {
  static const List<int> dAppPrivateKey = [
    15,
    45,
    81,
    175,
    222,
    247,
    225,
    170,
    1,
    115,
    75,
    128,
    93,
    91,
    23,
    191,
    214,
    134,
    92,
    7,
    182,
    75,
    229,
    45,
    17,
    101,
    155,
    70,
    211,
    16,
    238,
    38
  ];
  static const String toConnected = 'connected';
  static const String toDisConnected = 'disconnect';
  static const String toMarketplace = 'marketplace';
  static const String toReferral = 'referral';

  // Paths
  static const String connect = '/ul/v1/connect';
  static const String disconnect = '/ul/v1/disconnect';
  static const String signAndSendTransaction = '/ul/v1/signAndSendTransaction';
  static const String signTransaction = '/ul/v1/signTransaction';

  static const String signAllTransactions = '/ul/v1/signAllTransactions';
  static const String signMessage = 'ul/v1/signMessage';
}
