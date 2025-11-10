import 'package:flutter/cupertino.dart' show NavigatorState, GlobalKey;
import 'package:flutter/material.dart';
import 'package:genius_hormo/core/deep_link/genius_hormo_deep_link_data.dart';
import 'package:genius_hormo/core/navigation/navigation_service.dart';

class DeepLinkMapper {
  final GlobalKey<NavigatorState> navigatorKey;

  DeepLinkMapper({required this.navigatorKey});

  DeepLinkRouteConfig? mapDeepLinkToRoute(
    GeniusHormoDeepLinkData deepLinkData,
  ) {
    final context = _getNavigationContext();
    if (context == null) return null;

    print('🔗 Mapping deep link - Path: ${deepLinkData.path}');
    print('🔗 Host: ${deepLinkData.host}');
    print('🔗 Segments: ${deepLinkData.segments}');

    // ✅ DETECCIÓN SIMPLE PARA SPIKE/ACCEPTDEVICE
    // Para geniushormo://auth/spike/acceptdevice
    // - Scheme: geniushormo
    // - Host: auth
    // - Path: /spike/acceptdevice
    // - Segments: [spike, acceptdevice]
    
    if (deepLinkData.linkType == GeniusHormoLinkType.customScheme &&
        deepLinkData.host == 'auth' &&
        deepLinkData.segments.length >= 2 &&
        deepLinkData.segments[0] == 'spike' &&
        deepLinkData.segments[1] == 'acceptdevice') {
      
      print('✅ Ruta acceptDevice detectada via custom scheme');
      
      return DeepLinkRouteConfig(
        context: context,
        path: '/auth/spike/acceptdevice',
        queryParameters: {
          'provider_slug': deepLinkData.getQueryParam('provider_slug') ?? '',
          'user_id': deepLinkData.getQueryParam('user_id') ?? '',
        },
      );
    }

    // ✅ DETECCIÓN PARA UNIVERSAL LINKS
    // Para https://geniushormo.com/auth/spike/acceptdevice
    if (deepLinkData.linkType == GeniusHormoLinkType.universalLink &&
        deepLinkData.segments.length >= 3 &&
        deepLinkData.segments[0] == 'auth' &&
        deepLinkData.segments[1] == 'spike' &&
        deepLinkData.segments[2] == 'acceptdevice') {
      
      print('✅ Ruta acceptDevice detectada via universal link');
      
      return DeepLinkRouteConfig(
        context: context,
        path: '/auth/spike/acceptdevice',
        queryParameters: {
          'provider_slug': deepLinkData.getQueryParam('provider_slug') ?? '',
          'user_id': deepLinkData.getQueryParam('user_id') ?? '',
        },
      );
    }

    // ... el resto de tus rutas existentes ...

    print('❌ Ruta no reconocida');
    return DeepLinkRouteConfig(context: context, path: '/');
  }

  BuildContext? _getNavigationContext() {
    try {
      return navigatorKey.currentContext;
    } catch (e) {
      return null;
    }
  }
}