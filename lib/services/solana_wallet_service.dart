import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:pyjamaapp/config.dart';
import 'package:pyjamaapp/config/linking.dart';
import 'package:pyjamaapp/config/solana.dart';
import 'package:solana/base58.dart';
import 'package:solana/solana.dart';
import 'package:solana/encoder.dart';
import 'package:pinenacl/x25519.dart';
import 'package:url_launcher/url_launcher.dart';

String debugKey = 'lib/services/solana_wallet_service.dart -> ';

enum WalletConnectionStatus { disconnected, connecting, connected, error }

class SolanaWalletService {
  static late PrivateKey _dAppSecretKey;
  static late PublicKey dAppPublicKey;
  static Box? _sharedSecret;

  static String? _sessionToken;
  static String? _userPublicKey;
  static WalletConnectionStatus _connectionStatus =
      WalletConnectionStatus.disconnected;

  late SolanaCluster cluster = SolanaConfig.cluster;

  static void init() {
    _dAppSecretKey = PrivateKey.generate();
    dAppPublicKey = _dAppSecretKey.publicKey;
    log('dApp Secret Key: ${base58encode(_dAppSecretKey.asTypedList)}');
    log('dApp Public Key: ${base58encode(dAppPublicKey.asTypedList)}');
  }

  // Getters for important information
  String? get sessionToken => _sessionToken;
  static String? get userPublicKey => _userPublicKey;
  WalletConnectionStatus get connectionStatus => _connectionStatus;
  static void connect() {
    try {
      Uri uri = generateConnectUri(
        cluster: SolanaConfig.cluster,
        redirect: WalletConfig.toConnected,
      );
      launchUrl(uri, mode: LaunchMode.externalNonBrowserApplication);
    } catch (e) {
      log('$debugKey $e');
      throw Error.safeToString(e);
    }
  }

  static Uri generateConnectUri(
      {required SolanaCluster cluster, required String redirect}) {
    return buildUri(
      WalletConfig.connect,
      {
        'dapp_encryption_public_key': base58encode(dAppPublicKey.asTypedList),
        'cluster': cluster == SolanaCluster.devnet ? 'devnet' : 'mainnet',
        'app_url': LinkingConfig.appUrl,
        'redirect_link': '${LinkingConfig.deepLink}$redirect',
      },
    );
  }

  static Uri buildUri(String path, Map<String, dynamic> queryParams) {
    return Uri(
      scheme: LinkingConfig.scheme,
      host: LinkingConfig.host,
      path: path,
      queryParameters: queryParams,
    );
  }

  /// Verify and create session after wallet response
  static bool verifySession(Uri uri) {
    try {
      Map<String, List<String>> allParams = uri.queryParametersAll;

      log("all query params $allParams");
      // Validate required parameters
      // _connectionStatus = WalletConnectionStatus.error;

      String phantomPublicKey = allParams['phantom_encryption_public_key']![0];
      String nonce = allParams['nonce']![0];
      String data = allParams['data']![0];

      // Create shared secret
      _createSharedSecret(base58decode(phantomPublicKey).toUint8List());

      // Decrypt payload
      final decryptedData = _decryptPayload(data: data, nonce: nonce);

      // Update session details
      _sessionToken = decryptedData['session'];
      _userPublicKey = decryptedData['public_key'];
      _connectionStatus = WalletConnectionStatus.connected;

      log('Session created: $_sessionToken');
      log('User Public Key: $_userPublicKey');

      return true;
    } catch (e) {
      log('Session verification failed: $e');
      _connectionStatus = WalletConnectionStatus.error;
      return false;
    }
  }

  /// Validate session parameters
  bool _validateSessionParameters(Map<String, List<String>> allParams) {
    return allParams.containsKey('phantom_encryption_public_key') &&
        allParams.containsKey('data') &&
        allParams.containsKey('nonce');
  }

