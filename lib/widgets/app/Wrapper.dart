import 'package:flutter/material.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({
    super.key,
    required this.child,
    this.onBack,
    this.title,
  });
  final String? title;
  final VoidCallback? onBack;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            "assets/images/app/background.png",
          ),
        ),
      ),
      child: Scaffold(
        appBar: onBack == null
            ? AppBar(
                toolbarHeight: 0.0,
              )
            : AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: onBack,
                ),
                title: title == null
                    ? Container()
                    : Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: Text(
                          title!,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
        backgroundColor: Colors.transparent,
        body: child,
      ),
    );
  }
}
