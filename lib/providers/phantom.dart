import 'package:flutter/foundation.dart';
import 'package:solana/solana.dart';

class PhantomWalletProvider extends ChangeNotifier {
  String? _publicKey;
  double _balance = 0.0;
  bool _isConnected = false;

  String? get publicKey => _publicKey;
  double get balance => _balance;
  bool get isConnected => _isConnected;

  void setPublicKey(String publicKey) {
    _publicKey = publicKey;
    _isConnected = true;
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
