import 'package:flutter/material.dart';
import 'package:pyjama_runner/widgets/app/custom_progress_bar.dart';

class AnimatedProgressBar extends StatefulWidget {
  final void Function(double progress)? onProgressChanged;

  const AnimatedProgressBar({super.key, this.onProgressChanged});

  @override
  AnimatedProgressBarState createState() => AnimatedProgressBarState();
}

class AnimatedProgressBarState extends State<AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 5), // Animation duration
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0.01, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _progressAnimation.addListener(() {
      if (widget.onProgressChanged != null) {
        widget.onProgressChanged!(_progressAnimation.value);
      }
    });

    _controller.forward(); // Start the animation
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return CustomProgressBar(progress: _progressAnimation.value);
      },
    );
  }
}
