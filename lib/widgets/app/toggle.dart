import 'package:flutter/material.dart';

class ToggleSwitch extends StatefulWidget {
  final bool active;
  final ValueChanged<bool> onChanged;
  final String activeText;
  final String inactiveText;
  final String label;
  final Image image;

  const ToggleSwitch({
    super.key,
    this.active = false,
    required this.onChanged,
    this.activeText = 'ON',
    this.inactiveText = 'OFF',
    required this.label,
    required this.image,
  });

  @override
  ToggleSwitchState createState() => ToggleSwitchState();
}

class ToggleSwitchState extends State<ToggleSwitch> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 148,
          height: 36,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              widget.image,
              const SizedBox(width: 10),
              Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontFamily: 'Rubik',
                  fontWeight: FontWeight.w600,
                  height: 0,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 96,
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 3),
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            gradient: LinearGradient(
              begin: const Alignment(0.00, -1.00),
              end: const Alignment(0, 1),
              colors: widget.active
                  ? [
                      const Color(0xFF147B04),
                      const Color(0xFF4DD23A),
                      const Color(0xFF147B04)
                    ]
                  : [
                      const Color(0xFF5025A3),
                      const Color(0xFF903DDC),
                      const Color(0xFF5025A3)
                    ],
            ),
            shape: RoundedRectangleBorder(
              side: const BorderSide(
                width: 2,
                strokeAlign: BorderSide.strokeAlignOutside,
                color: Colors.white,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Stack(
            children: [
              AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: widget.active
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Image.asset(
                  widget.active
                      ? "assets/images/app/on.png"
                      : "assets/images/app/off.png",
                  width: 40.0,
                ),
              ),
              Align(
                alignment: widget.active
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    widget.onChanged(!widget.active);
                  },
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: widget.active ? 8.0 : 0.0,
                        right: widget.active ? 0.0 : 8.0),
                    child: Text(
                      widget.active ? widget.activeText : widget.inactiveText,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: widget.active ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