  /// Transfer SOL tokens with enhanced error handling
  Future<TransactionResult> transferSOL({
    required String from,
    required String to,
    required int amount,
    String? feePayer,
  }) async {
    if (_connectionStatus != WalletConnectionStatus.connected) {
      return TransactionResult.error('Wallet not connected');
    }

    try {
      // Validate wallet addresses
      Ed25519HDPublicKey fromPubKey = Ed25519HDPublicKey.fromBase58(from);
      Ed25519HDPublicKey toPubKey = Ed25519HDPublicKey.fromBase58(to);
      Ed25519HDPublicKey feePayerKey = feePayer != null
          ? Ed25519HDPublicKey.fromBase58(feePayer)
          : fromPubKey;

      // Create Solana client
      SolanaClient client = SolanaClient(
        websocketUrl: cluster == SolanaCluster.devnet
            ? Uri.parse(SolanaConfig.devnetWsUrl)
            : Uri.parse(
                SolanaConfig.mainnetWsUrl,
              ),
        rpcUrl: cluster == SolanaCluster.devnet
            ? Uri.parse(SolanaConfig.devnetRpcUrl)
            : Uri.parse(SolanaConfig.mainnetRpcUrl),
      );

      // Prepare transfer instruction
      final transfer = SystemInstruction.transfer(
        fundingAccount: fromPubKey,
        recipientAccount: toPubKey,
        lamports: amount * lamportsPerSol,
      );

      // Get latest blockhash
      final String blockhash = await client.rpcClient
          .getLatestBlockhash()
          .then((b) => b.value.blockhash);

      // Compile message
      final message = Message.only(transfer);
      final compiledMessage = message.compile(
        recentBlockhash: blockhash,
        feePayer: feePayerKey,
      );

      // Prepare transaction for signing
      final tx = SignedTx(
        compiledMessage: compiledMessage,
        signatures: [Signature(List.filled(64, 0), publicKey: fromPubKey)],
      );

      // Generate sign transaction URI
      Uri signUri = _generateSignTransactionUri(
        transaction: tx.encode(),
        redirect: '/transaction-completed',
      );

      return TransactionResult.pending(signUri);
    } catch (e) {
      log('Transfer error: $e');
      return TransactionResult.error(e.toString());
    }
  }

  /// Generate URI for signing a transaction
  Uri _generateSignTransactionUri({
    required String transaction,
    required String redirect,
  }) {
    var payload = {
      "transaction": base58encode(
        Uint8List.fromList(base64.decode(transaction)),
      ),
      "session": _sessionToken,
    };
    var encryptedPayload = _encryptPayload(payload);

    return Uri(
      scheme: LinkingConfig.scheme,
      host: LinkingConfig.host,
      path: '/signTransaction',
      queryParameters: {
        "dapp_encryption_public_key": base58encode(dAppPublicKey.asTypedList),
        "nonce": base58encode(encryptedPayload["nonce"]),
        'redirect_link': "${LinkingConfig.deepLink}$redirect",
        'payload': base58encode(encryptedPayload["encryptedPayload"])
      },
    );
  }

  /// Encrypt payload for Phantom wallet
  Map<String, dynamic> _encryptPayload(Map<String, dynamic> data) {
    if (_sharedSecret == null) {
      throw Exception("Shared secret not initialized");
    }

    final nonce = PineNaClUtils.randombytes(24);
    final payload = Uint8List.fromList(utf8.encode(jsonEncode(data)));

    final encryptedPayload = _sharedSecret!
        .encrypt(
          Uint8List.fromList(payload),
          nonce: nonce,
        )
        .cipherText;

    return {
      "encryptedPayload": encryptedPayload.asTypedList,
      "nonce": nonce,
    };
  }

  /// Create shared secret for encryption
  static void _createSharedSecret(Uint8List remotePubKey) {
    log('Remote Public Key: ${base58encode(remotePubKey)}');
    _sharedSecret = Box(
      myPrivateKey: _dAppSecretKey,
      theirPublicKey: PublicKey(remotePubKey),
    );
    log('Shared Secret created with Remote Public Key');
  }

  static Map<String, dynamic> _decryptPayload({
    required String data,
    required String nonce,
  }) {
    if (_sharedSecret == null) {
      log('Shared secret is null');
      return {};
    }

    try {
      // Decode the data and nonce from base58
      final decodedData = base58decode(data);
      final decodedNonce = base58decode(nonce);

      log('Decoded data: $decodedData');
      log('Decoded nonce: $decodedNonce');

      // Decrypt the data
      final decryptedData = _sharedSecret!.decrypt(
        ByteList(decodedData),
        nonce: Uint8List.fromList(decodedNonce),
      );

      // Convert decrypted data to a readable format
      final jsonData = utf8.decode(decryptedData);
      log('Decrypted data: $jsonData');

      return jsonDecode(jsonData);
    } catch (e) {
      log('Decryption failed: $e');
      return {};
    }
  }

  /// Disconnect wallet and reset session
  void disconnect() {
    _sessionToken = null;
    _userPublicKey = null;
    _sharedSecret = null;
    _connectionStatus = WalletConnectionStatus.disconnected;
  }
}

/// Transaction result class for better transaction handling
class TransactionResult {
  final String status;
  final dynamic data;

  TransactionResult._(this.status, this.data);

  factory TransactionResult.pending(Uri signUri) =>
      TransactionResult._('pending', signUri);

  factory TransactionResult.error(String message) =>
      TransactionResult._('error', message);

  factory TransactionResult.success(String txId) =>
      TransactionResult._('success', txId);
}
