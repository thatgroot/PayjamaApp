import 'dart:developer' as dev;
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pyjama_runner/services/firebase.dart';

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
  Future<void> registerUser(String? by_code, String newId) async {
    String newReferralCode = generateReferralCode();

    Map<String, dynamic> userData = {
      'userId': newId,
      'referralCode': newReferralCode,
      'referredBy': by_code,
      'referrals': [],
      'rewards': 0,
    };

    await _firestoreService.setDocument('users', newId, userData);
  }
}
