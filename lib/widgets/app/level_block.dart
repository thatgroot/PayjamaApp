import 'package:flutter/material.dart';

class LevelBlock extends StatelessWidget {
  final void Function()? onTap;
  final List<Color> gradient; // Progress percentage (0.0 to 1.0)
  final Color canvas;
  final Color shadow;
  final Color border;
  final bool status;
  final String label;
  const LevelBlock({
    super.key,
    required this.onTap,
    this.gradient = const [Color(0xFFC3B3FF), Color(0xFF5D4D9E)],
    this.canvas = const Color(0xFF014436),
    this.shadow = const Color(0xFF48349C),
    this.border = Colors.white,
    this.status = false,
    this.label = "0",
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: 80.4,
            height: 74.0,
            clipBehavior: Clip.hardEdge,
            decoration: ShapeDecoration(
              gradient: LinearGradient(
                begin: const Alignment(0.00, -1.00),
                end: const Alignment(0, 1),
                colors: gradient,
              ),
              shape: RoundedRectangleBorder(
                side: BorderSide(width: 2.50, color: border),
                borderRadius: BorderRadius.circular(10),
              ),
              shadows: [
                BoxShadow(
                  color: shadow,
                  blurRadius: 0,
                  offset: const Offset(0, 5),
                  spreadRadius: 0,
                )
              ],
            ),
            child: Stack(
              clipBehavior: Clip
                  .hardEdge, // Allows oval to overflow outside parent container
              children: [
                // Oval (Clipped Circle) positioned at top center
                Positioned(
                  top: -14, // Position the oval above the container
                  left: 0,
                  right:
                      0, // Adjust to center it horizontally relative to parent container width
                  child: ClipOval(
                    child: Opacity(
                      opacity: 0.30,
                      child: Container(
                        width: 80.4,
                        height: 54,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: const Alignment(0.00, -1.00),
                            end: const Alignment(0, 1),
                            colors: [Colors.white.withOpacity(0), Colors.white],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: SizedBox(
                width: 55,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 41,
                    fontFamily: 'Rubik',
                    fontWeight: FontWeight.w700,
                    height: 0,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -2,
            right: 0,
            child: Image.asset("assets/images/brick_breaker/lock.png"),
          ),
        ],
      ),
    );
  }
}
