import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final VoidCallback? onLongPressed;
  final Color? color;
  final String text;
  final TextStyle? textStyle;
  final Widget? child;
  final double? elevation;
  final double? borderWidth;
  final Color? borderColor;
  final OutlinedBorder? shape;
  const CustomButton({
    Key? key,
    required this.onPressed,
    required this.text,
    this.color,
    this.onLongPressed,
    this.textStyle,
    this.child,
    this.elevation,
    this.borderWidth,
    this.borderColor,
    this.shape,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      onLongPress: onLongPressed,
      child: Text(
        text,
        style: textStyle ??
            TextStyle(
              color: Theme.of(context).primaryColor,
              fontFamily: "Poppins",
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
      ),
      style: ElevatedButton.styleFrom(
        elevation: elevation ?? 10,
        primary: color ?? Theme.of(context).primaryColor,
        side: BorderSide(
          color: borderColor ?? Colors.transparent,
          width: borderWidth ?? 1,
        ),
        shape: shape ??
            const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
      ),
    );
  }
}
