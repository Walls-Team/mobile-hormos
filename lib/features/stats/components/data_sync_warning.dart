import 'package:flutter/material.dart';
import 'package:genius_hormo/l10n/app_localizations.dart';

class DataSyncWarning extends StatelessWidget {
  final String? customMessage;

  const DataSyncWarning({
    super.key,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange, width: 1),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.watch_later_outlined,
            color: Colors.orange,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!['common']?['dataSyncTitle'] ?? 'Synchronizing data',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  customMessage ??
                      AppLocalizations.of(context)!['common']?['dataSyncMessage'] ?? 'No data available yet. Please wait 24 hours after syncing your Whoop to view your data.',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
