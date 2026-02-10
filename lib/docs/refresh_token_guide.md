# Implementación de Refresh Token en Genius Hormo

Este documento describe la implementación del mecanismo de refresh token en la aplicación Genius Hormo, que permite manejar **proactivamente** la renovación de tokens JWT antes de que expiren, garantizando una experiencia fluida y continua para el usuario sin interrupciones.

## Arquitectura

La implementación se basa en tres componentes principales:

1. **RefreshTokenResponse** - DTO para manejar la respuesta del endpoint de refresh token
2. **TokenInterceptor** - Clase que intercepta errores 401 y maneja la renovación automática del token
3. **executeAuthenticatedRequest** - Función helper para realizar peticiones autenticadas con soporte de refresh token

## Flujo de Funcionamiento

### Enfoque Proactivo (Principal)

```
┌──────────────┌───────────────────┌───────────────────┌──────────────
│                │     │                    │     │                     │     │                 │
│  Aplicación    │─────▶  Verificar token    │─────▶  Por expirar? (<5min) │─────▶  Refrescar token │
│                │     │  antes de la request │     │                     │     │  proactivamente │
└──────────────└─────└───────────────────└─────└───────────────────└─────└──────────────
                                                             │                     │
                                                             │ No                  │
                                                             ▼                    │
┌──────────────┌───────────────────└────────────────────└
│                │     │                    │     
│  Ejecutar      │◄─────│  Realizar request   │◄─────
│  request API    │     │  con nuevo token    │     
└──────────────└─────└───────────────────└
```

### Enfoque Reactivo (Respaldo)

Si a pesar de la verificación proactiva, se recibe un error 401:

```
┌──────────────┌──────────────┌───────────────
│                │     │                 │     │                   │
│  API Request   │─────▶  Error 401       │─────▶ Refrescar Token   │
│                │     │                 │     │                   │
└──────────────└─────└──────────────└─────└───────────────
                                                            │
                                                            ▼
┌──────────────┌──────────────
│                │     │                 │
│  Continuar     │◄─────│  Reintentar     │
│  con app       │     │  Request        │
└──────────────└─────└──────────────└
```

## Endpoints y Respuestas

### Endpoint de Refresh Token

- **URL**: `/token/refresh/`
- **Método**: POST
- **Body**:
  ```json
  {
    "refresh_token": "string"  // Token de refresco obtenido durante el login
  }
  ```

### Respuesta Exitosa (200)

```json
{
  "message": "string",
  "error": "string",
  "data": {
    "access_token": "string",
    "refresh_token": "string"
  }
}
```

### Respuestas de Error

- **401** - Refresh token no válido o expirado
- **400** - Bad request, refresh token no proporcionado

## Implementación

### 1. Definición del DTO

```dart
// lib/features/auth/dto/refresh_token_dto.dart
class RefreshTokenResponse {
  final String accessToken;
  final String refreshToken;

  RefreshTokenResponse({
    required this.accessToken,
    required this.refreshToken,
  });

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) {
    return RefreshTokenResponse(
      accessToken: json['data']['access_token'] as String,
      refreshToken: json['data']['refresh_token'] as String,
    );
  }
}
```

### 2. Método de Refresh Token en AuthService

```dart
// lib/features/auth/services/auth_service.dart
Future<ApiResponse<RefreshTokenResponse>> refreshToken() async {
  try {
    final refreshToken = await _storageService.getRefreshToken();
    
    if (refreshToken == null || refreshToken.isEmpty) {
      return ApiResponse.error(message: 'No hay refresh token disponible');
    }
    
    final url = AppConfig.getApiUrl('token/refresh/');
    final body = json.encode({
      'refresh_token': refreshToken,
    });
    
    final response = await _client.post(
      Uri.parse(url),
      headers: AppConfig.getCommonHeaders(),
      body: body,
    );
    
    if (response.statusCode == 200) {
      final responseData = RefreshTokenResponse.fromJson(json.decode(response.body));
      
      await _storageService.saveJWTToken(responseData.accessToken);
      await _storageService.saveRefreshToken(responseData.refreshToken);
      
      return ApiResponse.success(
        message: 'Tokens refrescados exitosamente',
        data: responseData,
      );
    } else {
      return ApiResponse.error(message: 'Error al refrescar el token');
    }
  } catch (e) {
    return ApiResponse.error(message: 'Error al refrescar el token: $e');
  }
}
```

