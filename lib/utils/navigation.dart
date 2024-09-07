// to function
import 'package:flutter/material.dart';

void to(context, widget) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => widget,
    ),
  );
}
