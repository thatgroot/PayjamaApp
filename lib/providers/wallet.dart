import 'package:flutter/foundation.dart';
import 'package:pinenacl/x25519.dart';
import 'package:solana/solana.dart';

class WalletProvider extends ChangeNotifier {
  String? _publicKey;
  double _balance = 0.0;
  bool _isConnected = false;

  String? _sessionToken;
  String? _phantomEncryptionPubliKey;
  Box? _sharedSecret;

  String? get publicKey => _publicKey;

  String? get sessionToken => _sessionToken;
  String? get phantomEncryptionPubliKey => _phantomEncryptionPubliKey;
  Box? get sharedSecret => _sharedSecret;

  double get balance => _balance;
  bool get isConnected => _isConnected;

  void setPublicKey(String publicKey) {
    _publicKey = publicKey;
    _isConnected = true;
    notifyListeners();
  }

  void setSharedSecret(Box secret) {
    _sharedSecret = secret;
    notifyListeners();
  }

  void setSessionToken(String token) {
    _sessionToken = token;
    notifyListeners();
  }

  void setPhantomEncryptionPubliKey(String key) {
    _phantomEncryptionPubliKey = key;
    notifyListeners();
  }

  void disconnect() {
    _publicKey = null;
    _balance = 0.0;
    _isConnected = false;
    notifyListeners();
  }

  Future<void> fetchBalance() async {
    if (_publicKey != null) {
      final solana = SolanaClient(
        rpcUrl: Uri.parse('https://api.mainnet-beta.solana.com'),
        websocketUrl: Uri.parse('wss://api.mainnet-beta.solana.com'),
      );

      final balance = await solana.rpcClient.getBalance(
        _publicKey!,
      );

      _balance = balance.value / lamportsPerSol;
      notifyListeners();
    }
  }
}
