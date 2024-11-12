import 'package:solana/solana.dart';

enum SolanaCluster { devnet, mainnet }

class SolanaConfig {
  static const SolanaCluster cluster = SolanaCluster.devnet;

  static final Ed25519HDKeyPairData mintAuthority = Ed25519HDKeyPairData(
    [
      151,
      149,
      147,
      187,
      241,
      213,
      24,
      128,
      81,
      85,
      21,
      172,
      162,
      213,
      99,
      178,
      206,
      69,
      65,
      124,
      57,
      221,
      167,
      113,
      219,
      84,
      187,
      102,
      244,
      106,
      21,
      55,
      246,
      244,
      202,
      225,
      103,
      210,
      90,
      164,
      245,
      42,
      147,
      22,
      4,
      20,
      209,
      4,
      113,
      191,
      75,
      51,
      138,
      213,
      53,
      126,
      244,
      190,
      110,
      244,
      41,
      59,
      87,
      233
    ],
    publicKey: Ed25519HDPublicKey.fromBase58(
      "DRVYE7jgT3Kh2dsNXBz3X4rq2p5vPsJtugbd9Qod8VDP",
    ),
  );

  static Future<Ed25519HDKeyPair> getAuthorityPk() async {
    return await Ed25519HDKeyPair.fromPrivateKeyBytes(privateKey: [
      151,
      149,
      147,
      187,
      241,
      213,
      24,
      128,
      81,
      85,
      21,
      172,
      162,
      213,
      99,
      178,
      206,
      69,
      65,
      124,
      57,
      221,
      167,
      113,
      219,
      84,
      187,
      102,
      244,
      106,
      21,
      55,
      246,
      244,
      202,
      225,
      103,
      210,
      90,
      164,
      245,
      42,
      147,
      22,
      4,
      20,
      209,
      4,
      113,
      191,
      75,
      51,
      138,
      213,
      53,
      126,
      244,
      190,
      110,
      244,
      41,
      59,
      87,
      233
    ]);
  }

  static final Ed25519HDPublicKey mintAddress = Ed25519HDPublicKey.fromBase58(
    "5yKJNHyND6xNED6UmQ9MgK3HgNcjtuPXyiqCimndzvDU",
  );

  // SPL Associated Token Account Program ID
  static final Ed25519HDPublicKey associatedTokenProgramId =
      Ed25519HDPublicKey.fromBase58(
    'ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJA8knL',
  );

  // SPL Token Program ID
  static final Ed25519HDPublicKey tokenProgramId =
      Ed25519HDPublicKey.fromBase58(
    'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA',
  );

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
