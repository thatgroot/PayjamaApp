import 'dart:math';

import 'package:pyjamaapp/services/firebase.dart';

class ReferralSystem {
  final FirestoreService _firestoreService = FirestoreService();
  final int maxReferralLevels = 5;

  // Generate a unique referral code
  String generateReferralCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        8, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }

  // Register a new user with a referral code
  Future<void> registerUser(String? byCode, String newId) async {
    String newReferralCode = generateReferralCode();

    Map<String, dynamic> userData = {
      'userId': newId,
      'referralCode': newReferralCode,
      'referredBy': byCode,
      'referrals': [],
      'rewards': 0,
    };

    await _firestoreService.setDocument('users', newId, userData);
  }
}
