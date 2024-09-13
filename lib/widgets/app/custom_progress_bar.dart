import 'package:flutter/material.dart';

class CustomProgressBar extends StatelessWidget {
  final double progress; // Progress percentage (0.0 to 1.0)

  const CustomProgressBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background Container (empty part of the progress bar)
        Container(
          width: 284,
          height: 24,
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1, color: Color(0xFFFED127)),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        // Progress Indicator (filled part of the progress bar)
        Container(
          width: 284 * progress, // Adjust the width based on the progress value
          height: 24,
          decoration: ShapeDecoration(
            color: const Color(0xFFFED127),
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1, color: Color(0xFFFED127)),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}
