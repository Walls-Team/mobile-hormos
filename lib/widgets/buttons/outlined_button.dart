import 'package:flutter/material.dart';

class CustomOutlinedButton extends StatelessWidget {
  final Widget child;
  final Color borderColor;
  final VoidCallback onPressed;
  final Color? foregroundColor;
  final double? minHeight;
  final double? borderRadius;

  const CustomOutlinedButton({
    super.key,
    required this.child,
    required this.borderColor,
    required this.onPressed,
    this.foregroundColor = Colors.white,
    this.minHeight = 50,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: foregroundColor,
        side: BorderSide(color: borderColor),
        minimumSize: Size(double.infinity, minHeight!),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius!),
        ),
      ),
      child: child,
    );
  }
}