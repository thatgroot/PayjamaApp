import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:pyjamaapp/config.dart';
import 'package:solana/encoder.dart';
import 'package:solana/solana.dart';
// import 'package:solana_mobile_client/solana_mobile_client.dart';

class WalletProvider with ChangeNotifier {
  WalletProvider() {
    // _initializeClient();
  }

  late SolanaClient _solanaClient;

  // // State properties
  // GetCapabilitiesResult? _capabilities;
  // AuthorizationResult? _authorizationResult;
  // bool _isRequestingAirdrop = false;
  // bool _isMainnet = false;

  // // Getters
  // GetCapabilitiesResult? get capabilities => _capabilities;
  // AuthorizationResult? get authorizationResult => _authorizationResult;
  // bool get isRequestingAirdrop => _isRequestingAirdrop;
  // bool get isMainnet => _isMainnet;

  // bool get isAuthorized => _authorizationResult != null;
  // bool get canRequestAirdrop => isAuthorized && !_isRequestingAirdrop;

  // Ed25519HDPublicKey? get publicKey {
  //   final publicKey = _authorizationResult?.publicKey;
  //   if (publicKey == null) return null;

  //   return Ed25519HDPublicKey(publicKey);
  // }

  // String? get address => publicKey?.toBase58();

  // void _initializeClient() {
  //   final rpcUrl =
  //       _isMainnet ? SolanaConfig.mainnetRpcUrl : SolanaConfig.testnetRpcUrl;
  //   final websocketUrl =
  //       _isMainnet ? SolanaConfig.mainnetWsUrl : SolanaConfig.testnetWsUrl;
  //   _solanaClient = SolanaClient(
  //     rpcUrl: Uri.parse(rpcUrl),
  //     websocketUrl: Uri.parse(websocketUrl),
  //   );
  //   notifyListeners();
  // }

  // void updateNetwork({required bool isMainnet}) {
  //   if (_isMainnet == isMainnet) return;
  //   _isMainnet = isMainnet;
  //   _initializeClient();
  //   notifyListeners();
  // }

  // Future<bool> isWalletAvailable() => LocalAssociationScenario.isAvailable();

  // Future<void> requestCapabilities() async {
  //   final session = await LocalAssociationScenario.create();
  //   session.startActivityForResult(null).ignore();
  //   final client = await session.start();
  //   final result = await client.getCapabilities();
  //   await session.close();
  //   _capabilities = result;
  //   notifyListeners();
  // }

  // Future<void> authorize() async {
  //   final session = await LocalAssociationScenario.create();
  //   session.startActivityForResult(null).ignore();
  //   final client = await session.start();
  //   await _doAuthorize(client);
  //   await session.close();
  // }

  // Future<void> reauthorize() async {
  //   final authToken = _authorizationResult?.authToken;
  //   if (authToken == null) return;

  //   final session = await LocalAssociationScenario.create();
  //   session.startActivityForResult(null).ignore();
  //   final client = await session.start();
  //   await _doReauthorize(client);
  //   await session.close();
  // }

  // Future<void> deauthorize() async {
  //   final authToken = _authorizationResult?.authToken;
  //   if (authToken == null) return;

  //   final session = await LocalAssociationScenario.create();
  //   session.startActivityForResult(null).ignore();
  //   final client = await session.start();
  //   await client.deauthorize(authToken: authToken);
  //   await session.close();
  //   _authorizationResult = null;
  //   notifyListeners();
  // }

  // Future<void> requestAirdrop() async {
  //   final publicKey = _authorizationResult?.publicKey;
  //   if (publicKey == null || _isRequestingAirdrop) return;

  //   _isRequestingAirdrop = true;
  //   notifyListeners();

  //   try {
  //     await _solanaClient.requestAirdrop(
  //       address: Ed25519HDPublicKey(publicKey),
  //       lamports: lamportsPerSol,
  //     );
  //   } finally {
  //     _isRequestingAirdrop = false;
  //     notifyListeners();
  //   }
  // }

