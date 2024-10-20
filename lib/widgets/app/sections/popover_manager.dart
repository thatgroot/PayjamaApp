import 'package:flutter/material.dart';

class PopoverManager {
  OverlayEntry? _overlayEntry;

  // Create the overlay entry
  OverlayEntry _createOverlayEntry(Widget child) {
    return OverlayEntry(
      builder: (context) => child,
    );
  }

  // Show overlay
  void showOverlay(BuildContext context, Widget child) {
    _overlayEntry = _createOverlayEntry(child);
    Overlay.of(context).insert(_overlayEntry!);
  }

  // Remove overlay
  void removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
