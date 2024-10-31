import 'package:flutter/material.dart';
import 'package:pyjamaapp/services/solana_wallet_service.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});
  static String route = "/wallet";

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  void initState() {
    SolanaWalletService.init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.00, -1.00),
            end: Alignment(0, 1),
            colors: [Color(0xFF24243E), Color(0xFF302B63), Color(0xFF0F0C29)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.only(bottom: 0.0, right: 32.0),
                child: Image.asset(
                  'assets/images/pyjama/pyjama-character.png',
                  width: 241,
                  height: 210,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'PyjamaCoin',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w500,
                      height: 0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Please connect your wallet',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w300,
                      height: 0,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () {
                      SolanaWalletService.connect();
                    },
                    child: SizedBox(
                      width: 272,
                      height: 39,
                      child: Image.asset(
                        'assets/icons/wallet-connect-button.png',
                      ),
                    ),
                  ),
                ],
              ),
              // wallet-connect-button
            ],
          ),
        ),
      ),
    );
  }
}
