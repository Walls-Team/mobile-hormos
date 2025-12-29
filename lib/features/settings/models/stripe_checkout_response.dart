class StripeCheckoutResponse {
  final bool success;
  final String? error;
  final String? checkoutUrl;
  final String? message;
  final String? sessionId;
  final String? customerId;

  StripeCheckoutResponse({
    required this.success,
    this.error,
    this.checkoutUrl,
    this.message,
    this.sessionId,
    this.customerId,
  });

  factory StripeCheckoutResponse.fromJson(Map<String, dynamic> json) {
    // Extraer los datos de la estructura anidada
    Map<String, dynamic>? data;
    if (json.containsKey('data')) {
      data = json['data'] is Map ? Map<String, dynamic>.from(json['data']) : null;
    }
    
    return StripeCheckoutResponse(
      success: json['error'] == null || (json['error'] as String? ?? '').isEmpty,
      error: json['error'],
      // La URL de checkout está en el campo 'url' dentro de 'data'
      // Corregir espacios en la URL que pueden venir de la API
      checkoutUrl: data != null && data.containsKey('url') ? _fixStripeUrl(data['url'] as String) : null,
      message: json['message'],
      sessionId: data != null && data.containsKey('session_id') ? data['session_id'] as String : null,
      customerId: data != null && data.containsKey('customer_id') ? data['customer_id'] as String : null,
    );
  }

  factory StripeCheckoutResponse.error(String errorMessage) {
    return StripeCheckoutResponse(
      success: false,
      error: errorMessage,
    );
  }
  
  /// Corrige problemas comunes en las URLs de Stripe
  static String _fixStripeUrl(String url) {
    // Eliminar espacios en la URL (como en 'cs_tes t_b1xf...')
    String fixedUrl = url.replaceAll(' ', '');
    
    // Asegurarse de que la URL comienza con https://
    if (!fixedUrl.startsWith('http')) {
      fixedUrl = 'https://' + fixedUrl;
    }
    
    print('💳 URL original: $url');
    print('💳 URL corregida: $fixedUrl');
    
    return fixedUrl;
  }
}

class CreateCheckoutSessionRequest {
  final int planId;

  CreateCheckoutSessionRequest({
    required this.planId,
  });

  Map<String, dynamic> toJson() {
    return {
      'plan_id': planId,
    };
  }
}
