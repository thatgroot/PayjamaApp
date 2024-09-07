import 'package:flutter/material.dart';
import 'package:pyjama_runner/screens/SplashScreen.dart';

class PyjamaCoinApp extends StatelessWidget {
  const PyjamaCoinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PyjamaCoin',
      theme: ThemeData(
        primaryColor: const Color(0xFF1F1B35),
        scaffoldBackgroundColor: const Color(0xFF1F1B35),
      ),
      home: const SplashScreen(),
    );
  }
}
