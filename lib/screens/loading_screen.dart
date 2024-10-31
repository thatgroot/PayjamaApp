import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pyjamaapp/screens/wallet_screen.dart';
import 'package:pyjamaapp/screens/games.dart';
import 'package:pyjamaapp/services/context_utility.dart';
import 'package:pyjamaapp/services/hive.dart';
import 'package:pyjamaapp/utils/navigation.dart';
import 'package:pyjamaapp/widgets/app/animated_image.dart';
import 'package:pyjamaapp/widgets/app/animated_progress_bar.dart';
import 'package:pyjamaapp/widgets/app/wrapper.dart';

String debugKey = 'lib/screens/loading_screen.dart -> ';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});
  static String route = "/loading";

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
  }

  void navigateToNextScreen(double progress) async {
    if (progress == 1.0) {
      try {
        HiveService.getData(HiveKeys.connected).then((connected) {
          log('Loading Screen -> Progress: $progress $connected');
          to(
            ContextUtility.context!,
            connected == null ? WalletScreen.route : GamesScreen.route,
          );
        });
      } catch (e) {
        log("$debugKey error $e");
      }
    }
    // Handle progress change
  }

  @override
  Widget build(BuildContext context) {
    return Wrapper(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedImage(
              image: Image.asset(
                'assets/images/pyjama/pyjama.png',
                width: 240,
                height: 240,
              ),
            ),
            const Text(
              'Loading...',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontFamily: 'Rubik',
                fontWeight: FontWeight.w600,
                height: 0,
              ),
            ),
            const SizedBox(height: 12),
            AnimatedProgressBar(onProgressChanged: navigateToNextScreen),
          ],
        ),
      ),
    );
  }
}
