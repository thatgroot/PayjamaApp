import 'package:flutter/material.dart';

class PopoverContainer extends StatelessWidget {
  final List<Widget> children;
  const PopoverContainer({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black45.withOpacity(0.8),
      body: Container(
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: children,
          ),
        ),
      ),
    );
  }
}
