import 'package:flutter/material.dart';
import 'package:pyjama_runner/services/firebase.dart';
import 'package:pyjama_runner/services/referral.dart';
import 'package:pyjama_runner/services/referral_tree.dart';
import 'package:pyjama_runner/utils/hive.dart';
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
      saveData("name", name);
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
