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
  Future<void> registerUser(String userId, String? referralCode) async {
    String newReferralCode = generateReferralCode();

    Map<String, dynamic> userData = {
      'userId': userId,
      'referralCode': newReferralCode,
      'referredBy': referralCode,
      'referrals': [],
      'rewards': 0,
    };

    await _firestoreService.setDocument('users', userId, userData);

    if (referralCode != null) {
      await processReferral(referralCode, userId);
    }
  }

  // Process a referral
  Future<void> processReferral(String referralCode, String newUserId) async {
    QuerySnapshot referrerDoc = await _firestoreService
        .queryDocuments(
          'users',
          field: 'referralCode',
          isEqualTo: referralCode,
        )
        .first;

    if (referrerDoc.docs.isEmpty) return;

    String referrerId = referrerDoc.docs.first.id;
    List<String> referralChain = [referrerId];

    await updateReferralChain(referralChain, newUserId, 0);
  }

  // Update the referral chain and distribute rewards
  Future<void> updateReferralChain(
      List<String> referralChain, String newUserId, int level) async {
    if (level >= maxReferralLevels) return;

    String currentReferrerId = referralChain.last;
    DocumentSnapshot referrerDoc =
        await _firestoreService.getDocument('users', currentReferrerId);
    Map<String, dynamic> referrerData =
        referrerDoc.data() as Map<String, dynamic>;

    List<dynamic> referrals = List.from(referrerData['referrals'] ?? []);
    referrals.add(newUserId);

    await _firestoreService.updateDocument('users', currentReferrerId, {
      'referrals': referrals,
    });

    int reward = calculateReward(level);
    await distributeReward(currentReferrerId, reward);

    String? nextReferrerId = referrerData['referredBy'];
    if (nextReferrerId != null) {
      referralChain.add(nextReferrerId);
      await updateReferralChain(referralChain, newUserId, level + 1);
    }
  }

  // Calculate reward based on referral level
  int calculateReward(int level) {
    // Example reward structure: 10 tokens for level 1, 5 for level 2, etc.
    return max(10 - (level * 2), 1);
  }

  // Distribute reward to user
  Future<void> distributeReward(String userId, int reward) async {
    await _firestoreService.performTransaction('users', userId, reward);
  }

  // Get user's referral data
  Future<Map<String, dynamic>> getUserReferralData(String userId) async {
    dev.log("userId $userId -> Referral");
    DocumentSnapshot userDoc =
        await _firestoreService.getDocument('users', userId);
    dev.log("my referals ${userDoc.data()}");
    if (userDoc.data() == null) {
      return {};
    }
    return userDoc.data() as Map<String, dynamic>;
  }

  // Get referral analytics
  Future<Map<String, dynamic>> getReferralAnalytics() async {
    QuerySnapshot usersSnapshot =
        await _firestoreService.getDocuments('users').first;

    int totalReferrals = 0;
    int totalRewardsDistributed = 0;

    for (var doc in usersSnapshot.docs) {
      Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
      totalReferrals += (userData['referrals'] as List).length;
      totalRewardsDistributed += userData['rewards'] as int;
    }

    return {
      'totalUsers': usersSnapshot.docs.length,
      'totalReferrals': totalReferrals,
      'totalRewardsDistributed': totalRewardsDistributed,
    };
  }
}
