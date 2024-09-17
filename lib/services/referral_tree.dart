import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:math';
import 'dart:developer' as dev;
import 'package:crypto/crypto.dart';

class ReferralTree {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String generateReferralCode(int length) {
    const String chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#\$%^&*()-_=+[]{}|;:,.<>?';
    final Random random = Random.secure();

    // Generate a random salt
    final List<int> salt =
        List<int>.generate(16, (index) => random.nextInt(256));

    // Get the current timestamp
    final int timestamp = DateTime.now().millisecondsSinceEpoch;

    // Combine the salt and timestamp
    final String combined = base64UrlEncode(salt) + timestamp.toString();

    // Generate a SHA-256 hash of the combined string
    final List<int> hashBytes = sha256.convert(utf8.encode(combined)).bytes;

    // Use the hash to generate the referral code by picking characters from the chars set
    final String referralCode = List.generate(
        length,
        (index) =>
            chars[hashBytes[index % hashBytes.length] % chars.length]).join();

    return referralCode;
  }

  Future<String> registerUser(String name) async {
    String refCode = generateReferralCode(7);

    Map<String, dynamic> userData = {
      'userId': refCode,
      'referralCode': refCode,
      "characterName": name,
      'by': "",
      "byParent": ""
    };

    await _firestore.collection('users').doc(refCode).set(userData);

    return refCode;
  }

  Future<void> updateInfo(
      String userId, String wallet, String character) async {
    Map<String, dynamic> userData = {
      'userId': userId,
      "wallet": wallet,
      'character': character,
    };

    await _firestore.collection('users').doc(wallet).set(userData);
  }

  Future<String> addReferral(String by, String myRefCode) async {
    dev.log("by $by");

    var docSnapshot = await _firestore.collection('users').doc(by).get();
    if (!docSnapshot.exists) {
      return "";
    }
    Map<String, dynamic>? data = docSnapshot.data();
    String? byParent = data?['by'];
    String refCode = myRefCode != "" ? myRefCode : generateReferralCode(7);

    DocumentSnapshot<Map<String, dynamic>> doc =
        await _firestore.collection('users').doc(refCode).get();
    if (doc.exists) {
      await _firestore.collection('users').doc(refCode).set({
        'userId': refCode,
        'referralCode': refCode,
        'by': by,
        'byParent': byParent,
      }, SetOptions(merge: true));
    } else {
      await _firestore.collection('users').doc(refCode).set({
        'userId': refCode,
        'referralCode': refCode,
        "characterName": "",
        'by': by,
        'byParent': byParent,
      });
    }

    return refCode;
  }

  Future<List<Map<String, dynamic>>> getReferrals(
      String user, int maxDepth) async {
    List<Map<String, dynamic>> referrals = [];
    Queue<Map<String, dynamic>> queue = Queue();
    queue.add({'user': user, 'depth': 0, 'name': ""});

    while (queue.isNotEmpty) {
      var current = queue.removeFirst();
      String currentUser = current['user'];
      int currentDepth = current['depth'];

      if (currentDepth <= maxDepth) {
        // Get all users invited by the current user
        QuerySnapshot<Map<String, dynamic>> invitedUsersSnapshot =
            await _firestore
                .collection('users')
                .where('by', isEqualTo: currentUser)
                .get();

        for (var doc in invitedUsersSnapshot.docs) {
          String name = doc.get("characterName");
          dev.log("name is $name");
          referrals.add({
            "id": doc.id,
            'userId': currentUser,
            'level': currentDepth + 1,
            "name": name
          });

          queue.add({'user': doc.id, 'depth': currentDepth + 1, "name": name});
        }
      }
    }

    return referrals;
  }

  Future<void> printReferrals(String user, int maxDepth) async {
    List<Map<String, dynamic>> referrals = await getReferrals(user, maxDepth);
    dev.log("Referrals for $user up to depth $maxDepth:");
    for (var referral in referrals) {
      dev.log("User: ${referral['userId']}, Level: ${referral['level']}");
    }
  }
}
