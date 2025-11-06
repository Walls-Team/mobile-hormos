import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:genius_hormo/l10n/app_localizations.dart';
import 'package:genius_hormo/theme/colors_pallete.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter/cupertino.dart';

class StorePage extends StatelessWidget {
  const StorePage({super.key});

  Future<void> _launchURL(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Abrir enlace externo'),
            content: const Text(
              'Estás a punto de salir de la aplicación para visitar un sitio web externo. ¿Deseas continuar?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop(true);
                  await launchUrl(uri);
                },
                child: const Text('Abrir enlace'),
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se puede abrir el enlace: $url'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

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
              url: 'https://example.com/vitamins', // Reemplaza con URL real
              icon: CupertinoIcons.heart,
            ),

            // Partner: Whoop
            _buildCard(
              context: context,
              title: localizations.storeWhoopTitle,
              description: localizations.storeWhoopDescription,
              url: 'https://example.com/whoop', // Reemplaza con URL real
              icon: CupertinoIcons.waveform_path,
            ),

            // Partner: Labs sorio
            _buildCard(
              context: context,
              title: localizations.storeLabcorpTitle,
              description: localizations.storeLabcorpDescription,
              url: 'https://example.com/labs-sorio', // Reemplaza con URL real
              icon: CupertinoIcons.drop,
            ),

            // Partner: Muse
            _buildCard(
              context: context,
              title: localizations.storeMuseTitle,
              description: localizations.storeMuseDescription,
              url: 'https://example.com/muse', // Reemplaza con URL real
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
        colors: [ neutral_700, neutral_600 ],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white, Colors.transparent],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),

        onTap: () => _launchURL(context, url),
        child: Padding(
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

              // Descripción con icono en fila
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icono de tamaño mediano
                  Icon(
                    icon, // Cambié a arrow_forward que es más común para enlaces
                    size: 40, // Tamaño mediano
                  ),
                  const SizedBox(width: 8), // Espacio entre icono y texto
                  // Texto de descripción
                  Expanded(
                    child: Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        // color: Colors.grey[700],
                        height: 1.4,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ],
              ),

              // Indicador de enlace externo
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPartnerCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required String url,
  }) {
    return Card(
      elevation: 2,
      color: Colors.transparent,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),

        onTap: () => _launchURL(context, url),
        child: Padding(
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

              // Descripción con icono en fila
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icono de tamaño mediano
                  Icon(
                    icon, // Cambié a arrow_forward que es más común para enlaces
                    size: 40, // Tamaño mediano
                  ),
                  const SizedBox(width: 8), // Espacio entre icono y texto
                  // Texto de descripción
                  Expanded(
                    child: Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        // color: Colors.grey[700],
                        height: 1.4,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ],
              ),

              // Indicador de enlace externo
            ],
          ),
        ),
      ),
    );
  }
}

