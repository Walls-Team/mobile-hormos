import 'package:flutter/material.dart';
import 'package:genius_hormo/theme/colors_pallete.dart';

class FaqsBadge extends StatelessWidget {
  final VoidCallback onTap;

  const FaqsBadge({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // Mismo ancho que los demás
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: neutral_600,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "FAQ's",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
