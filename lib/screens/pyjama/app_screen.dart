import 'package:flutter/material.dart';
import 'package:pyjamaapp/screens/pyjama/character_display.dart';
import 'package:pyjamaapp/utils/navigation.dart';
import 'package:pyjamaapp/widgets/app/wrapper.dart';

class PyjamaAppScreen extends StatefulWidget {
  const PyjamaAppScreen({super.key});
  static String route = "/app_screen";
  @override
  State<PyjamaAppScreen> createState() => _PyjamaAppScreenState();
}

class _PyjamaAppScreenState extends State<PyjamaAppScreen> {
  @override
  void initState() {
    super.initState();
  }

  final List<String> images = [
    "assets/images/pyjama/characters/shiba-pyjama-gruen-kreise.png",
    "assets/images/pyjama/characters/shiba-pyjama-lila-sterne.png",
    "assets/images/pyjama/characters/shiba-pyjama-red-halbmond.png",
    "assets/images/pyjama/characters/shiba-pyjama-tuerkis-sterne.png"
  ];

  @override
  Widget build(BuildContext context) {
    return Wrapper(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              width: double.infinity,
              child: Text(
                'Choose a Pyjama',
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
                "John needs a pyjama, so that he can sleep",
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
              height: 16,
            ),
            const SizedBox(
              width: 116,
              child: Text(
                'Choose a Pyjama',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Color(0xFFFED127),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    height: 0.12),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 300, // Height of the slider
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: images.length,
                itemExtent: 160.0,
                itemBuilder: (context, index) {
                  return TextButton(
                    onPressed: () {
                      to(context, CharacterDisplayScreen.route);
                    },
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: index == 0
                            ? 16.0
                            : 8.0, // Extra padding on the left for the first item
                        right: 8.0,
                      ), // Add gap between items
                      child: Image.asset(
                        images[index],
                        fit: BoxFit.contain,
                        width: 112.0,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
