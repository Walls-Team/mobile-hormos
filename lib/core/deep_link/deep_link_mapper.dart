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
    // Get navigation context - puede ser null pero continuamos de todos modos
    final BuildContext? context = _getNavigationContext();
    
    print('__________________________  Deep_link_mapper __________________________ ');
    print('🔗 context __________________________ ${context}');
    if (context == null) {
      print('❌ No navigation context available for deep linking');
      // Continuamos de todos modos aunque no haya contexto
    }
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
    // - Path: /stripe/success o /stripe/cancel
    // - Segments: [stripe, success] o [stripe, cancel]
    // O BIEN
    // - Host: stripe
    // - Path: /success o /cancel
    // - Segments: [success] o [cancel]
    print('🔍 STRIPE DEBUG - Revisando condiciones:');
    print('- linkType == customScheme: ${deepLinkData.linkType == GeniusHormoLinkType.customScheme}');
    print('- host == stripe: ${deepLinkData.host == 'stripe'}');
    print('- segments no vacío: ${deepLinkData.segments.isNotEmpty}');
    if (deepLinkData.segments.isNotEmpty) {
      print('- primer segmento: ${deepLinkData.segments[0]}');
      if (deepLinkData.segments.length >= 2) {
        print('- segundo segmento: ${deepLinkData.segments[1]}');
      }
      print('- primer segmento es stripe?: ${deepLinkData.segments[0] == 'stripe'}');
      print('- primer o segundo segmento es success o cancel?: ${(deepLinkData.segments[0] == 'success' || deepLinkData.segments[0] == 'cancel') || (deepLinkData.segments.length >= 2 && (deepLinkData.segments[1] == 'success' || deepLinkData.segments[1] == 'cancel'))}');
    }
    
    // CONDICIÓN CORREGIDA: Ahora maneja ambos formatos posibles
    if (deepLinkData.linkType == GeniusHormoLinkType.customScheme &&
        (
          // Caso 1: host=stripe, segments=[success]
          (deepLinkData.host == 'stripe' &&
          deepLinkData.segments.isNotEmpty &&
          (deepLinkData.segments[0] == 'success' ||
              deepLinkData.segments[0] == 'cancel'))
          ||
          // Caso 2: host='', segments=[stripe, success]
          (deepLinkData.segments.length >= 2 &&
          deepLinkData.segments[0] == 'stripe' &&
          (deepLinkData.segments[1] == 'success' ||
              deepLinkData.segments[1] == 'cancel'))
        )) {
      
      // Determinar el path correcto según el formato detectado
      String stripePath;
      if (deepLinkData.host == 'stripe') {
        // Caso 1: host=stripe, segments=[success] -> /stripe/success
        stripePath = deepLinkData.segments[0] == 'success'
            ? '/stripe/success'
            : '/stripe/cancel';
      } else {
        // Caso 2: segments=[stripe, success] -> /stripe/success
        stripePath = deepLinkData.segments[1] == 'success'
            ? '/stripe/success'
            : '/stripe/cancel';
      }

      print('✅ Ruta Stripe detectada via custom scheme: $stripePath');
      print('🔍 Host detectado: ${deepLinkData.host}');
      print('🔍 Segments: ${deepLinkData.segments}');

      final sessionId = deepLinkData.getQueryParam('session_id');
      print('📋 Session ID encontrado: $sessionId');
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
    // Aunque no tengamos contexto o no reconozcamos la ruta,
    // retornamos una configuración de ruta por defecto
    return DeepLinkRouteConfig(
      context: context,  // puede ser null
      path: '/', 
    );
  }

  BuildContext? _getNavigationContext() {
    try {
      return navigatorKey.currentContext;
    } catch (e) {
      return null;
    }
  }
}