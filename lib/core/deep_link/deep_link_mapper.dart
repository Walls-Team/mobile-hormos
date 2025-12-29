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
    // Get navigation context - may be null
    final BuildContext? context = _getNavigationContext();
    
    // If context is null, we can't create a DeepLinkRouteConfig
    if (context == null) {
      print('❌ No navigation context available for deep linking');
      return null;
    }
    // Context is already retrieved and checked above
    print('🔗 context ${context}');
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

    // ✅ STRIPE - CUSTOM SCHEME
    // Para geniushormo://stripe/success?session_id=...
    // - Scheme: geniushormo
    // - Host: stripe
    // - Path: /success o /cancel
    // - Segments: [success] o [cancel]
    if (deepLinkData.linkType == GeniusHormoLinkType.customScheme &&
        deepLinkData.host == 'stripe' &&
        deepLinkData.segments.isNotEmpty &&
        (deepLinkData.segments[0] == 'success' ||
            deepLinkData.segments[0] == 'cancel')) {
      final stripePath = deepLinkData.segments[0] == 'success'
          ? '/stripe/success'
          : '/stripe/cancel';

      print('✅ Ruta Stripe detectada via custom scheme: $stripePath');

      final sessionId = deepLinkData.getQueryParam('session_id');
      return DeepLinkRouteConfig(
        context: context,
        path: stripePath,
        queryParameters: {
          if (sessionId != null && sessionId.isNotEmpty) 'session_id': sessionId,
        },
      );
    }

    // ✅ STRIPE - UNIVERSAL LINK
    // Para https://geniushormo.com/stripe/success?session_id=...
    // - Scheme: https
    // - Host: geniushormo.com
    // - Path: /stripe/success o /stripe/cancel
    // - Segments: [stripe, success] o [stripe, cancel]
    if (deepLinkData.linkType == GeniusHormoLinkType.universalLink &&
        deepLinkData.segments.length >= 2 &&
        deepLinkData.segments[0] == 'stripe' &&
        (deepLinkData.segments[1] == 'success' ||
            deepLinkData.segments[1] == 'cancel')) {
      final stripePath = deepLinkData.segments[1] == 'success'
          ? '/stripe/success'
          : '/stripe/cancel';

      print('✅ Ruta Stripe detectada via universal link: $stripePath');

      final sessionId = deepLinkData.getQueryParam('session_id');
      return DeepLinkRouteConfig(
        context: context,
        path: stripePath,
        queryParameters: {
          if (sessionId != null && sessionId.isNotEmpty) 'session_id': sessionId,
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
    return DeepLinkRouteConfig(context: context, path: '/'); // context is non-null here due to the check above
  }

  BuildContext? _getNavigationContext() {
    try {
      return navigatorKey.currentContext;
    } catch (e) {
      return null;
    }
  }
}