import 'package:flutter/material.dart';
import 'package:pyjamaapp/services/firebase.dart';
import 'package:pyjamaapp/services/referral.dart';
import 'package:pyjamaapp/services/referral_tree.dart';
import 'package:pyjamaapp/services/hive.dart';
import 'package:share_plus/share_plus.dart';

class ReferralProvider extends ChangeNotifier {
  final ReferralSystem referralSystem = ReferralSystem();
  List<Map<String, dynamic>> _referrals = [];

  List<Map<String, dynamic>> get referrals => _referrals;

  Future<void> loadReferralData(String userId) async {
    ReferralTree tree = ReferralTree();
    _referrals = await tree.getReferrals(userId, 5);
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

  /// Joins a user to the referral program using a referral code.
  ///
  /// Parameters:
  ///   name (String): The name of the character to join.
  ///   pubkey (String): The public key of the current user.
  ///   by (String): The referral code to use.
  ///
  /// Returns:
  ///   Future<bool>: A future that resolves to true if the join is successful, false otherwise.
  Future<bool> joinWithReferralCode(
      String name, String pubkey, String by) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      HiveService.setData(HiveKeys.name, name);
      final FirestoreService firestoreService = FirestoreService();

      ReferralTree tree = ReferralTree();

      String id = await tree.registerUser(name);

      _code = id;
      _pubkey = pubkey;

      if (by.length > 1) {
        await tree.addReferral(by, id);
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

class GlobalGameProvider with ChangeNotifier {
  GameNames _gameName = GameNames.runner;
  GameNames get gameName => _gameName;
  set setGameName(GameNames name) {
    _gameName = name;
    notifyListeners();
  }
}

abstract class GameProvider with ChangeNotifier {
  int _score = 0;
  int _level = 1;
  bool _sound = true; // Default sound on
  bool _bgm = true; // Default background music on

  int get score => _score;
  int get level => _level;
  bool get sound => _sound; // Getter for sound
  bool get bgm => _bgm; // Getter for background music

  // Method to increment the score
  void update(int value) {
    _score = value;
    notifyListeners(); // Notify listeners about the score change
  }

  // Method to update the level
  void updateLevel(GameNames name, int value) {
    _level = value;
    _score = 0; // Reset score when level changes
    HiveService.setGameLevel(
      name,
      value,
    );
    notifyListeners();
  }

  // Method to reset the score
  void resetScore() {
    _score = 0;
    notifyListeners();
  }

  // Method to reset the level
  void resetLevel() {
    _level = 1;
    notifyListeners();
  }

  // Method to toggle sound setting
  void toggleSound() {
    _sound = !_sound;
    notifyListeners(); // Notify listeners about the sound change
  }

  // Method to toggle background music setting
  void toggleBgm() {
    _bgm = !_bgm;
    notifyListeners(); // Notify listeners about the bgm change
  }

  // Optional methods to set sound and background music
  void setSound(bool value) {
    _sound = value;
    notifyListeners(); // Notify listeners about the sound change
  }

  void setBgm(bool value) {
    _bgm = value;
    notifyListeners(); // Notify listeners about the bgm change
  }
}

class BrickBreakerGameProvider with ChangeNotifier implements GameProvider {
  @override
  int _score = 0;
  @override
  int _level = 1;
  @override
  bool _sound = true; // Default sound on
  @override
  bool _bgm = true; // Default background music on

  @override
  int get score => _score;
  @override
  int get level => _level;
  @override
  bool get sound => _sound; // Getter for sound
  @override
  bool get bgm => _bgm; // Getter for background music

  // Method to increment the score
  @override
  void update(int value) {
    _score = value;
    notifyListeners(); // Notify listeners about the score change
  }

  // Method to update the level
  @override
  void updateLevel(GameNames name, int value) {
    _level = value;
    _score = 0;
    HiveService.setGameLevel(name, value);
    notifyListeners(); // Notify listeners about the level change
  }

  // Method to reset the score
  @override
  void resetScore() {
    _score = 0;
    notifyListeners();
  }

  // Method to reset the level
  @override
  void resetLevel() {
    _level = 1;
    notifyListeners();
  }

  // Method to toggle sound setting
  @override
  void toggleSound() {
    _sound = !_sound;
    notifyListeners(); // Notify listeners about the sound change
  }

  // Method to toggle background music setting
  @override
  void toggleBgm() {
    _bgm = !_bgm;
    notifyListeners(); // Notify listeners about the bgm change
  }

  // Method to set sound to a specific value (optional)
  @override
  void setSound(bool value) {
    _sound = value;
    notifyListeners(); // Notify listeners about the sound change
  }

  // Method to set background music to a specific value (optional)
  @override
  void setBgm(bool value) {
    _bgm = value;
    notifyListeners(); // Notify listeners about the bgm change
  }
}

class FruitNinjaGameProvider with ChangeNotifier implements GameProvider {
  void Function() _completePopover = () {};

  @override
  int _score = 0;
  @override
  int _level = 1;
  @override
  bool _sound = true; // Default sound on
  @override
  bool _bgm = true; // Default background music on

  @override
  int get score => _score;
  @override
  int get level => _level;
  @override
  bool get sound => _sound; // Getter for sound
  @override
  bool get bgm => _bgm; // Getter for background music

  set setCompletePopover(void Function() value) {
    _completePopover = value;
  }

  void completePopover() {
    _completePopover();
  }

  // Method to increment the score
  @override
  void update(int value) {
    _score = value;
    notifyListeners(); // Notify listeners about the score change
  }

  // Method to update the level
  @override
  void updateLevel(GameNames name, int value) {
    _level = value;
    _score = 0;
    HiveService.setGameLevel(name, value);
    notifyListeners(); // Notify listeners about the level change
  }

  // Method to reset the score
  @override
  void resetScore() {
    _score = 0;
    notifyListeners();
  }

  // Method to reset the level
  @override
  void resetLevel() {
    _level = 1;
    notifyListeners();
  }

  // Method to toggle sound setting
  @override
  void toggleSound() {
    _sound = !_sound;
    notifyListeners(); // Notify listeners about the sound change
  }

  // Method to toggle background music setting
  @override
  void toggleBgm() {
    _bgm = !_bgm;
    notifyListeners(); // Notify listeners about the bgm change
  }

  // Method to set sound to a specific value (optional)
  @override
  void setSound(bool value) {
    _sound = value;
    notifyListeners(); // Notify listeners about the sound change
  }

  // Method to set background music to a specific value (optional)
  @override
  void setBgm(bool value) {
    _bgm = value;
    notifyListeners(); // Notify listeners about the bgm change
  }
}
