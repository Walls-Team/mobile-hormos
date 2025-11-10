// // class GeniusHormoDeepLinkData {
// //   final String path;
// //   final List<String> segments;
// //   final Map<String, String> queryParameters;
// //   final String? fragment;
// //   final String scheme;
// //   final String host;
// //   final GeniusHormoLinkType linkType;

// //   GeniusHormoDeepLinkData({
// //     required this.path,
// //     required this.segments,
// //     required this.queryParameters,
// //     required this.scheme,
// //     required this.host,
// //     required this.linkType,
// //     this.fragment,
// //   });

// //   factory GeniusHormoDeepLinkData.fromUri(Uri uri) {
// //     return GeniusHormoDeepLinkData(
// //       path: uri.path,
// //       segments: uri.pathSegments,
// //       queryParameters: uri.queryParameters,
// //       fragment: uri.fragment,
// //       scheme: uri.scheme,
// //       host: uri.host,
// //       linkType: _determineLinkType(uri),
// //     );
// //   }

// //   static GeniusHormoLinkType _determineLinkType(Uri uri) {
// //     if (uri.host.contains('geniushormo.com')) {
// //       return GeniusHormoLinkType.universalLink;
// //     } else if (uri.scheme == 'geniushormo') {
// //       return GeniusHormoLinkType.customScheme;
// //     }
// //     return GeniusHormoLinkType.other;
// //   }

// //   // ✅ PROPIEDADES ESPECÍFICAS PARA TUS RUTAS
// //   String? get firstSegment => segments.isNotEmpty ? segments[0] : null;
// //   String? get secondSegment => segments.length > 1 ? segments[1] : null;
// //   String? get thirdSegment => segments.length > 2 ? segments[2] : null;
  
// //   String? getQueryParam(String key) => queryParameters[key];
// //   bool hasSegment(String segment) => segments.contains(segment);
  
// //   // 🔥 NUEVAS PROPIEDADES BASADAS EN TUS RUTAS REALES
// //   bool get isHome => path == '/' || path.isEmpty;
// //   bool get isTermsAndConditions => firstSegment == 'terms_and_conditions';
// //   bool get isDashboard => firstSegment == 'dashboard';
// //   bool get isStats => firstSegment == 'stats';
// //   bool get isStore => firstSegment == 'store';
// //   bool get isSettings => firstSegment == 'settings';
// //   bool get isFaqs => firstSegment == 'faqs';
  
// //   // Rutas de autenticación
// //   bool get isAuthRoute => firstSegment == 'auth';
// //   bool get isLogin => isAuthRoute && secondSegment == 'login';
// //   bool get isRegister => isAuthRoute && secondSegment == 'register';
// //   bool get isResetPassword => isAuthRoute && secondSegment == 'reset_password';
// //   bool get isForgotPassword => isAuthRoute && secondSegment == 'forgot_password';
// //   bool get isVerificateEmailCode => isAuthRoute && secondSegment == 'code_validation';

// //   @override
// //   String toString() {
// //     return 'GeniusHormoDeepLinkData{'
// //         'path: $path, '
// //         'segments: $segments, '
// //         'queryParameters: $queryParameters, '
// //         'linkType: $linkType'
// //         '}';
// //   }
// // }

// // enum GeniusHormoLinkType {
// //   universalLink,
// //   customScheme,
// //   other
// // }

// class GeniusHormoDeepLinkData {
//   final String path;
//   final List<String> segments;
//   final Map<String, String> queryParameters;
//   final String? fragment;
//   final String scheme;
//   final String host;
//   final GeniusHormoLinkType linkType;

//   GeniusHormoDeepLinkData({
//     required this.path,
//     required this.segments,
//     required this.queryParameters,
//     required this.scheme,
//     required this.host,
//     required this.linkType,
//     this.fragment,
//   });

//   factory GeniusHormoDeepLinkData.fromUri(Uri uri) {
//     return GeniusHormoDeepLinkData(
//       path: uri.path,
//       segments: uri.pathSegments,
//       queryParameters: uri.queryParameters,
//       fragment: uri.fragment,
//       scheme: uri.scheme,
//       host: uri.host,
//       linkType: _determineLinkType(uri),
//     );
//   }

//   static GeniusHormoLinkType _determineLinkType(Uri uri) {
//     if (uri.host.contains('geniushormo.com')) {
//       return GeniusHormoLinkType.universalLink;
//     } else if (uri.scheme == 'geniushormo') {
//       return GeniusHormoLinkType.customScheme;
//     }
//     return GeniusHormoLinkType.other;
//   }

//   // ✅ PROPIEDADES ESPECÍFICAS PARA TUS RUTAS
//   String? get firstSegment => segments.isNotEmpty ? segments[0] : null;
//   String? get secondSegment => segments.length > 1 ? segments[1] : null;
//   String? get thirdSegment => segments.length > 2 ? segments[2] : null;
  
