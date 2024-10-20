import 'package:flutter/material.dart';

class CustomProgressBar extends StatelessWidget {
  final double progress; // Progress percentage (0.0 to 1.0)

  const CustomProgressBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 292,
          height: 24,
          padding: const EdgeInsets.all(3),
          decoration: ShapeDecoration(
            gradient: const LinearGradient(
              begin: Alignment(0.00, -1.00),
              end: Alignment(0, 1),
              colors: [Color(0xFF0032E4), Color(0xFF00BDF9)],
            ),
            shape: RoundedRectangleBorder(
              side: const BorderSide(
                width: 3,
                strokeAlign: BorderSide.strokeAlignOutside,
                color: Colors.white,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 284 *
                    progress, // Adjust the width based on the progress value
                height: 18,
                decoration: ShapeDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment(0.00, -1.00),
                    end: Alignment(0, 1),
                    colors: [
                      Color(0xFFFFE928),
                      Color(0xFFFA5A00),
                      Color(0xFFD04D04)
                    ],
                  ),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(width: 1, color: Colors.white),
                    borderRadius: BorderRadius.circular(9.51),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: Color(0x4C000000),
                      blurRadius: 2,
                      offset: Offset(0, 4),
                      spreadRadius: 0,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        // Background Container (empty part of the progress bar)
      ],
    );
  }
}
