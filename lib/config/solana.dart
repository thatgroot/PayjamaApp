import 'package:solana/solana.dart';

enum SolanaCluster { devnet, mainnet }

class SolanaConfig {
  static const SolanaCluster cluster = SolanaCluster.devnet;

  static const String mintAddress =
      '9M2aFRip6H3vL6fLeaagoHXQ2NnRBs6k4JDwYgSkwB6k';

  static const String testnetRpcUrl = 'https://api.testnet.solana.com';
  static const String testnetWsUrl = 'wss://api.testnet.solana.com';
  static const String testnetCluster = 'testnet';
  static const String devnetRpcUrl = 'https://api.devnet.solana.com';
  static const String devnetWsUrl = 'wss://api.devnet.solana.com';
  static const String devnetCluster = 'devnet';
  static const String mainnetRpcUrl = 'https://api.mainnet-beta.solana.com';
  static const String mainnetWsUrl = 'wss://api.mainnet-beta.solana.com';
  static const String mainnetCluster = 'mainnet-beta';

  static SolanaClient client() {
    String rpc = cluster == SolanaCluster.devnet
        ? SolanaConfig.devnetRpcUrl
        : SolanaConfig.mainnetRpcUrl;

    String ws = cluster == SolanaCluster.devnet
        ? SolanaConfig.devnetWsUrl
        : SolanaConfig.mainnetWsUrl;

    SolanaClient solanaClient = SolanaClient(
      rpcUrl: Uri.parse(rpc),
      websocketUrl: Uri.parse(ws),
    );
    return solanaClient;
  }
}
