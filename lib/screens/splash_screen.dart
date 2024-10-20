import 'package:flutter/material.dart';
import 'package:pyjamaapp/screens/loading_screen.dart';
import 'package:pyjamaapp/services/context_utility.dart';
import 'package:pyjamaapp/utils/navigation.dart';
import 'package:pyjamaapp/widgets/app/wrapper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static String route = "/splash";

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _toLoadingScreen();
  }

  void _toLoadingScreen() async {
    await Future.delayed(const Duration(seconds: 4));
    to(ContextUtility.context, LoadingScreen.route);
  }

  @override
  Widget build(BuildContext context) {
    return Wrapper(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/pyjama/pyjama-logo.png',
              width: 241,
              height: 241,
            ),
            const SizedBox(height: 4),
            const Text(
              'PjyamaCoin',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontFamily: 'Lato',
                fontWeight: FontWeight.w500,
                height: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
