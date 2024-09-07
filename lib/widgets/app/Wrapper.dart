import 'package:flutter/material.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key, required this.child, this.onBack, this.title});
  final String? title;
  final VoidCallback? onBack;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF24243E), Color(0xFF302B63), Color(0xFF0F0C29)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: onBack,
          ),
          title: Text(
            title ?? '',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: child,
      ),
    );
  }
}
