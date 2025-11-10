# 📡 Documentación de Endpoints - Genius Hormo API

## 🎯 Base URL
- **Desarrollo:** `http://localhost:3000`
- **Producción:** `https://api.geniushormo.com` (actualizar cuando tengas el dominio)

---

## 🔐 Autenticación (AuthService)

### ✅ **Ya Configurados con AppConfig**

| Método | Endpoint | Descripción | Requiere Auth |
|--------|----------|-------------|---------------|
| POST | `/v1/api/register` | Registro de usuario | ❌ |
| POST | `/login` | Login (endpoint legacy sin /v1/api) | ❌ |
| POST | `/v1/api/verify-account` | Verificar cuenta con código OTP | ❌ |
| POST | `/v1/api/resend-otp` | Reenviar código OTP | ❌ |
| POST | `/v1/api/password-reset/request` | Solicitar reset de contraseña | ❌ |
| POST | `/v1/api/password-reset/validate-otp` | Validar código de reset | ❌ |
| POST | `/v1/api/password-reset/confirm` | Confirmar nueva contraseña | ❌ |
| GET | `/v1/api/me` | Obtener perfil del usuario | ✅ |
| GET | `/v1/api/me/update` | Actualizar perfil | ✅ |

---

## 🏠 Dashboard (DashBoardService)

### ⚠️ **PENDIENTE: Actualizar a AppConfig**

**Archivo:** `lib/features/dashboard/services/dashboard_service.dart`

| Método | Endpoint | Descripción | Requiere Auth |
|--------|----------|-------------|---------------|
| GET | `/v1/api/home/basic-metrics` | Métricas básicas de sueño | ✅ |
| GET | `/v1/api/home/energy-levels` | Niveles de energía | ✅ |

**Cambios necesarios:**
1. Agregar `import 'package:genius_hormo/core/config/app_config.dart';`
2. Eliminar `static const String _baseUrl = 'http://localhost:3000';`
3. Reemplazar `'$_baseUrl/v1/api/...'` por `AppConfig.getApiUrl('...')`
4. Reemplazar `_getHeaders()` por `AppConfig.getCommonHeaders()`

---

## 📊 Stats (StatsService)

### ⚠️ **PENDIENTE: Actualizar a AppConfig**

**Archivo:** `lib/features/stats/service/stats_service.dart`

| Método | Endpoint | Descripción | Requiere Auth |
|--------|----------|-------------|---------------|
| GET | `/v1/api/stats/sleep-efficiency` | Eficiencia del sueño | ✅ |
| GET | `/v1/api/stats/sleep-duration` | Duración del sueño | ✅ |
| GET | `/v1/api/stats/heartrate` | Frecuencia cardíaca | ✅ |
| GET | `/v1/api/stats/spo2` | Nivel de oxígeno en sangre | ✅ |
| GET | `/v1/api/stats/calories` | Calorías quemadas | ✅ |
| GET | `/v1/api/stats/sleep-interruptions` | Interrupciones del sueño | ✅ |
| GET | `/health` | Health check del servidor | ❌ |

**Cambios necesarios:**
1. Agregar `import 'package:genius_hormo/core/config/app_config.dart';`
2. Eliminar `static const String _baseUrl = 'http://localhost:3000/v1/api/stats';`
3. Usar `AppConfig.getApiUrl('stats/...')` para todos los endpoints
4. El endpoint `/health` debería ser `AppConfig.getBaseUrl('health')`

---

## 🔌 Spike API Integration (SpikeApiService)

### ⚠️ **PENDIENTE: Actualizar a AppConfig**

**Archivo:** `lib/features/spike/services/spike_providers.dart`

| Método | Endpoint | Descripción | Requiere Auth |
|--------|----------|-------------|---------------|
| POST | `/auth/hmac` | Obtener token HMAC de Spike | ✅ |
| GET | `https://app-api.spikeapi.com/v3/providers/whoop/integration/init_url` | Iniciar integración con Whoop | ✅ (Spike Token) |

**Cambios necesarios:**
1. Agregar `import 'package:genius_hormo/core/config/app_config.dart';`
2. Eliminar `static const String _baseUrl = 'http://localhost:3000';`
3. Para endpoints de tu backend: `AppConfig.getBaseUrl('auth/hmac')`
4. Para Spike API externa: mantener `AppConfig.spikeApiUrl` (ya está en config)

