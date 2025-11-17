import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:genius_hormo/features/dashboard/services/dashboard_service.dart';
import 'package:genius_hormo/features/spike/services/spike_providers.dart';
import 'package:genius_hormo/l10n/app_localizations.dart';
import 'package:genius_hormo/theme/colors_pallete.dart';
import 'package:get_it/get_it.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter/cupertino.dart';

class StoreScreen extends StatelessWidget {

  const StoreScreen({super.key});

  Future<void> _launchURL(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Open external link'),
            content: const Text(
              'You are about to leave the app to visit an external website. Do you want to continue?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop(true);
                  await launchUrl(uri);
                },
                child: const Text('Open link'),
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot open link: $url'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    if (localizations == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10.0,
          children: [
            // Título descriptivo
            Text(
              localizations.storeTitle,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(localizations.storeSubtitle, style: TextStyle(fontSize: 16)),

            // Partner: Vitamins
            _buildCard(
              context: context,
              title: localizations.storeVitaminsTitle,
              description: localizations.storeVitaminsDescription,
              url: 'https://geniushormo.com/vitaminas/',
              icon: CupertinoIcons.heart,
            ),

            // Partner: Whoop
            _buildCard(
              context: context,
              title: localizations.storeWhoopTitle,
              description: localizations.storeWhoopDescription,
              url: 'https://join.whoop.com/us/en/GENIUS/',
              icon: CupertinoIcons.waveform_path,
            ),

            // Partner: Labs sorio
            _buildCard(
              context: context,
              title: localizations.storeLabcorpTitle,
              description: localizations.storeLabcorpDescription,
              url: 'https://www.labcorp.com/',
              icon: CupertinoIcons.drop,
            ),

            // Partner: Muse
            _buildCard(
              context: context,
              title: localizations.storeMuseTitle,
              description: localizations.storeMuseDescription,
              url: 'https://choosemuse.com/pages/muse-2-offers',
              icon: CupertinoIcons.moon_zzz,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required String url,
  }) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 200,
      borderRadius: 16,
      blur: 20, // Efecto blur más controlado
      border: 0,
      linearGradient: LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [neutral_700, neutral_600],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white, Colors.transparent],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        onTap: () => _launchURL(context, url),
        child: Stack(
          children: [
            // Content
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  // Título del partner
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      // color: Colors.black,
                    ),
                  ),

                  // Descripción sin icono para mejor alineación
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      // color: Colors.grey[700],
                      height: 1.4,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),
            
            // Icono en la esquina superior derecha
            Positioned(
              top: 16,
              right: 16,
              child: Icon(
                icon,
                size: 24,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
