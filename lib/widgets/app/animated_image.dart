import 'package:flutter/material.dart';

class AnimatedImage extends StatefulWidget {
  final Image image;

  const AnimatedImage({super.key, required this.image});

  @override
  AnimatedImageState createState() => AnimatedImageState();
}

class AnimatedImageState extends State<AnimatedImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2), // Total time for one complete cycle
      vsync: this,
    );

    _animation = Tween<Offset>(
      begin: const Offset(0, 0), // Starting position (center)
      end: const Offset(0, -0.2), // End position (upward shift)
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.repeat(reverse: true); // Repeats the animation in reverse
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: widget.image, // Use the image passed from outside
    );
  }
}
