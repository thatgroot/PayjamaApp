import 'dart:developer';

import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:pyjamaapp/models/player_data.dart';
import 'package:pyjamaapp/models/settings.dart';
import 'package:pyjamaapp/providers/game.dart';
import 'package:pyjamaapp/services/context_utility.dart';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

enum HiveKeys {
  score,
  phantomEncryptionPublicKey,
  connected,
  name,
  referralCode,
  dAppSecretKey,
  walletSession,
  userPublicKey,
  sound,
  bgm
}

enum GameNames {
  runner,
  fruitNinja,
  brickBreaker,
  cleaning,
}

class HiveService {
// This function will initilize hive with apps documents directory.
// Additionally it will also register all the hive adapters.
  static Future<void> init() async {
    // For web hive does not need to be initialized.
    if (!kIsWeb) {
      final dir = await getApplicationDocumentsDirectory();
      Hive.init(dir.path);
    }
    Hive.registerAdapter<PlayerData>(PlayerDataAdapter());
    Hive.registerAdapter<Settings>(SettingsAdapter());
  }

  static final Map<HiveKeys, String> keys = {
    HiveKeys.name: "name",
    HiveKeys.score: 'game_score',
    HiveKeys.phantomEncryptionPublicKey: 'phantomEncryptionPublicKey',
    HiveKeys.connected: "connected",
    HiveKeys.referralCode: "referralCode",
    HiveKeys.dAppSecretKey: "dAppSecretKey",
    HiveKeys.walletSession: "walletSession",
    HiveKeys.userPublicKey: "userPublicKey",
    HiveKeys.sound: "sound",
    HiveKeys.bgm: "bgm",
  };

  static final Map<GameNames, String> games = {
    GameNames.runner: 'runner',
    GameNames.fruitNinja: 'fruitNinja',
    GameNames.brickBreaker: 'brickBreaker',
    GameNames.cleaning: 'cleaning',
  };

  static final Map<GameNames, String> levels = {
    GameNames.runner: 'runner',
    GameNames.fruitNinja: 'fruitNinja',
    GameNames.brickBreaker: 'brickBreaker',
    GameNames.cleaning: 'cleaning',
  };

  // static Future _openBox(String box) async {
  //   return await Hive.openBox(box);
  // }

  static Future gameBox() async {
    return await Hive.openBox("game_box");
  }

  static Future<void> setData(HiveKeys key, dynamic value) async {
    String keyName = keys[key]!;
    (await gameBox()).put(keyName, value);
  }

  static Future<void> setGameScore(GameNames key, dynamic value) async {
    String gameType = games[key]!;
    (await gameBox()).put(gameType, value);
  }

  static Future<void> setGameLevel(
    GameNames key,
    int level,
  ) async {
    String gameType = games[key]!;
    (await gameBox()).put(
      "${gameType}Level",
      "$level",
    );
  }

  static Future<dynamic> getGameLevel(GameNames key) async {
    String gameType = games[key]!;
    return (await getValue(
          "${gameType}Level",
        )) ??
        "0";
  }

  static Future<void> setGameLevelScore({
    required GameNames game,
    required int level,
    required int score,
  }) async {
    String gameType = games[game]!;
    log("settings level data: ${gameType}Level${level}Score -> $score");
    (await gameBox()).put(
      "${gameType}Level${level}Score",
      "$score",
    );
  }

  static Future<Map<int, int>> getGameLevelScore(
    GameNames game,
  ) async {
    String gameType = games[game]!;

    int level = int.parse(await HiveService.getGameLevel(game) ?? "0");
    Map<int, int> levelScores = {};

    for (var i = 1; i < level + 1; i++) {
      levelScores[i] =
          int.parse((await gameBox()).get("${gameType}Level${i}Score") ?? "0");
    }
    log("level scores $levelScores");
    return levelScores;
  }

  static Future<dynamic> getValue(String key) async {
    log("Hive Service key is $key");
    return (await gameBox()).get(key);
  }

  static Future<int> getCurrentGameScore() async {
    {
      var globalGameProvider = Provider.of<GlobalGameProvider>(
        ContextUtility.context!,
        listen: false,
      );

      dynamic score =
          await HiveService.getGameScore(globalGameProvider.gameName);

      return score ?? 0;
    }
  }

  static Future<void> saveCurrentGameScore(int newScore) async {
    int oldScore = await HiveService.getCurrentGameScore();
    var provider =
        Provider.of<GlobalGameProvider>(ContextUtility.context!, listen: false);
    log("current game ${provider.gameName} prevScore $oldScore now $newScore total ${newScore + oldScore}");
    HiveService.setGameScore(provider.gameName, newScore + newScore);
  }

  static Future<int> getGameScore(GameNames key) async {
    String gameType = games[key]!;
    return int.parse("${await getValue(gameType) ?? "0"}");
  }

  static Future<dynamic> getData(HiveKeys key) async {
    return await getValue(keys[key]!);
  }

  static Future<Map<String, Map<int, int>>> getLevlScores() async {
    var runnerScore = await HiveService.getGameScore(GameNames.runner);

    Map<int, int> brickScoreMap =
        await HiveService.getGameLevelScore(GameNames.brickBreaker);
    Map<int, int> fruitScoreMap =
        await HiveService.getGameLevelScore(GameNames.fruitNinja);
    Map<int, int> runnerScoreMap = {6: runnerScore};

    return {
      "${GameNames.runner}": runnerScoreMap,
      "${GameNames.brickBreaker}": brickScoreMap,
      "${GameNames.fruitNinja}": fruitScoreMap,
    };
  }

  static Future<Map<String, int>> getGameScores() async {
    var runnerScore = await HiveService.getGameScore(GameNames.runner);
    var brickScore = await HiveService.getGameScore(GameNames.brickBreaker);
    var fruitScore = await HiveService.getGameScore(GameNames.fruitNinja);

    return {
      "${GameNames.runner}": runnerScore,
      "${GameNames.brickBreaker}": brickScore,
      "${GameNames.fruitNinja}": fruitScore,
    };
  }
}
