/// Configuración centralizada de la aplicación
/// Similar a un .env en Node.js o React
class AppConfig {
  // ========== ENDPOINTS ==========
  
  /// URL base del API backend (para registro y verificación)
  /// Para desarrollo local: 'http://localhost:3000'
  /// Para producción: 'https://main.geniushpro.com'
  static const String baseUrl = 'https://main.geniushpro.com';
  
  /// URL base del API de Login (diferente)
  /// Para desarrollo local: 'http://localhost:3000'
  /// Para producción: 'https://api.geniushpro.com'
  static const String loginBaseUrl = 'https://api.geniushpro.com';
  
  /// URL base de Spike API (terceros)
  static const String spikeApiUrl = 'https://app-api.spikeapi.com/v3';
  
  // ========== API VERSIONS ==========
  static const String apiVersion = 'v1';
  static const String apiBasePath = '/v1/api';
  
  // ========== TIMEOUTS ==========
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const Duration shortTimeout = Duration(seconds: 15);
  static const Duration longTimeout = Duration(seconds: 60);
  
  // ========== STORAGE KEYS ==========
  static const String jwtTokenKey = 'jwt_token';
  static const String userProfileKey = 'cached_user_profile';
  static const String languageKey = 'language';
  
  // ========== FEATURES FLAGS (opcional) ==========
  static const bool enableDeepLinks = true;
  static const bool enableAnalytics = false;
  static const bool debugMode = true;
  
  // ========== MÉTODOS HELPER ==========
  
  /// Construye una URL completa del API
  /// Ejemplo: getApiUrl('/auth/login') => 'http://localhost:3000/v1/api/auth/login'
  static String getApiUrl(String endpoint) {
    // Remover slash inicial si existe
    final cleanEndpoint = endpoint.startsWith('/') 
        ? endpoint.substring(1) 
        : endpoint;
    
    return '$baseUrl$apiBasePath/$cleanEndpoint';
  }
  
  /// Construye una URL sin el prefijo /v1/api
  /// Útil para endpoints legacy o especiales
  static String getBaseUrl(String endpoint) {
    final cleanEndpoint = endpoint.startsWith('/') 
        ? endpoint.substring(1) 
        : endpoint;
    
    return '$baseUrl/$cleanEndpoint';
  }
  
  /// Construye una URL del API de Login
  /// Ejemplo: getLoginUrl('login') => 'https://api.geniushpro.com/login'
  static String getLoginUrl(String endpoint) {
    final cleanEndpoint = endpoint.startsWith('/') 
        ? endpoint.substring(1) 
        : endpoint;
    
    return '$loginBaseUrl/$cleanEndpoint';
  }
  
  /// Retorna headers comunes para todas las requests
  static Map<String, String> getCommonHeaders({
    bool withAuth = false,
    String? token,
  }) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (withAuth && token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }
}