  // Future<void> signMessages(int number) async {
  //   final session = await LocalAssociationScenario.create();
  //   session.startActivityForResult(null).ignore();
  //   final client = await session.start();
  //   if (await _doReauthorize(client)) {
  //     final signer = publicKey!;
  //     final addresses = [signer.bytes].map(Uint8List.fromList).toList();
  //     final messages = _generateMessages(number: number, signer: signer)
  //         .map((e) => e
  //             .compile(recentBlockhash: '', feePayer: signer)
  //             .toByteArray()
  //             .toList())
  //         .map(Uint8List.fromList)
  //         .toList();

  //     await client.signMessages(messages: messages, addresses: addresses);
  //   }
  //   await session.close();
  // }

  // Future<void> signAndSendTransactions(int number) async {
  //   final session = await LocalAssociationScenario.create();
  //   session.startActivityForResult(null).ignore();
  //   final client = await session.start();
  //   if (await _doReauthorize(client)) {
  //     final signer = publicKey!;
  //     final blockhash = await _solanaClient.rpcClient
  //         .getLatestBlockhash()
  //         .then((it) => it.value.blockhash);
  //     final txs = _generateTransactions(
  //             number: number, signer: signer, blockhash: blockhash)
  //         .map((e) => e.toByteArray().toList())
  //         .map(Uint8List.fromList)
  //         .toList();

  //     await client.signAndSendTransactions(transactions: txs);
  //   }
  //   await session.close();
  // }

  // Future<void> signTransactions(int number) async {
  //   final session = await LocalAssociationScenario.create();
  //   session.startActivityForResult(null).ignore();
  //   final client = await session.start();
  //   if (await _doReauthorize(client)) {
  //     await _doGenerateAndSignTransactions(client, number);
  //   }
  //   await session.close();
  // }

  // Future<void> authorizeAndSignTransactions() async {
  //   final session = await LocalAssociationScenario.create();
  //   session.startActivityForResult(null).ignore();
  //   final client = await session.start();
  //   if (await _doAuthorize(client)) {
  //     await _doGenerateAndSignTransactions(client, 1);
  //   }
  //   await session.close();
  // }

  // Future<void> _doGenerateAndSignTransactions(
  //     MobileWalletAdapterClient client, int number) async {
  //   final signer = publicKey!;
  //   final blockhash = await _solanaClient.rpcClient
  //       .getLatestBlockhash()
  //       .then((it) => it.value.blockhash);
  //   final txs = _generateTransactions(
  //           number: number, signer: signer, blockhash: blockhash)
  //       .map((e) => e.toByteArray().toList())
  //       .map(Uint8List.fromList)
  //       .toList();

  //   await client.signTransactions(transactions: txs);
  // }

  // Future<bool> _doAuthorize(MobileWalletAdapterClient client) async {
  //   final result = await client.authorize(
  //     identityUri: Uri.parse('https://solana.com'),
  //     iconUri: Uri.parse('favicon.ico'),
  //     identityName: 'Solana',
  //     cluster: _isMainnet
  //         ? SolanaConfig.mainnetCluster
  //         : SolanaConfig.testnetCluster,
  //   );

  //   _authorizationResult = result;
  //   notifyListeners();

  //   return result != null;
  // }

  // Future<bool> _doReauthorize(MobileWalletAdapterClient client) async {
  //   final authToken = _authorizationResult?.authToken;
  //   if (authToken == null) return false;

  //   final result = await client.reauthorize(
  //     identityUri: Uri.parse('https://solana.com'),
  //     iconUri: Uri.parse('favicon.ico'),
  //     identityName: 'Solana',
  //     authToken: authToken,
  //   );

  //   _authorizationResult = result;
  //   notifyListeners();

  //   return result != null;
  // }
}

List<SignedTx> _generateTransactions({
  required int number,
  required Ed25519HDPublicKey signer,
  required String blockhash,
}) {
  final instructions = List.generate(
    number,
    (index) => MemoInstruction(signers: [signer], memo: 'Memo #$index'),
  );
  final signature = Signature(List.filled(64, 0), publicKey: signer);

  return instructions
      .map(Message.only)
      .map((e) => SignedTx(
            compiledMessage:
                e.compile(recentBlockhash: blockhash, feePayer: signer),
            signatures: [signature],
          ))
      .toList();
}

List<Message> _generateMessages({
  required int number,
  required Ed25519HDPublicKey signer,
}) =>
    List.generate(
      number,
      (index) => MemoInstruction(signers: [signer], memo: 'Memo #$index'),
    ).map(Message.only).toList();
