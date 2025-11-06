// import 'package:flutter/material.dart';

// class CustomElevatedButton extends StatelessWidget {
//   final Widget child;
//   final VoidCallback onPressed;
//   final Color? borderColor; // Opcional para ElevatedButton
//   final Color? foregroundColor;
//   final double? minHeight;
//   final double? borderRadius;
//   final Color? backgroundColor;

//   const CustomElevatedButton({
//     Key? key,
//     required this.child,
//     required this.onPressed,
//     this.borderColor, // Opcional
//     this.foregroundColor = Colors.black,
//     this.minHeight = 50,
//     this.borderRadius = 8,
//     this.backgroundColor,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//       onPressed: onPressed,
//       style: ElevatedButton.styleFrom(
//         backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.primary,
//         foregroundColor: foregroundColor,
//         minimumSize: Size(double.infinity, minHeight!),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(borderRadius!),
//           side: borderColor != null 
//               ? BorderSide(color: borderColor!) 
//               : BorderSide.none,
//         ),
//       ),
//       child: child,
//     );
//   }
// }

import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed; // ← Cambiar a nullable
  final Color? borderColor;
  final Color? foregroundColor;
  final double? minHeight;
  final double? borderRadius;
  final Color? backgroundColor;

  const CustomElevatedButton({
    Key? key,
    required this.child,
    this.onPressed, // ← Ya no es required, puede ser null
    this.borderColor,
    this.foregroundColor = Colors.black,
    this.minHeight = 50,
    this.borderRadius = 8,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed, // ← Pasar directamente, puede ser null
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.primary,
        foregroundColor: foregroundColor,
        minimumSize: Size(double.infinity, minHeight!),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius!),
          side: borderColor != null 
              ? BorderSide(color: borderColor!) 
              : BorderSide.none,
        ),
      ),
      child: child,
    );
  }
}