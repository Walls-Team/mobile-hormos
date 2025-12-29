import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlLauncherUtils {
  /// Abre una URL en el navegador predeterminado
  static Future<bool> launchURL(String url, {bool useWebView = false}) async {
    try {
      final Uri uri = Uri.parse(url);
      
      debugPrint('🔗 Intentando abrir URL: $url');
      
      if (await canLaunchUrl(uri)) {
        return await launchUrl(
          uri,
          mode: useWebView 
            ? LaunchMode.inAppWebView 
            : LaunchMode.externalApplication,
        );
      } else {
        debugPrint('❌ No se puede abrir la URL: $url');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error al abrir URL: $e');
      return false;
    }
  }
  
  /// Muestra un diálogo con error cuando no se puede abrir una URL
  static void showErrorDialog(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error al abrir enlace'),
        content: Text('No se pudo abrir: $url'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }
}
