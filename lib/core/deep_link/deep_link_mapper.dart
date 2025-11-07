import 'genius_hormo_deep_link_data.dart';
import '../navigation/navigation_service.dart';
import 'package:flutter/material.dart';

class DeepLinkMapper {
  final GlobalKey<NavigatorState> navigatorKey;

  DeepLinkMapper({required this.navigatorKey});

  DeepLinkRouteConfig? mapDeepLinkToRoute(GeniusHormoDeepLinkData deepLinkData) {
    final context = _getNavigationContext();
    if (context == null) return null;


    // HOME: https://geniushormo.com/
    if (deepLinkData.isHome) {
      return DeepLinkRouteConfig(
        context: context,
        path: '/',
      );
    }
    
    // TERMS AND CONDITIONS: https://geniushormo.com/terms_and_conditions
    else if (deepLinkData.isTermsAndConditions) {
      return DeepLinkRouteConfig(
        context: context,
        path: '/terms_and_conditions',
      );
    }
    
    // DASHBOARD: https://geniushormo.com/dashboard
    else if (deepLinkData.isDashboard) {
      return DeepLinkRouteConfig(
        context: context,
        path: '/dashboard',
      );
    }
    
    // STATS: https://geniushormo.com/stats
    else if (deepLinkData.isStats) {
      return DeepLinkRouteConfig(
        context: context,
        path: '/stats',
      );
    }
    
    // STORE: https://geniushormo.com/store
    else if (deepLinkData.isStore) {
      return DeepLinkRouteConfig(
        context: context,
        path: '/store',
      );
    }
    
    // SETTINGS: https://geniushormo.com/settings
    else if (deepLinkData.isSettings) {
      return DeepLinkRouteConfig(
        context: context,
        path: '/settings',
      );
    }
    
    // FAQs: https://geniushormo.com/faqs
    else if (deepLinkData.isFaqs) {
      return DeepLinkRouteConfig(
        context: context,
        path: '/faqs',
      );
    }
    
    // LOGIN: https://geniushormo.com/auth/login
    else if (deepLinkData.isLogin) {
      return DeepLinkRouteConfig(
        context: context,
        path: '/auth/login',
      );
    }
    
    // REGISTER: https://geniushormo.com/auth/register
    else if (deepLinkData.isRegister) {
      return DeepLinkRouteConfig(
        context: context,
        path: '/auth/register',
      );
    }
    
    // RESET PASSWORD: https://geniushormo.com/auth/reset_password
    else if (deepLinkData.isResetPassword) {
      return DeepLinkRouteConfig(
        context: context,
        path: '/auth/reset_password',
      );
    }
    
    // FORGOT PASSWORD: https://geniushormo.com/auth/forgot_password
    else if (deepLinkData.isForgotPassword) {
      return DeepLinkRouteConfig(
        context: context,
        path: '/auth/forgot_password',
      );
    }
    
    // EMAIL VERIFICATION: https://geniushormo.com/auth/code_validation
    else if (deepLinkData.isVerificateEmailCode) {
      return DeepLinkRouteConfig(
        context: context,
        path: '/auth/code_validation',
        queryParameters: {
          if (deepLinkData.getQueryParam('email') != null)
            'email': deepLinkData.getQueryParam('email')!,
          if (deepLinkData.getQueryParam('action') != null)
            'action': deepLinkData.getQueryParam('action')!,
        },
      );
    }

    // Ruta no reconocida - redirigir a home
    return DeepLinkRouteConfig(
      context: context,
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