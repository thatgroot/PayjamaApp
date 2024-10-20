import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pyjamaapp/providers/phantom.dart';
import 'package:pyjamaapp/screens/pyjama/character_display.dart';
import 'package:pyjamaapp/screens/name_input_screen.dart';
import 'package:pyjamaapp/screens/wallet_screen.dart';
import 'package:pyjamaapp/services/context_utility.dart';
import 'package:pyjamaapp/services/firebase.dart';
import 'package:pyjamaapp/utils/navigation.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});
  static String route = "/welcome";

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool loading = true;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final walletProvider = Provider.of<PhantomWalletProvider>(
          ContextUtility.context!,
          listen: false);
      final FirestoreService firestoreService = FirestoreService();

      if (walletProvider.publicKey == null) {
        if (mounted) {
          to(ContextUtility.context!, WalletScreen.route);
        }
        return;
      } else {
        firestoreService
            .getDocument("info", walletProvider.publicKey!)
            .then((doc) {
          log("exists ${doc.data()}");
          if (doc.exists) {
            to(ContextUtility.context!, CharacterDisplayScreen.route);
          }
        });
      }

      setState(() {
        loading = false;
      });
    });
  }

  void _navigateToNameScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const NameInputScreen()),
    );
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
        child: loading
            ? Container()
            : Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: double.infinity,
                      child: Text(
                        'Welcome!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                          height: 0,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 308,
                      child: Text(
                        "Let's start easily and completely relaxed into the world of Pyjamacoin.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w300,
                          height: 0,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 28,
                    ),
                    TextButton(
                      onPressed: () {
                        _navigateToNameScreen();
                      },
                      child: Container(
                        width: 264,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: ShapeDecoration(
                          color: const Color(0xFFFED127),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Let's start with your character",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w500,
                            height: 0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
