import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/services.dart';
import 'package:genius_hormo/core/deep_link/genius_hormo_deep_link_data.dart';

class GeniusHormoDeepLinkService {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  static final GeniusHormoDeepLinkService _instance = GeniusHormoDeepLinkService._internal();
  factory GeniusHormoDeepLinkService() => _instance;
  GeniusHormoDeepLinkService._internal();

  final StreamController<GeniusHormoDeepLinkData> _deepLinkController = 
      StreamController<GeniusHormoDeepLinkData>.broadcast();
  
  Stream<GeniusHormoDeepLinkData> get deepLinkStream => _deepLinkController.stream;

  Future<void> init() async {
    _appLinks = AppLinks();
    
    await _handleInitialLink();
    _listenToLinks();
  }

  Future<void> _handleInitialLink() async {
    try {
      // ✅ CORRECCIÓN: Usar getInitialLink() en lugar de getInitialAppLink()
      final Uri? initialUri = await _appLinks.getInitialLink();
      if (initialUri != null && _isGeniusHormoLink(initialUri)) {
        _processDeepLink(initialUri);
      }
    } on PlatformException catch (e) {
      _logError('Error getting initial app link: $e');
    }
  }

  void _listenToLinks() {
    // ✅ CORRECCIÓN: Usar stringLinkStream o uriLinkStream según necesites
    _linkSubscription = _appLinks.uriLinkStream.listen((Uri uri) {
      if (_isGeniusHormoLink(uri)) {
        _processDeepLink(uri);
      }
    }, onError: (err) {
      _logError('Error in app link stream: $err');
    });
  }

  bool _isGeniusHormoLink(Uri uri) {
    return uri.host.contains('geniushormo') || 
           uri.scheme == 'geniushormo' ||
           uri.toString().contains('geniushormo');
  }


  void _processDeepLink(Uri uri) {
  try {
    print('=== DEEP LINK RAW URI ===');
    print('URI completo: $uri');
    print('Scheme: ${uri.scheme}');
    print('Host: ${uri.host}');
    print('Path: ${uri.path}');
    print('Path Segments: ${uri.pathSegments}');
    print('Query: ${uri.query}');
    print('Query Parameters: ${uri.queryParameters}');
    
    final deepLinkData = GeniusHormoDeepLinkData.fromUri(uri);
    
    print('=== PROCESSED DEEP LINK ===');
    print('Path: ${deepLinkData.path}');
    print('Segments: ${deepLinkData.segments}');
    print('Host: ${deepLinkData.host}');
    print('Link Type: ${deepLinkData.linkType}');
    print('isAcceptDevice: ${deepLinkData.isAcceptDevice}');
    
    _deepLinkController.add(deepLinkData);
    _logInfo('Deep link processed: ${deepLinkData.path}');
  } catch (e) {
    _logError('Error processing deep link: $e');
  }
}

  void _logInfo(String message) {
    print('🔗 DeepLinkService: $message');
  }

  void _logError(String message) {
    print('❌ DeepLinkService: $message');
  }

  void dispose() {
    _linkSubscription?.cancel();
    _deepLinkController.close();
  }
}