import 'package:flutter/material.dart';

class CharacterOption extends StatelessWidget {
  final Color color;
  const CharacterOption({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
      child: const Center(
        child: Icon(Icons.person, size: 48, color: Colors.white),
      ),
    );
  }
}
