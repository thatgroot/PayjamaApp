import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pyjama_runner/screens/character_selection_screen.dart';
import 'package:pyjama_runner/widgets/app/animated_image.dart';
import 'package:pyjama_runner/widgets/app/animated_progress_bar.dart';

class Loadingscreen extends StatefulWidget {
  const Loadingscreen({super.key});

  @override
  State<Loadingscreen> createState() => _LoadingscreenState();
}

class _LoadingscreenState extends State<Loadingscreen> {
  @override
  void initState() {
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
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AnimatedImage(
                image: Image.asset(
                  'assets/images/pyjama/pyjama.png',
                  width: 241,
                  height: 241,
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              AnimatedProgressBar(
                onProgressChanged: (progress) {
                  if (progress == 1.0) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CharacterSelectionScreen(),
                      ),
                    );
                  }
                  // Handle progress change
                  log('Loading Screen -> Progress: $progress');
                },
              ),
              const SizedBox(
                height: 12,
              ),
              const Text(
                'Loading...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                  height: 0,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
