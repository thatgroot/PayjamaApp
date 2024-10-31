import 'dart:convert';
import 'dart:developer';

import 'package:pinenacl/ed25519.dart';
import 'package:solana/base58.dart';

class PhantomSessionHandler {
  late SigningKey _dAppSigningKey;
  late VerifyKey dAppVerifyKey;
  String? _sessionToken;

  PhantomSessionHandler() {
    // Generate signing keypair for the dApp
    _dAppSigningKey = SigningKey.generate();
    dAppVerifyKey = _dAppSigningKey.verifyKey;
  }

  /// Verify and decode a session received from Phantom
  dynamic verifyAndDecodeSession(Map<String, String> params) {
    try {
      log("Verifying session with params: $params");

      if (!params.containsKey("data")) {
        throw Exception("Missing session data");
      }

      // Decode the base58 session data
      final sessionBytes = base58decode(params["data"]!);
      log("Decoded session length: ${sessionBytes.length}");

      // The first 64 bytes are the signature, the rest is the message
      if (sessionBytes.length <= 64) {
        throw Exception("Invalid session data length");
      }

      final signature = sessionBytes.sublist(0, 64);
      final message = sessionBytes.sublist(64);

      log("Signature length: ${signature.length}");
      log("Message length: ${message.length}");

      try {
        // Convert the received data to the format PineNaCl expects
        final signedMessage = SignedMessage(
          signature: Signature(Uint8List.fromList(signature)),
          message: Uint8List.fromList(message),
        );

        // Create verify key from Phantom's public key
        final phantomPublicKey =
            base58decode(params["phantom_encryption_public_key"]!);
        final verifyKey = VerifyKey(Uint8List.fromList(phantomPublicKey));

        // Verify the signature and get the original message

        verifyKey.verifySignedMessage(signedMessage: signedMessage);

        // Decode the verified message as UTF-8 JSON
        final decodedJson = utf8.decode(signedMessage.message);
        log("Decoded session JSON: $decodedJson");

        final sessionData = jsonDecode(decodedJson);

        // Validate session data structure
        if (!_validateSessionData(sessionData)) {
          throw Exception("Invalid session data structure");
        }

        // Store session token
        _sessionToken = params["data"];
        // String userPublicKey = params["public_key"] ?? "";

        log("Session verified successfully");
        return sessionData;
      } catch (e) {
        log("Signature verification failed: $e");
        throw Exception("Invalid signature");
      }
    } catch (e, stackTrace) {
      log("Session verification failed: $e");
      log("Stack trace: $stackTrace");
      return null;
    }
  }

  /// Create a new session
  String createSession({
    required String appUrl,
    String chain = "solana",
    String cluster = "mainnet-beta",
  }) {
    try {
      final sessionData = {
        "app_url": appUrl,
        "chain": chain,
        "cluster": cluster,
        "timestamp": DateTime.now().millisecondsSinceEpoch ~/ 1000,
      };

      final jsonData = jsonEncode(sessionData);
      final messageBytes = Uint8List.fromList(utf8.encode(jsonData));

      // Sign the message
      final signedMessage = _dAppSigningKey.sign(messageBytes);

      // Combine signature and message in Phantom's format
      final combinedBytes = Uint8List.fromList([
        ...signedMessage.signature.toUint8List(),
        ...messageBytes,
      ]);

      // Encode to base58
      return base58encode(combinedBytes);
    } catch (e, stackTrace) {
      log("Failed to create session: $e");
      log("Stack trace: $stackTrace");
      throw Exception("Failed to create session: $e");
    }
  }

  bool _validateSessionData(Map<String, dynamic> sessionData) {
    return sessionData.containsKey("app_url") &&
        sessionData.containsKey("chain") &&
        sessionData.containsKey("timestamp");
  }

  String? get sessionToken => _sessionToken;

  /// Get the dApp's public key in base58 format
  String get dAppPublicKeyBase58 => base58encode(dAppVerifyKey.toUint8List());
}
