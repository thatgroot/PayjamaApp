import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pyjama_runner/services/referral.dart';
import 'package:share_plus/share_plus.dart';

class ReferralProvider extends ChangeNotifier {
  final ReferralSystem _referralSystem = ReferralSystem();
  List<Map<String, dynamic>> _referrals = [];
  String _referralCode = '';
  int _totalEarnings = 0;

  List<Map<String, dynamic>> get referrals => _referrals;
  String get referralCode => _referralCode;
  int get totalEarnings => _totalEarnings;

  Future<void> loadReferralData(String userId) async {
    var userData = await _referralSystem.getUserReferralData(userId);
    if (userData['referralCode'] == null) {
      return;
    }
    _referralCode = userData['referralCode'];
    log("referrals: $userData['referrals']");
    _referrals = List<Map<String, dynamic>>.from(userData['referrals']);
    _totalEarnings = userData['rewards'];
    notifyListeners();
  }

  Future<void> shareReferralCode() async {
    await Share.share(
        'Join Pyjama Runner using my referral code: $_referralCode');
  }
}

class ReferralJoinProvider extends ChangeNotifier {
  final ReferralSystem _referralSystem = ReferralSystem();
  bool _isLoading = false;
  String _errorMessage = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<bool> joinWithReferralCode(String userId, String referralCode) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await _referralSystem.registerUser(userId, referralCode);
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
