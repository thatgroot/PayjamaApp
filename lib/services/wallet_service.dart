import 'dart:convert';
import 'dart:developer';
import 'package:pinenacl/digests.dart';
import 'package:pinenacl/x25519.dart';
import 'package:pyjamaapp/config.dart';
import 'package:pyjamaapp/utils/hive.dart';
import 'package:solana/base58.dart';

import 'package:solana/dto.dart';
import 'package:solana/solana.dart';
import 'package:solana_web3/buffer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:solana_web3/solana_web3.dart' as web3;
import 'package:solana_web3/programs.dart' as web3_programs;

String debugKey = 'WalletService :: lib/services/wallet_service.dart -> ';

class WalletService {
  static late PrivateKey dAppSecretKey;
  late final PublicKey dAppPublicKey;

  String? _sessionToken;
  late String userPublicKey;
  Box? _sharedSecret;

  WalletService() {
    dAppSecretKey = PrivateKey.generate();
    dAppPublicKey = dAppSecretKey.publicKey;
    saveData('dAppSecretKey', dAppSecretKey.toUint8List());
    log('dAppSecretKey ${dAppSecretKey.toUint8List()} -> ${dAppSecretKey.publicKey}');
  }

  Uri buildUri(String path, Map<String, dynamic> queryParams) {
    return Uri(
      scheme: WalletConfig.scheme,
      host: WalletConfig.host,
      path: path,
      queryParameters: queryParams,
    );
  }

  void connect() {
    try {
      Uri uri = generateConnectUri(
        cluster: WalletConfig.cluster,
        redirect: WalletConfig.connected,
      );
      launchUrl(uri, mode: LaunchMode.externalNonBrowserApplication);
    } catch (e) {
      log('$debugKey $e');
      throw Error.safeToString(e);
    }
  }

  Future<void> buyNftTransaction({
    required String sellerPubkey,
    required String nftPubkey,
    required String receiverPubkey,
  }) async {
    SolanaClient solanaClient = WalletConfig.client();

    web3.Pubkey source =
        await findAssociatedTokenAddress(sellerPubkey, nftPubkey);
    web3.Pubkey destination =
        await findAssociatedTokenAddress(receiverPubkey, nftPubkey);

    // Create the transfer instruction
    final transferInstruction = web3_programs.TokenProgram.transfer(
      source: source,
      destination: destination,
      owner: web3.Pubkey.fromBase58(sellerPubkey),
      amount: BigInt.from(1),
    );

    String recentBlockhash =
        (await solanaClient.rpcClient.getLatestBlockhash()).value.blockhash;

    final transaction = web3.Transaction.v0(
      payer: web3.Pubkey.fromBase58(sellerPubkey),
      recentBlockhash: recentBlockhash,
      instructions: [transferInstruction],
    );

    final Buffer transactionSerialize = transaction.serialize(
      const web3.TransactionSerializableConfig(requireAllSignatures: false),
    );

    final Uri uri = generateSignAndSendTransactionUri(
      transaction: transactionSerialize,
      redirect: "onSignAndSendTransaction",
    );

    // Launch the Phantom wallet
    await launchUrl(uri, mode: LaunchMode.externalNonBrowserApplication);
  }

  Future<web3.Pubkey> findAssociatedTokenAddress(
      String walletAddress, String mintAddress) async {
    SolanaClient solanaClient = WalletConfig.client();

    Ed25519HDPublicKey walletAddressEd25519 =
        Ed25519HDPublicKey.fromBase58(walletAddress);
    Ed25519HDPublicKey mintAddressEd25519 =
        Ed25519HDPublicKey.fromBase58(mintAddress);

    final accounts = await solanaClient.rpcClient.getProgramAccounts(
      SolanaConfig.nftAddress,
      encoding: Encoding.base64,
      filters: [
        const ProgramDataFilter.dataSize(165),
        ProgramDataFilter.memcmp(
          offset: 32,
          bytes: walletAddressEd25519.toByteArray().toList(),
        ),
        ProgramDataFilter.memcmp(
          offset: 0,
          bytes: mintAddressEd25519.toByteArray().toList(),
        ),
      ],
    );

    return web3.Pubkey.fromBase58(accounts.first.pubkey);
  }

  bool createSession(Uri uri) {
    Map<String, String> params = uri.queryParameters;

    try {
      _createSharedSecret(
        base58decode(params['phantom_encryption_public_key']!).toUint8List(),
      );
      final dataDecrypted = _decryptPayload(
        data: params['data']!,
        nonce: params['nonce']!,
      );
      _sessionToken = dataDecrypted['session'];
      userPublicKey = dataDecrypted['public_key'];
      // @TODO : if wallet rejects the transaction in other functions, we need to connect and send the transaction
      saveData("walletSession", _sessionToken);
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
        'app_url': appUrl,
        'redirect_link': '$deepLink$redirect',
      },
    );
  }

  Uri generateSignAndSendTransactionUri(
      {required Buffer transaction, required String redirect}) {
    final payload = {
      'session': _sessionToken,
      'transaction': base58encode(transaction.toList()),
    };
    final encryptedPayload = _encryptPayload(payload);

    return buildUri(
      WalletConfig.signAndSendTransaction,
      {
        'dapp_encryption_public_key': base58encode(dAppPublicKey.asTypedList),
        'nonce': base58encode(encryptedPayload['nonce']!.toList()),
        'redirect_link': '$deepLink$redirect',
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
        'redirect_link': '$deepLink$redirect',
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
        'redirect_link': '$deepLink$redirect',
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
        'redirect_link': '$deepLink$redirect',
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
        'redirect_link': '$deepLink$redirect',
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
    return {'encryptedPayload': encryptedPayload.asTypedList, 'nonce': nonce};
  }
}