//   String? getQueryParam(String key) => queryParameters[key];
//   bool hasSegment(String segment) => segments.contains(segment);
  
//   // 🔥 NUEVAS PROPIEDADES BASADAS EN TUS RUTAS REALES
//   bool get isHome => path == '/' || path.isEmpty;
//   bool get isTermsAndConditions => firstSegment == 'terms_and_conditions';
//   bool get isDashboard => firstSegment == 'dashboard';
//   bool get isStats => firstSegment == 'stats';
//   bool get isStore => firstSegment == 'store';
//   bool get isSettings => firstSegment == 'settings';
//   bool get isFaqs => firstSegment == 'faqs';
  
//   // Rutas de autenticación
//   bool get isAuthRoute => firstSegment == 'auth';
//   bool get isLogin => isAuthRoute && secondSegment == 'login';
//   bool get isRegister => isAuthRoute && secondSegment == 'register';
//   bool get isResetPassword => isAuthRoute && secondSegment == 'reset_password';
//   bool get isForgotPassword => isAuthRoute && secondSegment == 'forgot_password';
//   bool get isVerificateEmailCode => isAuthRoute && secondSegment == 'code_validation';
  
//   // ✅ RUTA ACCEPT DEVICE AGREGADA
//   bool get isAcceptDevice => isAuthRoute && 
//                            secondSegment == 'spike' && 
//                            thirdSegment == 'acceptdevice';

//   @override
//   String toString() {
//     return 'GeniusHormoDeepLinkData{'
//         'path: $path, '
//         'segments: $segments, '
//         'queryParameters: $queryParameters, '
//         'linkType: $linkType'
//         '}';
//   }
// }

// enum GeniusHormoLinkType {
//   universalLink,
//   customScheme,
//   other
// }

class GeniusHormoDeepLinkData {
  final String path;
  final List<String> segments;
  final Map<String, String> queryParameters;
  final String? fragment;
  final String scheme;
  final String host;
  final GeniusHormoLinkType linkType;

  GeniusHormoDeepLinkData({
    required this.path,
    required this.segments,
    required this.queryParameters,
    required this.scheme,
    required this.host,
    required this.linkType,
    this.fragment,
  });

  factory GeniusHormoDeepLinkData.fromUri(Uri uri) {
    return GeniusHormoDeepLinkData(
      path: uri.path,
      segments: uri.pathSegments,
      queryParameters: uri.queryParameters,
      fragment: uri.fragment,
      scheme: uri.scheme,
      host: uri.host,
      linkType: _determineLinkType(uri),
    );
  }

  static GeniusHormoLinkType _determineLinkType(Uri uri) {
    if (uri.host.contains('geniushormo.com')) {
      return GeniusHormoLinkType.universalLink;
    } else if (uri.scheme == 'geniushormo') {
      return GeniusHormoLinkType.customScheme;
    }
    return GeniusHormoLinkType.other;
  }

  // ✅ PROPIEDADES ESPECÍFICAS PARA TUS RUTAS
  String? get firstSegment => segments.isNotEmpty ? segments[0] : null;
  String? get secondSegment => segments.length > 1 ? segments[1] : null;
  String? get thirdSegment => segments.length > 2 ? segments[2] : null;
  
  String? getQueryParam(String key) => queryParameters[key];
  bool hasSegment(String segment) => segments.contains(segment);
  
  // 🔥 PROPIEDADES BASADAS EN TUS RUTAS REALES
  bool get isHome => path == '/' || path.isEmpty;
  bool get isTermsAndConditions => firstSegment == 'terms_and_conditions';
  bool get isDashboard => firstSegment == 'dashboard';
  bool get isStats => firstSegment == 'stats';
  bool get isStore => firstSegment == 'store';
  bool get isSettings => firstSegment == 'settings';
  bool get isFaqs => firstSegment == 'faqs';
  
  // Rutas de autenticación
  bool get isAuthRoute => firstSegment == 'auth';
  bool get isLogin => isAuthRoute && secondSegment == 'login';
  bool get isRegister => isAuthRoute && secondSegment == 'register';
  bool get isResetPassword => isAuthRoute && secondSegment == 'reset_password';
  bool get isForgotPassword => isAuthRoute && secondSegment == 'forgot_password';
  bool get isVerificateEmailCode => isAuthRoute && secondSegment == 'code_validation';
  
  // ✅ SOLO AGREGAMOS ESTA PROPIEDAD NUEVA
  bool get isAcceptDevice => isAuthRoute && 
                           secondSegment == 'spike' && 
                           thirdSegment == 'acceptdevice';

  @override
  String toString() {
    return 'GeniusHormoDeepLinkData{'
        'path: $path, '
        'segments: $segments, '
        'queryParameters: $queryParameters, '
        'linkType: $linkType'
        '}';
  }
}

enum GeniusHormoLinkType {
  universalLink,
  customScheme,
  other
}