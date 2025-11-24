import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WhoopPromoModal extends StatelessWidget {
  const WhoopPromoModal({super.key});

  static Future<void> show(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const WhoopPromoModal(),
    );
  }

  Future<void> _openWhoopLink() async {
    final uri = Uri.parse('https://join.whoop.com/GENIUS');
    
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        debugPrint('✅ Abriendo enlace de WHOOP');
      } else {
        debugPrint('❌ No se puede abrir el enlace');
      }
    } catch (e) {
      debugPrint('❌ Error al abrir enlace: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallDevice = screenWidth < 400 || screenHeight < 700;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isSmallDevice ? 20 : 40,
        vertical: isSmallDevice ? 24 : 40,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: screenHeight * 0.8,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1a1a2e),
              Color(0xFF16213e),
              Color(0xFF0f3460),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.purple.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: -30,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.withOpacity(0.1),
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: EdgeInsets.all(isSmallDevice ? 16.0 : 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Close button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.white70),
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: isSmallDevice ? 4 : 8),
                  
                  // Icon/Logo placeholder
                  Container(
                    width: isSmallDevice ? 60 : 80,
                    height: isSmallDevice ? 60 : 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Colors.purple.shade400,
                          Colors.blue.shade400,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.favorite,
                      size: isSmallDevice ? 28 : 40,
                      color: Colors.white,
                    ),
                  ),
                  
                  SizedBox(height: isSmallDevice ? 16 : 24),
                  
                  // Title
                  Text(
                    '¡Oferta Exclusiva! 🎁',
                    style: TextStyle(
                      fontSize: isSmallDevice ? 20 : 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: isSmallDevice ? 12 : 16),
                  
                  // Description
                  Container(
                    padding: EdgeInsets.all(isSmallDevice ? 12 : 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Obtén un WHOOP gratis',
                          style: TextStyle(
                            fontSize: isSmallDevice ? 16 : 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: isSmallDevice ? 6 : 8),
                        Text(
                          '+ 1 mes gratis',
                          style: TextStyle(
                            fontSize: isSmallDevice ? 14 : 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.green.shade300,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: isSmallDevice ? 8 : 12),
                        Text(
                          'al unirte a través de nuestro enlace exclusivo',
                          style: TextStyle(
                            fontSize: isSmallDevice ? 12 : 14,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: isSmallDevice ? 16 : 24),
                  
                  // CTA Button
                  Container(
                    width: double.infinity,
                    height: isSmallDevice ? 48 : 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.purple.shade500,
                          Colors.blue.shade500,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withOpacity(0.4),
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        _openWhoopLink();
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              '¡Quiero mi WHOOP gratis!',
                              style: TextStyle(
                                fontSize: isSmallDevice ? 14 : 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: isSmallDevice ? 20 : 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: isSmallDevice ? 12 : 16),
                  
                  // Secondary button
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Ahora no',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: isSmallDevice ? 13 : 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