---

## 📝 Endpoints Faltantes (Por Implementar)

Según la estructura del proyecto, estos servicios deberían existir pero no están implementados:

### 🛒 Store Service (NO EXISTE)
**Carpeta:** `lib/features/store/`
**Estado:** Solo tiene la página, falta el servicio

Endpoints sugeridos:
- `GET /v1/api/store/products` - Listar productos
- `GET /v1/api/store/products/:id` - Detalle de producto
- `POST /v1/api/store/purchase` - Realizar compra

### ⚙️ Settings Service (NO EXISTE)
**Carpeta:** `lib/features/settings/`
**Estado:** Solo tiene la página, falta el servicio

Endpoints sugeridos:
- `GET /v1/api/settings` - Obtener configuración del usuario
- `PUT /v1/api/settings` - Actualizar configuración
- `DELETE /v1/api/account` - Eliminar cuenta

### ❓ FAQs Service (NO EXISTE)
**Carpeta:** `lib/features/faqs/`
**Estado:** Solo tiene la página, podría necesitar servicio

Endpoints sugeridos:
- `GET /v1/api/faqs` - Obtener preguntas frecuentes
- `GET /v1/api/support/contact` - Contactar soporte

---

## 🔧 Cómo Actualizar Otros Servicios

### Ejemplo: DashBoardService

**ANTES:**
```dart
class DashBoardService {
  static const String _baseUrl = 'http://localhost:3000';
  
  Future<SleepData> getBasicMetrics({required String token}) async {
    final result = await executeRequest<SleepData>(
      request: _client
          .get(
            Uri.parse('$_baseUrl/v1/api/home/basic-metrics'),
            headers: _getHeaders(withAuth: true, token: token),
          )
          .timeout(const Duration(seconds: 30)),
      fromJson: SleepData.fromJson,
    );
    // ...
  }
  
  Map<String, String> _getHeaders({bool withAuth = false, String? token}) {
    // ...
  }
}
```

**DESPUÉS:**
```dart
import 'package:genius_hormo/core/config/app_config.dart';

class DashBoardService {
  // Eliminar _baseUrl
  
  Future<SleepData> getBasicMetrics({required String token}) async {
    final result = await executeRequest<SleepData>(
      request: _client
          .get(
            Uri.parse(AppConfig.getApiUrl('home/basic-metrics')),
            headers: AppConfig.getCommonHeaders(withAuth: true, token: token),
          )
          .timeout(AppConfig.defaultTimeout),
      fromJson: SleepData.fromJson,
    );
    // ...
  }
  
  // Eliminar método _getHeaders(), ya está en AppConfig
}
```

---

## 🌐 Variables de Entorno Recomendadas

Cuando tu backend esté en producción, actualiza `lib/core/config/app_config.dart`:

```dart
class AppConfig {
  // Cambiar esto según el ambiente
  static const String _environment = 'development'; // 'development' | 'production'
  
  static String get baseUrl {
    switch (_environment) {
      case 'production':
        return 'https://api.geniushormo.com';
      case 'development':
      default:
        return 'http://localhost:3000';
    }
  }
}
```

O mejor aún, usa flavors de Flutter para manejar múltiples ambientes (desarrollo, staging, producción).

---

## ✅ Checklist de Migración

- [x] ✅ AuthService - **YA ACTUALIZADO**
- [ ] ⚠️ DashBoardService - Pendiente
- [ ] ⚠️ StatsService - Pendiente
- [ ] ⚠️ SpikeApiService - Pendiente
- [ ] ❌ StoreService - No implementado
- [ ] ❌ SettingsService - No implementado
- [ ] ❌ FAQsService - No implementado

---

## 🚀 Próximos Pasos

1. **Actualizar servicios restantes** con AppConfig
2. **Implementar servicios faltantes** (Store, Settings, FAQs)
3. **Agregar interceptor HTTP** para logging y manejo de errores global
4. **Implementar refresh token** para renovar JWT automáticamente
5. **Agregar caché inteligente** para reducir llamadas al API
6. **Testing:** Unit tests para cada servicio

---

## 📞 Contacto Backend

Si necesitas que se agreguen nuevos endpoints o cambiar los existentes, comunícate con el equipo de backend con esta documentación.
