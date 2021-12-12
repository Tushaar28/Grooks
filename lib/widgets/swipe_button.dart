import 'package:flutter/material.dart';
import 'package:slide_to_confirm/slide_to_confirm.dart';

class SwipeButton extends StatelessWidget {
  final String text;
  final VoidCallback onSwipeCallback;
  final Color? color;
  final Color bakgroundColor;
  final Color? backgroundColorEnd;
  final Color iconColor;
  final Widget icon;
  final BoxShadow? shadow;
  final TextStyle? textStyle;
  final BorderRadius? foregroundShape;
  final BorderRadius? backgroundShape;
  final double height;
  final double width;

  const SwipeButton({
    Key? key,
    this.color,
    this.bakgroundColor = Colors.white,
    this.backgroundColorEnd,
    this.iconColor = Colors.white,
    this.icon = const Icon(Icons.chevron_right),
    this.shadow,
    this.textStyle,
    this.foregroundShape,
    this.backgroundShape,
    this.height = 70,
    this.width = 300,
    required this.text,
    required this.onSwipeCallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConfirmationSlider(
      onConfirmation: onSwipeCallback,
      height: height,
      width: width,
      backgroundColor: bakgroundColor,
      backgroundColorEnd: backgroundColorEnd,
      foregroundColor: color ?? Theme.of(context).primaryColor,
      iconColor: iconColor,
      sliderButtonContent: icon,
      shadow: shadow ??
          const BoxShadow(
            color: Colors.black38,
            offset: Offset(0, 2),
            blurRadius: 2,
            spreadRadius: 0,
          ),
      text: text,
      textStyle: textStyle ??
          const TextStyle(
            color: Colors.black26,
            fontWeight: FontWeight.bold,
          ),
      foregroundShape: foregroundShape,
      backgroundShape: backgroundShape,
    );
  }
}
