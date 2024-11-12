import 'package:flutter/material.dart';
import 'package:pyjamaapp/services/firebase.dart';
import 'package:pyjamaapp/services/referral_service.dart';
import 'package:pyjamaapp/services/hive.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:developer';

class ReferralProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _referrals = [];

  List<Map<String, dynamic>> get referrals => _referrals;

  Future<void> loadReferralData(String userId) async {
    ReferralService referralService = ReferralService();
    _referrals = await referralService.getReferrals(userId, 5);
    notifyListeners();
  }

  Future<void> shareReferralCode(String code) async {
    await Share.share('Join Pyjama Runner using my referral code: $code');
  }
}

class ReferralJoinProvider extends ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';
  String _code = '';
  String _pubkey = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get referralCode => _code;
  String get publicKey => _pubkey;

  Future<bool> joinWithReferralCode(
      String name, String pubkey, String by) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      HiveService.setData(HiveKeys.name, name);
      final FirestoreService firestoreService = FirestoreService();
      ReferralService referralService = ReferralService();

      String id = await referralService.registerUser(name);

      _code = id;
      _pubkey = pubkey;

      if (by.isNotEmpty) {
        await referralService.addReferral(by, id);
      }

      var doc = await firestoreService.getDocument("info", pubkey);
      if (!doc.exists) {
        firestoreService.setDocument(
          "info",
          pubkey,
          {
            "name": name,
            "pubkey": pubkey,
            "id": id,
          },
        );
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage =
          'Invalid referral code or error occurred. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}

abstract class GameProvider with ChangeNotifier {
  int _score = 0;
  int _level = 1;
  bool _sound = true; // Default sound on
  bool _bgm = true; // Default background music on

  int get score => _score;
  int get level => _level;
  bool get sound => _sound;
  bool get bgm => _bgm;

  void update(int value) {
    _score = value;
    notifyListeners();
  }

  void updateLevel({
    required GameNames name,
    required int currentLevel,
    required int oldLevel,
    required int oldScore,
  }) {
    log("$_level $currentLevel -> levels");
    if (_level == currentLevel) return; // Only update if the level has changed

    log("updating $name score and levels data");
    // Only update Hive if the level has actually changed
    HiveService.setGameLevel(name, currentLevel);
    HiveService.setGameLevelScore(game: name, level: level, score: 0);
    HiveService.setGameLevelScore(
      game: name,
      level: oldLevel,
      score: oldScore,
    );

    _level = currentLevel;
    _score = 0;
    log("updated $name score and levels data");

    notifyListeners();
  }

  void resetScore() {
    _score = 0;
    notifyListeners();
  }

  void resetLevel() {
    _level = 1;
    notifyListeners();
  }

  void toggleSound() {
    _sound = !_sound;
    notifyListeners();
  }

  void toggleBgm() {
    _bgm = !_bgm;
    notifyListeners();
  }

  void setSound(bool value) {
    _sound = value;
    notifyListeners();
  }

  void setBgm(bool value) {
    _bgm = value;
    notifyListeners();
  }
}

class BrickBreakerGameProvider extends GameProvider {}

class FruitNinjaGameProvider extends GameProvider {}

class GlobalGameProvider with ChangeNotifier {
  GameNames _gameName = GameNames.runner;

  GameNames get gameName => _gameName;
  set setGameName(GameNames name) {
    _gameName = name;
    notifyListeners();
  }
}