### 3. Interceptor de Tokens

```dart
// lib/core/api/token_interceptor.dart
class TokenInterceptor {
  // Ver implementación completa en el archivo
  
  static Future<http.Response> executeWithTokenRefresh(
    Future<http.Response> Function(String token) requestFn
  ) async {
    // Verificar proactivamente si el token está por expirar
    if (await _isTokenAboutToExpire(token)) {
      // Refrescar proactivamente antes de la petición
      final newToken = await _refreshToken();
      return await requestFn(newToken);
    }
    
    // Ejecutar solicitud con token actual
    final response = await requestFn(token);
    
    // Si a pesar de todo falla con 401, refrescar y reintentar
    if (response.statusCode == 401) {
      final newToken = await _refreshToken();
      return await requestFn(newToken);
    }
  }
  
  // Verificar si el token expira pronto (menos de 5 minutos)
  static Future<bool> _isTokenAboutToExpire(String token) {
    // Decodifica el token JWT y verifica su tiempo de expiración
  }
}
```

### 4. Helper para Solicitudes Autenticadas

```dart
// lib/core/api/api_helpers.dart
Future<ApiResponse<T>> executeAuthenticatedRequest<T>({
  required Future<http.Response> Function(String token) requestWithToken,
  required T Function(Map<String, dynamic>) fromJson,
}) async {
  try {
    final response = await TokenInterceptor.executeWithTokenRefresh(requestWithToken);
    return handleApiResponse(response, fromJson);
  } catch (e) {
    return ApiResponse.error(message: 'Error: $e');
  }
}
```

## Cómo Usar en Servicios Existentes

Para utilizar el mecanismo de refresh token en servicios existentes, debes migrar las funciones que hacen llamadas a la API autenticada para que usen `executeAuthenticatedRequest`. Ejemplo:

### Antes:

```dart
Future<UserProfileData> getMyProfile({required String token}) async {
  final url = AppConfig.getApiUrl('me/');
  final headers = AppConfig.getCommonHeaders(withAuth: true, token: token);
  
  final response = await _client.get(
    Uri.parse(url),
    headers: headers,
  );
  
  // Procesar respuesta...
}
```

### Después:

```dart
Future<ApiResponse<UserProfileData>> getMyProfile() async {
  return executeAuthenticatedRequest<UserProfileData>(
    requestWithToken: (token) async {
      final url = AppConfig.getApiUrl('me/');
      final headers = AppConfig.getCommonHeaders(withAuth: true, token: token);
      
      return await _client.get(
        Uri.parse(url),
        headers: headers,
      );
    },
    fromJson: UserProfileData.fromJson,
  );
}
```

## Ventajas

1. **Transparencia total para el usuario** - El refresh token ocurre automáticamente sin interacción del usuario
2. **Enfoque proactivo** - Los tokens se renuevan antes de que expiren, evitando incluso los fallos 401
3. **Mantenimiento de la sesión** - Prioriza mantener al usuario conectado en todo momento
4. **Centralización** - Toda la lógica de refresh token está en un solo lugar
5. **Prevención de solicitudes simultáneas** - Se utiliza un completer para evitar múltiples refrescos simultáneos
6. **Facilidad de uso** - Una simple migración de código para implementar en funciones existentes
7. **Doble capa de seguridad** - Si falla la renovación proactiva, también maneja los errores 401

## Consideraciones

- **Continuidad de sesión**: El sistema prioriza mantener la sesión del usuario activa en todo momento
- **Renovación proactiva**: Se verifican los tokens antes de cada petición, renovándolos si están próximos a expirar (menos de 5 minutos)
- **Doble mecanismo de seguridad**: Si falla la verificación proactiva, también se maneja el error 401 automáticamente
- **Coordinación de renovaciones**: Para peticiones simultáneas, solo la primera dispara el refresh y las demás esperan el resultado
- **Manejo de fallos**: Solo en el caso extremo de que ambos tokens (acceso y refresh) estén expirados, será necesario que el usuario inicie sesión nuevamente

## Archivos Involucrados

- `lib/features/auth/dto/refresh_token_dto.dart`
- `lib/features/auth/services/auth_service.dart`
- `lib/features/auth/services/user_storage_service.dart`
- `lib/core/api/token_interceptor.dart`
- `lib/core/api/api_helpers.dart`
- `lib/examples/refresh_token_example.dart`
