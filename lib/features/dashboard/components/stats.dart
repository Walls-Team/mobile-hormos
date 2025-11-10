// import 'package:flutter/material.dart';

// class StatCard extends StatelessWidget {
//   final String duration;
//   final String title;
//   final IconData icon;
//   final double iconSize;
//   final double fontSize;
//   final double padding;
//   final double borderRadius;
//   final double? size;

//   const StatCard({
//     super.key,
//     required this.duration,
//     this.title = 'Title',
//     this.icon = Icons.info,
//     this.iconSize = 32,
//     this.fontSize = 16,
//     this.padding = 20,
//     this.borderRadius = 12,
//     this.size,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: EdgeInsets.all(4),

//       shape: RoundedRectangleBorder(
//         side: BorderSide(
//           color: Theme.of(context).colorScheme.outline,
//           // Color del borde
//         ),
//         borderRadius: BorderRadius.circular(12), // Bordes redondeados
//       ),

//       child: Padding(
//         padding: EdgeInsets.all(8.0),

//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,

//           children: [
//             Icon(icon, size: iconSize),
//             const SizedBox(height: 12),
//             Text(
//               duration,
//               style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               title,
//               style: TextStyle(fontSize: fontSize),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String duration;
  final String title;
  final IconData icon;
  final double iconSize;
  final double fontSize;
  final double padding;
  final double borderRadius;
  final double? size;

  const StatCard({
    super.key,
    required this.duration,
    this.title = 'Title',
    this.icon = Icons.info,
    this.iconSize = 24,
    this.fontSize = 14,
    this.padding = 16,
    this.borderRadius = 8,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        // side: BorderSide(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      elevation: 2,
      child: Container(
        width: 110,
        height: 140, // Altura fija para todas
        padding: EdgeInsets.all(padding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: iconSize),
            const SizedBox(height: 8),
            Text(
              duration,
              style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            // Usa Flexible para que el texto se ajuste sin cambiar la altura
            Flexible(
              child: Text(
                title,
                style: TextStyle(fontSize: fontSize - 2),
                textAlign: TextAlign.center,
                maxLines: 2, // Máximo 2 líneas
                overflow: TextOverflow.ellipsis, // Puntos si es muy largo
              ),
            ),
          ],
        ),
      ),
    );
  }
}
