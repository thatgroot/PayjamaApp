import 'dart:convert';
import 'dart:developer';
import 'package:pinenacl/digests.dart';
import 'package:pinenacl/x25519.dart';
import 'package:provider/provider.dart';
import 'package:pyjamaapp/config.dart';
import 'package:pyjamaapp/config/linking.dart';
import 'package:pyjamaapp/config/solana.dart';
import 'package:pyjamaapp/providers/wallet.dart';
import 'package:pyjamaapp/screens/wallet_screen.dart';
import 'package:pyjamaapp/services/context_utility.dart';
import 'package:pyjamaapp/services/hive.dart';
import 'package:pyjamaapp/utils/navigation.dart';
import 'package:solana/base58.dart';

import 'package:solana/encoder.dart';
import 'package:solana/solana.dart';
import 'package:url_launcher/url_launcher.dart';

String debugKey = 'lib/services/wallet_service.dart -> ';

class WalletService {
  static late PrivateKey dAppSecretKey;
  late final PublicKey dAppPublicKey;

  String? _sessionToken;
  late String userPublicKey;
  Box? _sharedSecret;
  WalletProvider? _walletProvider;

  WalletService() {
    dAppSecretKey = PrivateKey.generate();
    dAppPublicKey = dAppSecretKey.publicKey;
    HiveService.setData(HiveKeys.dAppSecretKey, dAppSecretKey.toUint8List());
    log('dAppSecretKey ${dAppSecretKey.toUint8List()} -> ${dAppSecretKey.publicKey}');
  }

  Uri buildUri(String path, Map<String, dynamic> queryParams) {
    return Uri(
      scheme: LinkingConfig.scheme,
      host: LinkingConfig.host,
      path: path,
      queryParameters: queryParams,
    );
  }

