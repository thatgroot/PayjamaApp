import 'package:flutter/material.dart';
import 'package:pyjamaapp/config.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: appTitle,
      theme: themeData,
      routerConfig: goRouter,
    );
  }
}
