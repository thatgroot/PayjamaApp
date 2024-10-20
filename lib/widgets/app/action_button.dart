import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const ActionButton({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white),
        Text(label,
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center),
      ],
    );
  }
}