  void connect() {
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

  Future<void> buyNftTransaction({
    required String sellerPubkey,
    required String receiverPubkey,
  }) async {
    try {
      SolanaClient solanaClient = SolanaConfig.client();

      Ed25519HDPublicKey source =
          await findAssociatedTokenAddress(sellerPubkey);
      Ed25519HDPublicKey destination =
          await findAssociatedTokenAddress(receiverPubkey);

      // Create the transfer instruction
      final instruction = TokenInstruction.transfer(
        source: source,
        destination: destination,
        owner: Ed25519HDPublicKey.fromBase58(sellerPubkey),
        amount: 100 * lamportsPerSol, // NFT transfer amount is typically 1
      );

      // Get the latest blockhash
      String recentBlockhash =
          (await solanaClient.rpcClient.getLatestBlockhash()).value.blockhash;

      // Create and compile the message
      final Message message = Message(instructions: [instruction]);
      final CompiledMessage compiledMessage = message.compile(
        recentBlockhash: recentBlockhash,
        feePayer: Ed25519HDPublicKey.fromBase58(sellerPubkey),
      );

      // Create the transaction
      final SignedTx transaction = SignedTx(
        signatures: [],
        compiledMessage: compiledMessage,
      );

      // Serialize the transaction
      final Uint8List serializedTransaction =
          Uint8List.fromList(transaction.toByteArray().toList());

      // Generate URI for wallet interaction
      final Uri uri = generateSignAndSendTransactionUri(
        transaction: serializedTransaction,
        redirect: "onSignAndSendTransaction",
      );

      // Launch the external wallet
      await launchUrl(
        uri,
        mode: LaunchMode.externalNonBrowserApplication,
      );
    } catch (e) {
      log('$debugKey Error in buyNftTransaction: $e');
      rethrow;
    }
  }

  Future<Ed25519HDPublicKey> findAssociatedTokenAddress(
      String walletAddress) async {
    try {
      final Ed25519HDPublicKey walletPubKey =
          Ed25519HDPublicKey.fromBase58(walletAddress);
      final Ed25519HDPublicKey mintPubKey = SolanaConfig.mintAddress;

      // SPL Associated Token Account Program ID
      final Ed25519HDPublicKey associatedTokenProgramId =
          Ed25519HDPublicKey.fromBase58(
              'ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJA8knL');

      // SPL Token Program ID
      final Ed25519HDPublicKey tokenProgramId = Ed25519HDPublicKey.fromBase58(
          'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA');

      // Find PDA for associated token account
      List<List<int>> seeds = [
        walletPubKey.toByteArray().toList(),
        tokenProgramId.toByteArray().toList(),
        mintPubKey.toByteArray().toList(),
      ];

      // Create the address
      final addressResult = await Ed25519HDPublicKey.findProgramAddress(
        seeds: seeds,
        programId: associatedTokenProgramId,
      );

      return addressResult;
    } catch (e) {
      log('$debugKey Error finding associated token address: $e');
      rethrow;
    }
  }

  bool createSession(Uri uri) {
    _walletProvider =
        Provider.of<WalletProvider>(ContextUtility.context!, listen: false);

    Map<String, String> params = uri.queryParameters;
    log("phantom params $params");
    String encPubkey = "${params['phantom_encryption_public_key']}";
    _walletProvider!.setPhantomEncryptionPubliKey(encPubkey);
    try {
      _createSharedSecret(encPubkey);
      final dataDecrypted = _decryptPayload(
        data: params['data']!,
        nonce: params['nonce']!,
      );
      _walletProvider!.setSessionToken(dataDecrypted['session']);

      _sessionToken = dataDecrypted['session'];

      userPublicKey = dataDecrypted['public_key'];
      HiveService.setData(HiveKeys.walletSession, _sessionToken);
      log('$debugKey session token $_sessionToken publick key $userPublicKey');
      return true;
    } catch (e) {
      log('phantom error $e');
      return false;
    }
  }

  Uri generateConnectUri(
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

  Uri generateSignAndSendTransactionUri({
    required Uint8List transaction,
    required String redirect,
  }) {
    _walletProvider ??=
        Provider.of<WalletProvider>(ContextUtility.context!, listen: false);
    if (_sessionToken == null) {
      _sessionToken = _walletProvider!.sessionToken;
      log('$debugKey _sessionToken is null $_sessionToken');
    }

    final payload = {
      'session': _sessionToken,
      'transaction': base58encode(transaction.toList()),
    };
    final encryptedPayload = _encryptPayload(payload);

    if (encryptedPayload['nonce'] == null) {
      log('$debugKey nonce is null');
    }
    if (encryptedPayload['encryptedPayload'] == null) {
      log('$debugKey encryptedPayload is null');
    }

    log("payload   $payload");
    log("encryptedPayload   $encryptedPayload");

    return buildUri(
      WalletConfig.signAndSendTransaction,
      {
        'dapp_encryption_public_key': base58encode(dAppPublicKey.asTypedList),
        'nonce': base58encode(encryptedPayload['nonce']!.toList()),
        'redirect_link': '${LinkingConfig.deepLink}$redirect',
        'payload': base58encode(encryptedPayload['encryptedPayload']!.toList()),
      },
    );
  }

  Uri generateDisconnectUri({required String redirect}) {
    final payload = {'session': _sessionToken};
    final encryptedPayload = _encryptPayload(payload);

    _sharedSecret = null;
    return buildUri(
      WalletConfig.disconnect,
      {
        'dapp_encryption_public_key': base58encode(dAppPublicKey.asTypedList),
        'nonce': base58encode(encryptedPayload['nonce']!.toList()),
        'redirect_link': '${LinkingConfig.deepLink}$redirect',
        'payload': base58encode(encryptedPayload['encryptedPayload']!.toList()),
      },
    );
  }

  Uri generateSignTransactionUri(
      {required String transaction, required String redirect}) {
    final payload = {
      'transaction': base58encode(base64.decode(transaction)),
      'session': _sessionToken,
    };
    final encryptedPayload = _encryptPayload(payload);

    return buildUri(
      WalletConfig.signTransaction,
      {
        'dapp_encryption_public_key': base58encode(dAppPublicKey.asTypedList),
        'nonce': base58encode(encryptedPayload['nonce']!.toList()),
        'redirect_link': '${LinkingConfig.deepLink}$redirect',
        'payload': base58encode(encryptedPayload['encryptedPayload']!.toList()),
      },
    );
  }

  Uri generateSignAllTransactionsUri(
      {required List<String> transactions, required String redirect}) {
    final payload = {
      'transactions':
          transactions.map((e) => base58encode(base64.decode(e))).toList(),
      'session': _sessionToken,
    };
    final encryptedPayload = _encryptPayload(payload);

    return buildUri(
      WalletConfig.signAllTransactions,
      {
        'dapp_encryption_public_key': base58encode(dAppPublicKey.asTypedList),
        'nonce': base58encode(encryptedPayload['nonce']!.toList()),
        'redirect_link': '${LinkingConfig.deepLink}$redirect',
        'payload': base58encode(encryptedPayload['encryptedPayload']!.toList()),
      },
    );
  }

  Uri generateSignMessageUri(
      {required Uint8List nonce, required String redirect}) {
    final hashedNonce = Hash.sha256(nonce);
    final message =
        'Sign this message for authenticating with your wallet. Nonce: ${base58encode(hashedNonce)}';
    final payload = {
      'session': _sessionToken,
      'message': base58encode(Uint8List.fromList(utf8.encode(message))),
    };

    final encryptedPayload = _encryptPayload(payload);

    return buildUri(
      WalletConfig.signMessage,
      {
        'dapp_encryption_public_key': base58encode(dAppPublicKey.asTypedList),
        'nonce': base58encode(encryptedPayload['nonce']!.toList()),
        'redirect_link': '${LinkingConfig.deepLink}$redirect',
        'payload': base58encode(encryptedPayload['encryptedPayload']!.toList()),
      },
    );
  }

  Future<bool> isValidSignature(String signature, Uint8List nonce) async {
    final hashedNonce = Hash.sha256(nonce);
    final message =
        'Sign this message for authenticating with your wallet. Nonce: ${base58encode(hashedNonce)}';
    final messageBytes = Uint8List.fromList(utf8.encode(message));
    final signatureBytes = base58decode(signature);
    final verify = await verifySignature(
      message: messageBytes,
      signature: signatureBytes,
      publicKey: Ed25519HDPublicKey.fromBase58(userPublicKey),
    );
    return verify;
  }

  void _createSharedSecret(String remotePubKey) {
    log("remotePubKey $remotePubKey");

    _sharedSecret = Box(
      myPrivateKey: dAppSecretKey,
      theirPublicKey: PublicKey.decode(remotePubKey.toUpperCase()).publicKey,
    );
    _walletProvider!.setSharedSecret(_sharedSecret!);
  }

  Map<String, dynamic> _decryptPayload({
    required String data,
    required String nonce,
  }) {
    final decryptedData = _sharedSecret!.decrypt(
      ByteList(base58decode(data)),
      nonce: Uint8List.fromList(base58decode(nonce)),
    );

    return jsonDecode(utf8.decode(decryptedData));
  }

  Map<String, Uint8List> _encryptPayload(Map<String, dynamic> data) {
    if (_sharedSecret == null) {
      to(ContextUtility.context!, WalletScreen.route);
      // throw Exception('Shared secret is null');
      return {};
    } else {
      final nonce = PineNaClUtils.randombytes(24);
      final payload = Uint8List.fromList(utf8.encode(jsonEncode(data)));
      final encryptedPayload =
          _sharedSecret!.encrypt(payload, nonce: nonce).cipherText;
      return {'encryptedPayload': encryptedPayload.asTypedList, 'nonce': nonce};
    }
  }
}
