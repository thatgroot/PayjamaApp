import 'package:flutter/material.dart';
import 'package:pyjama_runner/screens/LoadingScreen.dart';

class NameInputScreen extends StatefulWidget {
  const NameInputScreen({super.key});

  @override
  State<NameInputScreen> createState() => _NameInputScreenState();
}

class _NameInputScreenState extends State<NameInputScreen> {
  @override
  void initState() {
    super.initState();
  }

  void _navigateToNameScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Loadingscreen()),
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
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                width: double.infinity,
                child: Text(
                  'Name',
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
                  "Your character needs a name",
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
              SizedBox(
                width: 325,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  // gap
                  children: [
                    const Text(
                      'Your character name',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFFED127),
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        height: 0.11,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 0.0,
                        ), // Adjust padding as needed
                        filled: true,
                        fillColor: Colors.transparent, // No background color
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(
                            color: Color(0xFFFED127),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(
                            color: Color(0xFFFED127),
                            width: 1,
                          ),
                        ),
                        hintText: 'John',
                        hintStyle: const TextStyle(
                          color: Color(0xFF99A0A8),
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          height: 1.2, // Adjusted to fit better in TextField
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 18,
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
