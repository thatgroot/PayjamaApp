import 'dart:convert';
import 'dart:developer';
import 'package:pinenacl/digests.dart';
import 'package:pinenacl/x25519.dart';
import 'package:pinenacl/tweetnacl.dart';
import 'package:pyjama_runner/utils/hive.dart';
import 'package:solana/base58.dart';
import 'package:solana/solana.dart';

/// PhantomConnect allows users to connect to Phantom Wallet from mobile apps.
///
/// This package requires deeplinking to work. For more information about deeplinking,
/// see: https://docs.flutter.dev/development/ui/navigation/deep-linking
class PhantomConnect {
  static const String _scheme = "https";
  static const String _host = "phantom.app";

  final String appUrl;
  final String deepLink;

  static late PrivateKey dAppSecretKey;
  late final PublicKey dAppPublicKey;

  String? _sessionToken;
  late String userPublicKey;
  Box? _sharedSecret;

  PhantomConnect({required this.appUrl, required this.deepLink}) {
    dAppSecretKey = PrivateKey.generate();
    dAppPublicKey = dAppSecretKey.publicKey;
    saveData("dAppSecretKey", dAppSecretKey.toUint8List());
    log("dAppSecretKey ${dAppSecretKey.toUint8List()} -> ${dAppSecretKey.publicKey}");
  }

  Uri generateConnectUri({required String cluster, required String redirect}) {
    return Uri(
      scheme: _scheme,
      host: _host,
      path: '/ul/v1/connect',
      queryParameters: {
        'dapp_encryption_public_key': base58encode(dAppPublicKey.asTypedList),
        'cluster': cluster,
        'app_url': appUrl,
        'redirect_link': "$deepLink$redirect",
      },
    );
  }

  Uri generateSignAndSendTransactionUri({
    required String transaction,
    required String redirect,
  }) {
    final payload = {
      "session": _sessionToken,
      "transaction": base58encode(base64.decode(transaction)),
    };
    final encryptedPayload = _encryptPayload(payload);

    return Uri(
      scheme: _scheme,
      host: _host,
      path: '/ul/v1/signAndSendTransaction',
      queryParameters: {
        "dapp_encryption_public_key": base58encode(dAppPublicKey.asTypedList),
        "nonce": base58encode(encryptedPayload["nonce"]!.toList()),
        'redirect_link': "$deepLink$redirect",
        'payload': base58encode(encryptedPayload["encryptedPayload"]!.toList()),
      },
    );
  }

  Uri generateDisconnectUri({required String redirect}) {
    final payload = {"session": _sessionToken};
    final encryptedPayload = _encryptPayload(payload);

    final uri = Uri(
      scheme: _scheme,
      host: _host,
      path: '/ul/v1/disconnect',
      queryParameters: {
        "dapp_encryption_public_key": base58encode(dAppPublicKey.asTypedList),
        "nonce": base58encode(encryptedPayload["nonce"]!.toList()),
        'redirect_link': "$deepLink$redirect",
        "payload": base58encode(encryptedPayload["encryptedPayload"]!.toList()),
      },
    );
    _sharedSecret = null;
    return uri;
  }

  Uri generateSignTransactionUri({
    required String transaction,
    required String redirect,
  }) {
    final payload = {
      "transaction": base58encode(base64.decode(transaction)),
      "session": _sessionToken,
    };
    final encryptedPayload = _encryptPayload(payload);

    return Uri(
      scheme: _scheme,
      host: _host,
      path: '/ul/v1/signTransaction',
      queryParameters: {
        "dapp_encryption_public_key": base58encode(dAppPublicKey.asTypedList),
        "nonce": base58encode(encryptedPayload["nonce"]!.toList()),
        'redirect_link': "$deepLink$redirect",
        'payload': base58encode(encryptedPayload["encryptedPayload"]!.toList()),
      },
    );
  }

  Uri generateSignAllTransactionsUri({
    required List<String> transactions,
    required String redirect,
  }) {
    final payload = {
      "transactions":
          transactions.map((e) => base58encode(base64.decode(e))).toList(),
      "session": _sessionToken,
    };
    final encryptedPayload = _encryptPayload(payload);

    return Uri(
      scheme: _scheme,
      host: _host,
      path: '/ul/v1/signAllTransactions',
      queryParameters: {
        "dapp_encryption_public_key": base58encode(dAppPublicKey.asTypedList),
        "nonce": base58encode(encryptedPayload["nonce"]!.toList()),
        'redirect_link': "$deepLink$redirect",
        'payload': base58encode(encryptedPayload["encryptedPayload"]!.toList()),
      },
    );
  }

  Uri generateSignMessageUri({
    required Uint8List nonce,
    required String redirect,
  }) {
    final hashedNonce = Hash.sha256(nonce);
    final message =
        "Sign this message for authenticating with your wallet. Nonce: ${base58encode(hashedNonce)}";
    final payload = {
      "session": _sessionToken,
      "message": base58encode(Uint8List.fromList(utf8.encode(message))),
    };

    final encryptedPayload = _encryptPayload(payload);

    return Uri(
      scheme: _scheme,
      host: _host,
      path: 'ul/v1/signMessage',
      queryParameters: {
        "dapp_encryption_public_key": base58encode(dAppPublicKey.asTypedList),
        "nonce": base58encode(encryptedPayload["nonce"]!.toList()),
        "redirect_link": "$deepLink$redirect",
        "payload": base58encode(encryptedPayload["encryptedPayload"]!.toList()),
      },
    );
  }

  bool createSession(Map<String, String> params) {
    try {
      _createSharedSecret(
          base58decode(params["phantom_encryption_public_key"]!).toUint8List());
      final dataDecrypted = _decryptPayload(
        data: params["data"]!,
        nonce: params["nonce"]!,
      );
      _sessionToken = dataDecrypted["session"];
      userPublicKey = dataDecrypted["public_key"];
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isValidSignature(String signature, Uint8List nonce) async {
    final hashedNonce = Hash.sha256(nonce);
    final message =
        "Sign this message for authenticating with your wallet. Nonce: ${base58encode(hashedNonce)}";
    final messageBytes = Uint8List.fromList(utf8.encode(message));
    final signatureBytes = base58decode(signature);
    final verify = await verifySignature(
      message: messageBytes,
      signature: signatureBytes,
      publicKey: Ed25519HDPublicKey.fromBase58(userPublicKey),
    );
    return verify;
  }

  void _createSharedSecret(Uint8List remotePubKey) {
    _sharedSecret = Box(
      myPrivateKey: dAppSecretKey,
      theirPublicKey: PublicKey(remotePubKey),
    );
  }

  Map<String, dynamic> _decryptPayload({
    required String data,
    required String nonce,
  }) {
    if (_sharedSecret == null) {
      return {};
    }

    final decryptedData = _sharedSecret!.decrypt(
      ByteList(base58decode(data)),
      nonce: Uint8List.fromList(base58decode(nonce)),
    );

    return jsonDecode(utf8.decode(decryptedData));
  }

  Map<String, Uint8List> _encryptPayload(Map<String, dynamic> data) {
    if (_sharedSecret == null) {
      return {};
    }
    final nonce = PineNaClUtils.randombytes(24);
    final payload = Uint8List.fromList(utf8.encode(jsonEncode(data)));
    final encryptedPayload =
        _sharedSecret!.encrypt(payload, nonce: nonce).cipherText;
    return {"encryptedPayload": encryptedPayload.asTypedList, "nonce": nonce};
  }
}
