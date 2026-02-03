import 'package:flutter/material.dart';
import 'package:genius_hormo/l10n/app_localizations.dart';
import 'package:genius_hormo/theme/colors_pallete.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class ProgressBar extends StatelessWidget {
  final double progress;

  const ProgressBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '${progress.toStringAsFixed(0)}% ',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),

        Text(
          AppLocalizations.of(context)!['dashboard']['ofGoalAchieved'] ?? 'of goal achieved',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: LinearPercentIndicator(
            percent: progress / 100,
            lineHeight: 14.0,
            backgroundColor: Theme.of(context).colorScheme.onSurface,
            progressColor: neutral_500,
            padding: EdgeInsets.zero,
            animation: true,
            animateFromLastPercent: true,
          ),
        ),
      ],
    );
  }
}
