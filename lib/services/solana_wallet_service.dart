import 'dart:convert';
import 'dart:developer';

import 'package:pyjamaapp/config.dart';
import 'package:pyjamaapp/config/linking.dart';
import 'package:pyjamaapp/config/solana.dart';
import 'package:pyjamaapp/services/hive.dart';
import 'package:solana/base58.dart';
import 'package:solana/dto.dart' as dto;
import 'package:solana/solana.dart';
import 'package:solana_web3/solana_web3.dart' as web3;
import 'package:solana_web3/programs.dart' as web3_programs;
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

  static SolanaCluster cluster = SolanaConfig.cluster;
  // Create Solana client
  static late SolanaClient client;
  static void init() {
    // _dAppSecretKey = PrivateKey.fromSeed(
    //   Uint8List.fromList(WalletConfig.dAppPrivateKey),
    // );
    _dAppSecretKey = PrivateKey.generate();
    dAppPublicKey = _dAppSecretKey.publicKey;
    log("dapp secret and pubkey:$_dAppSecretKey -> ${base58encode(_dAppSecretKey.publicKey.toUint8List())}");
    client = SolanaClient(
      websocketUrl: cluster == SolanaCluster.devnet
          ? Uri.parse(
              SolanaConfig.devnetWsUrl,
            )
          : Uri.parse(
              SolanaConfig.mainnetWsUrl,
            ),
      rpcUrl: cluster == SolanaCluster.devnet
          ? Uri.parse(
              SolanaConfig.devnetRpcUrl,
            )
          : Uri.parse(
              SolanaConfig.mainnetRpcUrl,
            ),
    );
  }

  // Getters for important information
  String? get sessionToken => _sessionToken;
  static String? get userPublicKey => _userPublicKey;
  WalletConnectionStatus get connectionStatus => _connectionStatus;
  static Map<String, String> _connectParams() {
    return {
      'dapp_encryption_public_key': base58encode(dAppPublicKey.asTypedList),
      'cluster':
          SolanaConfig.cluster == SolanaCluster.devnet ? 'devnet' : 'mainnet',
      'app_url': LinkingConfig.appUrl,
      'redirect_link': '${LinkingConfig.deepLink}${WalletConfig.toConnected}',
    };
  }

  static Map<String, String> _disConnectParams() {
    return {
      'dapp_encryption_public_key': base58encode(dAppPublicKey.asTypedList),
      'cluster':
          SolanaConfig.cluster == SolanaCluster.devnet ? 'devnet' : 'mainnet',
      'app_url': LinkingConfig.appUrl,
      'redirect_link':
          '${LinkingConfig.deepLink}${WalletConfig.toDisConnected}',
    };
  }

  static void connect() {
    var params = _connectParams();
    try {
      Uri uri = Uri(
        scheme: LinkingConfig.scheme,
        host: LinkingConfig.host,
        path: WalletConfig.connect,
        queryParameters: params,
      );

      launchUrl(uri, mode: LaunchMode.externalNonBrowserApplication);
    } catch (e) {
      log('$debugKey $e');
      throw Error.safeToString(e);
    }
  }

  static void disConnect() {
    var params = _disConnectParams();
    try {
      Uri uri = Uri(
        scheme: LinkingConfig.scheme,
        host: LinkingConfig.host,
        path: WalletConfig.disconnect,
        queryParameters: params,
      );

      launchUrl(uri, mode: LaunchMode.externalNonBrowserApplication);
    } catch (e) {
      log('$debugKey $e');
      throw Error.safeToString(e);
    }
  }

  /// Verify and create session after wallet response
  static Future<bool> verifySession(Uri uri) async {
    try {
      Map<String, List<String>> allParams = uri.queryParametersAll;

      String phantomPublicKey = allParams['phantom_encryption_public_key']![0];
      String nonce = allParams['nonce']![0];
      String data = allParams['data']![0];

      await HiveService.setData(
        HiveKeys.phantomEncryptionPublicKey,
        phantomPublicKey,
      );

      await _createSharedSecret();

      final decryptedData = _decryptPayload(data: data, nonce: nonce);

      // Update session details
      _sessionToken = decryptedData['session'];
      _userPublicKey = decryptedData['public_key'];
      _connectionStatus = WalletConnectionStatus.connected;

      await HiveService.setData(HiveKeys.userPublicKey, _userPublicKey);
      await HiveService.setData(HiveKeys.walletSession, _sessionToken);

      return true;
    } catch (e) {
      throw Error.safeToString(e);
    }
  }

  Future<Uri> mintNFT(String toAddress, String redirectTo) async {
    // Get latest blockhash
    final String blockhash = await client.rpcClient
        .getLatestBlockhash()
        .then((b) => b.value.blockhash);

    Ed25519HDPublicKey authorityPubKey = Ed25519HDPublicKey.fromBase58(
        SolanaConfig.mintAuthority.publicKey.toBase58());

    log("$debugKey $authorityPubKey");

    Ed25519HDPublicKey to = Ed25519HDPublicKey.fromBase58(toAddress);

    Ed25519HDPublicKey destination =
        await findAssociatedTokenAddress(toAddress);

    final instructions = [
      AssociatedTokenAccountInstruction.createAccount(
        funder: authorityPubKey,
        address: destination,
        owner: to,
        mint: SolanaConfig.mintAddress,
      ),
      TokenInstruction.mintTo(
        mint: SolanaConfig.mintAddress,
        destination: destination,
        authority: authorityPubKey,
        amount: 1,
      )
    ];

    // Create the message
    final message = Message(
      instructions: instructions,
    );

    final compiledMessage = message.compile(
      recentBlockhash: blockhash,
      feePayer: authorityPubKey,
    );

    // Sign the transaction
    final tx = SignedTx(
      compiledMessage: compiledMessage,
      signatures: [Signature(List.filled(64, 0), publicKey: authorityPubKey)],
    );

    // Generate sign transaction URI
    Uri signUri = await _generateSignTransactionUri(
      transaction: base64.encode(tx.toByteArray().toList()),
      redirect: redirectTo,
    );

    return signUri;
  }

  Future<Ed25519HDPublicKey> findAssociatedTokenAddress(String wallet,
      {String? mint}) async {
    try {
      final Ed25519HDPublicKey walletPubKey =
          Ed25519HDPublicKey.fromBase58(wallet);

      bool has = await client.hasAssociatedTokenAccount(
        owner: walletPubKey,
        mint: SolanaConfig.mintAddress,
      );
      if (has) {
        dto.ProgramAccount? account = await client.getAssociatedTokenAccount(
          owner: walletPubKey,
          mint: mint!.isNotEmpty
              ? Ed25519HDPublicKey.fromBase58(mint)
              : SolanaConfig.mintAddress,
        );
        // log("account data ${account!.account.data!.toJson()}");

        var address = Ed25519HDPublicKey.fromBase58(account!.pubkey);
        log('$debugKey has mint ata $address');
        return address;
      } else {
        // Find PDA for associated token account
        List<Uint8List> seeds = [
          walletPubKey.bytes.toUint8List(),
          SolanaConfig.tokenProgramId.bytes.toUint8List(),
          SolanaConfig.mintAddress.bytes.toUint8List(),
        ];

        // Create the address
        final addressResult = await Ed25519HDPublicKey.findProgramAddress(
          seeds: seeds,
          programId: SolanaConfig.associatedTokenProgramId,
        );

        log('$debugKey not has mint ata $addressResult');
        return addressResult;
      }
    } catch (e) {
      log('$debugKey Error finding associated token address: $e');
      rethrow;
    }
  }

  /// Generate URI for signing a transaction
  Future<Uri> _generateSignTransactionUri({
    required String transaction,
    required String redirect,
  }) async {
    dynamic session = await HiveService.getData(HiveKeys.walletSession);
    var payload = {
      "transaction": transaction,
      "session": session,
    };

    var data = await _encryptPayload(payload);
    var nonce = base58encode(data["nonce"]);
    var dappEncPubKey = base58encode(
      dAppPublicKey.toUint8List(),
    );
    var redirectLink = "${LinkingConfig.deepLink}$redirect";
    return Uri(
      scheme: LinkingConfig.scheme,
      host: LinkingConfig.host,
      path: WalletConfig.signAndSendTransaction,
      // path: '/signTransaction',
      queryParameters: {
        "dapp_encryption_public_key": dappEncPubKey,
        "nonce": nonce,
        'redirect_link': redirectLink,
        'payload': payload
      },
    );
  }

  /// Encrypt payload for Phantom wallet
  Future<Map<String, dynamic>> _encryptPayload(
      Map<String, dynamic> payload) async {
    if (_sharedSecret == null) {
      await _createSharedSecret();
    }

    final nonce = PineNaClUtils.randombytes(24);

    final payloadList = jsonEncode(payload).codeUnits.toUint8List();

    final encryptedPayload = _sharedSecret!
        .encrypt(
          Uint8List.fromList(payloadList),
          nonce: nonce,
        )
        .cipherText;

    return {
      "data": encryptedPayload,
      "nonce": nonce,
    };
  }

  /// Create shared secret for encryption
  static Future<void> _createSharedSecret() async {
    String pubKey =
        await HiveService.getData(HiveKeys.phantomEncryptionPublicKey);
    var theirPublicKey = PublicKey(base58decode(pubKey).toUint8List());
    _sharedSecret = Box(
      myPrivateKey: _dAppSecretKey,
      theirPublicKey: theirPublicKey,
    );
    log('$debugKey Shared Secret created with Remote Public Key');
  }

  static Map<String, dynamic> _decryptPayload({
    required String data,
    required String nonce,
  }) {
    if (_sharedSecret == null) {
      log('$debugKey Shared secret is null');
      return {};
    }

    try {
      // Decode the data and nonce from base58
      final decodedData = base58decode(data);
      final decodedNonce = base58decode(nonce);

      log('$debugKey Decoded data: $decodedData');
      log('$debugKey Decoded nonce: $decodedNonce');

      // Decrypt the data
      final decryptedData = _sharedSecret!.decrypt(
        ByteList(decodedData),
        nonce: Uint8List.fromList(decodedNonce),
      );

      // Convert decrypted data to a readable format
      final jsonData = utf8.decode(decryptedData);
      log('$debugKey Decrypted data: $jsonData');

      return jsonDecode(jsonData);
    } catch (e) {
      log('$debugKey Decryption failed: $e');
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

  Future<void> transferFn() async {
    String payer =
        await HiveService.getData(HiveKeys.phantomEncryptionPublicKey);

    final String blockhash = await client.rpcClient
        .getLatestBlockhash()
        .then((b) => b.value.blockhash);

    var tx = web3.Transaction.v0(
      payer: web3.Pubkey.fromBase58(payer),
      instructions: [
        web3_programs.SystemProgram.transfer(
          fromPubkey: web3.Pubkey.fromBase58(payer),
          toPubkey: web3.Pubkey.fromBase58(payer),
          lamports: lamportsPerSol.toBigInt(),
        )
      ],
      recentBlockhash: blockhash,
    );
    Uint8List serializedTxBytes = tx
        .serialize(
          web3.TransactionSerializableConfig(requireAllSignatures: false),
        )
        .asUint8List();

    final serializedTx = base58encode(serializedTxBytes);
    String session = await HiveService.getData(HiveKeys.walletSession);
    final payloadToEncrypt = {
      'transaction': serializedTx,
      'session': session,
    };
    Map<String, dynamic> encryptedPayload =
        await _encryptPayload(payloadToEncrypt);

    final uri = Uri(
        scheme: LinkingConfig.scheme,
        host: LinkingConfig.host,
        path: WalletConfig.signAndSendTransaction,
        queryParameters: {
          'dapp_encryption_public_key': base58encode(dAppPublicKey.toList()),
          'nonce': base58encode(encryptedPayload['nonce']),
          'redirect_link':
              '${LinkingConfig.deepLink}${WalletConfig.toMarketplace}',
          'payload': base58encode(encryptedPayload['data'])
        });

    await launchUrl(uri, mode: LaunchMode.externalNonBrowserApplication);
  }

  Future<void> transferToken() async {
    String payer =
        await HiveService.getData(HiveKeys.phantomEncryptionPublicKey);

    final String blockhash = await client.rpcClient
        .getLatestBlockhash()
        .then((b) => b.value.blockhash);

    final tokenAccount = web3.Pubkey.fromBase58(
        (await findAssociatedTokenAddress(payer)).toBase58());
    log('$debugKey has account $tokenAccount');

    var createAtaInstruction = web3_programs.AssociatedTokenProgram.create(
      fundingAccount: web3.Pubkey.fromBase58(payer),
      associatedTokenAccount: tokenAccount,
      associatedTokenAccountOwner: web3.Pubkey.fromBase58(payer),
      tokenMint: web3.Pubkey.fromBase58(SolanaConfig.mintAddress.toBase58()),
    );

    var authority = web3.Pubkey.fromBase58(
      SolanaConfig.mintAuthority.publicKey.toBase58(),
    );
    var mint = web3.Pubkey.fromBase58(SolanaConfig.mintAddress.toBase58());
    log("$debugKey authority $authority mint $mint");
// web3_programs.TokenProgram.initializeAccount(account: account, mint: mint, owner: owner)
    var mintoAta = web3_programs.TokenProgram.mintTo(
      mint: mint,
      account: tokenAccount,
      mintAuthority: authority,
      amount: 1.toBigInt(),
    );

    var tx = web3.Transaction.v0(
      payer: web3.Pubkey.fromBase58(payer),
      instructions: [createAtaInstruction, mintoAta],
      recentBlockhash: blockhash,
    );

    Uint8List serializedTxBytes = tx
        .serialize(
          web3.TransactionSerializableConfig(requireAllSignatures: false),
        )
        .asUint8List();

    final serializedTx = base58encode(serializedTxBytes);
    String session = await HiveService.getData(HiveKeys.walletSession);
    final payloadToEncrypt = {
      'transaction': serializedTx,
      'session': session,
    };
    Map<String, dynamic> encryptedPayload =
        await _encryptPayload(payloadToEncrypt);

    final uri = Uri(
        scheme: LinkingConfig.scheme,
        host: LinkingConfig.host,
        path: WalletConfig.signAndSendTransaction,
        queryParameters: {
          'dapp_encryption_public_key': base58encode(dAppPublicKey.toList()),
          'nonce': base58encode(encryptedPayload['nonce']),
          'redirect_link':
              '${LinkingConfig.deepLink}${WalletConfig.toMarketplace}',
          'payload': base58encode(encryptedPayload['data'])
        });

    await launchUrl(uri, mode: LaunchMode.externalNonBrowserApplication);
  }

  Future<void> mintFn() async {
    String payer =
        await HiveService.getData(HiveKeys.phantomEncryptionPublicKey);

    final String blockhash = await client.rpcClient
        .getLatestBlockhash()
        .then((b) => b.value.blockhash);

    final tokenAccount = web3.Pubkey.fromBase58(
        (await findAssociatedTokenAddress(payer)).toBase58());
    log('$debugKey has account $tokenAccount');

    var createAtaInstruction = web3_programs.AssociatedTokenProgram.create(
      fundingAccount: web3.Pubkey.fromBase58(payer),
      associatedTokenAccount: tokenAccount,
      associatedTokenAccountOwner: web3.Pubkey.fromBase58(payer),
      tokenMint: web3.Pubkey.fromBase58(SolanaConfig.mintAddress.toBase58()),
    );

    var authority = web3.Pubkey.fromBase58(
      SolanaConfig.mintAuthority.publicKey.toBase58(),
    );
    var mint = web3.Pubkey.fromBase58(SolanaConfig.mintAddress.toBase58());
    log("$debugKey authority $authority mint $mint");
// web3_programs.TokenProgram.initializeAccount(account: account, mint: mint, owner: owner)
    var mintoAta = web3_programs.TokenProgram.mintTo(
      mint: mint,
      account: tokenAccount,
      mintAuthority: authority,
      amount: 1.toBigInt(),
    );

    var tx = web3.Transaction.v0(
      payer: web3.Pubkey.fromBase58(payer),
      instructions: [createAtaInstruction, mintoAta],
      recentBlockhash: blockhash,
    );

    Uint8List serializedTxBytes = tx
        .serialize(
          web3.TransactionSerializableConfig(requireAllSignatures: false),
        )
        .asUint8List();

    final serializedTx = base58encode(serializedTxBytes);
    String session = await HiveService.getData(HiveKeys.walletSession);
    final payloadToEncrypt = {
      'transaction': serializedTx,
      'session': session,
    };
    Map<String, dynamic> encryptedPayload =
        await _encryptPayload(payloadToEncrypt);

    final uri = Uri(
        scheme: LinkingConfig.scheme,
        host: LinkingConfig.host,
        path: WalletConfig.signAndSendTransaction,
        queryParameters: {
          'dapp_encryption_public_key': base58encode(dAppPublicKey.toList()),
          'nonce': base58encode(encryptedPayload['nonce']),
          'redirect_link':
              '${LinkingConfig.deepLink}${WalletConfig.toMarketplace}',
          'payload': base58encode(encryptedPayload['data'])
        });

    await launchUrl(uri, mode: LaunchMode.externalNonBrowserApplication);
  }

  Future<int> getNFTBalance(String address) async {
    final account = await client.rpcClient.getAccountInfo(address);
    final accountData = account.value!.data!.toJson();
    log('$debugKey account data $accountData');
    return 1;
  }

  Future<int> getTokenBalance(String address) async {
    var tokenAmount = await client.getTokenBalance(
      owner: Ed25519HDPublicKey.fromBase58(address),
      mint: Ed25519HDPublicKey.fromBase58(
          "SMBH3wF6baUj6JWtzYvqcKuj2XCKWDqQxzspY12xPND"),
    );
    if (tokenAmount.amount.isNotEmpty) {
      return int.parse(tokenAmount.amount);
    }
    return 0;
  }
}
