# Genius Hormo - Mobile App

Aplicación móvil multiplataforma desarrollada en **Flutter** para el monitoreo de salud hormonal. Integra datos de dispositivos wearables (Whoop) para estimar niveles de testosterona y mostrar métricas de sueño, frecuencia cardíaca, SpO2 y calorías.

- **Versión:** `1.0.9+3`
- **SDK:** Flutter `^3.9.2`
- **Package name:** `genius_hormo`

---

## Requisitos previos

- **Flutter SDK** `>=3.9.2`
- **Dart SDK** (incluido con Flutter)
- **Xcode** (para iOS) con CocoaPods instalado
- **Android Studio** (para Android) con SDK configurado
- **Firebase CLI** (para notificaciones push)

---

## Instalación y ejecución

```bash
# 1. Clonar el repositorio
git clone <repo-url>
cd mobile-hormos

# 2. Instalar dependencias
flutter pub get

# 3. Instalar pods de iOS (solo macOS)
cd ios && pod install && cd ..

# 4. Ejecutar en modo debug
flutter run --debug


### Comandos útiles

```bash
# Analizar código
flutter analyze

# Ejecutar tests
flutter test

# Build para iOS
flutter build ios --release

# Build para Android
flutter build apk --release

# Limpiar proyecto
flutter clean && flutter pub get
```

---

## Configuración de entornos

La configuración de URLs y entornos se maneja en:

**`lib/core/config/app_config.dart`**

```dart
// Staging (actual)
static const String baseUrl = 'http://api-staging.geniushpro.com';

// Producción
// static const String baseUrl = 'https://main.geniushpro.com';
```

| Variable | Descripción |
|---|---|
| `baseUrl` | URL base del API backend |
| `loginBaseUrl` | URL base para autenticación |
| `spikeApiUrl` | URL del API de Spike (wearables) |
| `apiVersion` | Versión del API (`v1`) |
| `defaultTimeout` | Timeout por defecto (30s) |

---

## Arquitectura del proyecto

```
lib/
├── main.dart                    # Entry point de la app
├── home.dart                    # Pantalla principal con bottom navigation
├── welcome.dart                 # Pantalla de bienvenida (landing)
│
├── app/                         # Configuración de la aplicación
│   ├── app.dart                 # Widget raíz (MaterialApp + GoRouter)
│   ├── routes.dart              # Definición de todas las rutas
│   ├── route_names.dart         # Constantes de nombres de rutas
│   ├── safe_navigation.dart     # Navegación segura (evita locks)
│   └── hot_restart_wrapper.dart # Wrapper para hot restart limpio
│
├── core/                        # Capa core (infraestructura)
│   ├── api/
│   │   ├── api_helpers.dart     # Helper para ejecutar requests HTTP
│   │   └── api_response.dart    # Modelo genérico de respuesta API
│   ├── auth/
│   │   ├── auth_state_provider.dart   # Estado global de autenticación
│   │   └── auth_redirect_service.dart # Redirección según auth
│   ├── config/
│   │   └── app_config.dart      # Configuración centralizada (URLs, keys)
│   ├── deep_link/               # Manejo de deep links
│   ├── di/
│   │   └── dependency_injection.dart  # Registro de dependencias (GetIt)
│   ├── guards/
│   │   └── subscription_guard.dart    # Guard de suscripción
│   ├── navigation/
│   │   └── navigation_service.dart    # Servicio de navegación global
│   └── utils/                   # Utilidades core
│
├── features/                    # Módulos de funcionalidad (feature-based)
│   ├── auth/                    # Autenticación
│   ├── dashboard/               # Dashboard principal
│   ├── stats/                   # Estadísticas detalladas
│   ├── settings/                # Configuración de usuario
│   ├── store/                   # Tienda de productos
│   ├── chat/                    # Chat con IA
│   ├── daily_questions/         # Cuestionario diario
│   ├── notifications/           # Centro de notificaciones
│   ├── payments/                # Pagos con Stripe
│   ├── subscription/            # Gestión de suscripción
│   ├── spike/                   # Integración con Spike API (wearables)
│   ├── acceptdevice/            # Aceptar dispositivo wearable
│   ├── setup/                   # Setup inicial del usuario
│   ├── faqs/                    # Preguntas frecuentes
│   └── terms_and_conditions/    # Términos y condiciones
│
├── l10n/                        # Internacionalización
│   ├── app_localizations.dart   # Clase principal de traducciones
│   ├── app_localizations_en.dart # Traducciones en inglés
│   ├── app_localizations_es.dart # Traducciones en español
│   └── l10n.dart                # Exportaciones
│
├── models/                      # Modelos globales
├── providers/                   # Providers globales
│   ├── lang_service.dart        # Servicio de idioma
│   └── subscription_provider.dart # Provider de suscripción
│
├── services/                    # Servicios globales
│   ├── firebase_messaging_service.dart  # Notificaciones push
│   ├── local_notifications_service.dart # Notificaciones locales
│   ├── notification_api_service.dart    # API de notificaciones
│   ├── profile_service.dart             # Servicio de perfil
│   └── whoop_promo_service.dart         # Promoción Whoop
│
├── theme/                       # Tema visual
│   ├── theme.dart               # Definición del tema (dark/light)
│   └── colors_pallete.dart      # Paleta de colores
│
├── utils/                       # Utilidades generales
└── widgets/                     # Widgets reutilizables globales
```

---

## Estructura de cada feature

Cada feature sigue una estructura consistente:

```
features/<nombre>/
├── pages/           # Pantallas (widgets de nivel superior)
├── components/      # Widgets específicos del feature
├── dto/             # Data Transfer Objects (modelos de datos)
├── services/        # Servicios (llamadas API)
├── models/          # Modelos de dominio
├── controllers/     # Controladores de lógica
├── widgets/         # Widgets reutilizables del feature
└── utils/           # Utilidades del feature
```

---

## Features principales

### Auth (`features/auth/`)

Maneja registro, login, verificación de email, recuperación de contraseña y autenticación biométrica.

| Archivo | Descripción |
|---|---|
| `pages/login.dart` | Pantalla de inicio de sesión |
| `pages/register.dart` | Pantalla de registro |
| `pages/email_verification/` | Verificación de email con código |
| `pages/reset_password/` | Flujo de recuperación de contraseña |
| `services/auth_service.dart` | Llamadas API de autenticación |
| `services/user_storage_service.dart` | Almacenamiento seguro de tokens y perfil |
| `services/biometric_auth_service.dart` | Autenticación biométrica (Face ID / Touch ID) |
| `dto/user_profile_dto.dart` | DTO del perfil de usuario |

### Dashboard (`features/dashboard/`)

Pantalla principal que muestra las métricas de salud del usuario.

| Archivo | Descripción |
|---|---|
| `pages/dashboard.dart` | Pantalla principal del dashboard |
| `components/testosterone_chart.dart` | Gráfico radial de testosterona estimada |
| `components/rem_chart.dart` | Gráfico de sueño REM |
| `components/sleep_interruptions_chart.dart` | Gráfico de interrupciones de sueño |
| `components/spo_chart.dart` | Gráfico de SpO2 |
| `components/stats.dart` | Tarjetas de estadísticas (eficiencia, duración, HRV) |
| `services/dashboard_service.dart` | Servicio API del dashboard |
| `dto/health_data.dart` | DTO principal (contiene EnergyData + SleepData) |
| `dto/basic_metrics/sleep_data_dto.dart` | DTO de datos de sueño |
| `dto/basic_metrics/sleep_summary_dto.dart` | DTO de resumen de sueño |
| `dto/energy_levels/energy_data.dart` | DTO de niveles de energía |
| `dto/energy_levels/energy_stats.dart` | DTO de estadísticas de energía |

**Endpoints del Dashboard:**
- `GET /v1/api/home/basic-metrics` → Métricas básicas de sueño
- `GET /v1/api/home/energy-levels` → Niveles de energía/testosterona

### Stats (`features/stats/`)

Pantalla de estadísticas detalladas con filtros por semanas.

| Archivo | Descripción |
|---|---|
| `stats.dart` | Pantalla principal de estadísticas |
| `components/sleep_efficiency_bar_chart.dart` | Gráfico de eficiencia de sueño |
| `components/sleep_duration_chart.dart` | Gráfico de duración de sueño |
| `components/heart_rate_resting_chart.dart` | Gráfico de frecuencia cardíaca |
| `components/spo2_chart.dart` | Gráfico de SpO2 |
| `components/calories_burned_chart.dart` | Gráfico de calorías |
| `components/sleep_interruptions_stat_chart.dart` | Gráfico de interrupciones |
| `components/data_sync_warning.dart` | Widget de advertencia de sincronización |
| `service/stats_service.dart` | Servicio API de estadísticas |
| `dto/dtos.dart` | Todos los DTOs de estadísticas |

**Endpoints de Stats:**
- `GET /v1/api/stats/sleep-efficiency`
- `GET /v1/api/stats/sleep-duration`
- `GET /v1/api/stats/heartrate`
- `GET /v1/api/stats/spo2`
- `GET /v1/api/stats/calories`
- `GET /v1/api/stats/sleep-interruptions`

**Filtros de tiempo:** 1 semana, 2 semanas, 3 semanas, 4 semanas.

### Settings (`features/settings/`)

Configuración del perfil del usuario, dispositivos, idioma y cuenta.

| Archivo | Descripción |
|---|---|
| `settings.dart` | Pantalla principal de ajustes |
| `widgets/profile_form.dart` | Formulario de perfil |
| `widgets/height_picker.dart` | Selector de altura (métrico/imperial) |
| `widgets/weight_picker.dart` | Selector de peso |
| `widgets/birth_date_picker.dart` | Selector de fecha de nacimiento |
| `services/plans_api_service.dart` | Servicio de planes/suscripciones |
| `services/stripe_api_service.dart` | Servicio de pagos Stripe |

### Chat (`features/chat/`)

Chat con asistente de IA para consultas de salud.

### Store (`features/store/`)

Tienda con productos recomendados (vitaminas, dispositivos, laboratorios).

### Spike (`features/spike/`)

Integración con Spike API para conectar dispositivos wearables (Whoop).

---

## Inyección de dependencias

Se usa **GetIt** como service locator. Todas las dependencias se registran en:

**`lib/core/di/dependency_injection.dart`**

Servicios registrados:
- `AuthService` — Autenticación
- `UserStorageService` — Almacenamiento seguro
- `BiometricAuthService` — Biometría
- `DashBoardService` — Dashboard API
- `StatsService` — Estadísticas API
- `SpikeApiService` — Wearables API
- `PlansApiService` — Planes/suscripciones
- `StripeApiService` — Pagos Stripe
- `FirebaseMessagingService` — Push notifications
- `LocalNotificationsService` — Notificaciones locales
- `NotificationApiService` — API de notificaciones
- `LanguageService` — Idioma
- `WhoopPromoService` — Promoción Whoop
- `SetupStatusService` — Estado del setup
- `SubscriptionProvider` — Suscripción
- `NavigationService` — Navegación global
- `GeniusHormoDeepLinkService` — Deep links

---

## Navegación

Se usa **GoRouter** para la navegación declarativa.

### Rutas públicas (sin autenticación)

| Ruta | Pantalla |
|---|---|
| `/` | Welcome (landing) |
| `/auth/login` | Login |
| `/auth/register` | Registro |
| `/auth/forgot_password` | Recuperar contraseña |

### Rutas privadas (requieren autenticación)

| Ruta | Pantalla |
|---|---|
| `/dashboard` | Home (con bottom nav) |
| `/stats` | Estadísticas |
| `/store` | Tienda |
| `/settings` | Ajustes |
| `/auth/spike/acceptdevice` | Aceptar dispositivo |
| `/stripe/success` | Pago exitoso |
| `/stripe/cancel` | Pago cancelado |

La autenticación se valida automáticamente en el `redirect` de GoRouter usando `AuthRedirectService`.

---

## Internacionalización (i18n)

Idiomas soportados: **Español** (`es`) e **Inglés** (`en`).

Los archivos de traducción están en `lib/l10n/`:
- `app_localizations_es.dart` — Traducciones en español
- `app_localizations_en.dart` — Traducciones en inglés

### Uso en código

```dart
// Acceso por operador []
final localizations = AppLocalizations.of(context)!;
localizations['dashboard']['sleepEfficiency']

// Acceso por getters tipados
localizations.dashboardOverview
localizations.settingsPersonalData
```

---

## Manejo de errores 404 (sin datos)

Cuando el backend responde con **HTTP 404** indicando que no hay datos disponibles (usuario nuevo o Whoop no sincronizado), la app:

1. **No muestra error** — En lugar de crashear, retorna DTOs vacíos
2. **Muestra gráficos en cero** — Todos los charts se renderizan con valores 0
3. **Muestra advertencia** — Widget `DataSyncWarning` indica al usuario que debe esperar 24h para sincronizar

### Archivos involucrados

- `lib/features/stats/service/stats_service.dart` — `_safeGet()` fallback por endpoint
- `lib/features/dashboard/services/dashboard_service.dart` — `.catchError()` en cada future
- `lib/features/stats/components/data_sync_warning.dart` — Widget de advertencia
- Todos los DTOs tienen factory `empty()` para crear instancias vacías
- `AllStats.isSynchronizing` y `HealthData.isSynchronizing` detectan estado vacío

---

## Notificaciones push

Se usa **Firebase Cloud Messaging (FCM)** para notificaciones push.

- `lib/services/firebase_messaging_service.dart` — Configuración de FCM
- `lib/services/local_notifications_service.dart` — Notificaciones locales
- `lib/services/notification_api_service.dart` — API de notificaciones
- `lib/features/notifications/notifications_screen.dart` — Centro de notificaciones

### Configuración Firebase

- **Android:** `android/app/google-services.json`
- **iOS:** `ios/Runner/GoogleService-Info.plist`

---

## Tema y estilos

El tema se define en `lib/theme/`:

- `theme.dart` — Tema principal (soporta dark mode)
- `colors_pallete.dart` — Paleta de colores personalizada

Se usan gráficos de **Syncfusion Flutter Charts** (`syncfusion_flutter_charts`).

---

## Dependencias principales

| Paquete | Uso |
|---|---|
| `go_router` | Navegación declarativa |
| `get_it` | Inyección de dependencias |
| `provider` | State management |
| `http` | Cliente HTTP |
| `firebase_core` | Firebase base |
| `firebase_messaging` | Push notifications |
| `syncfusion_flutter_charts` | Gráficos de datos |
| `flutter_secure_storage` | Almacenamiento seguro |
| `shared_preferences` | Preferencias locales |
| `local_auth` | Autenticación biométrica |
| `flutter_localization` | Internacionalización |
| `intl` | Formateo de fechas/números |
| `app_links` | Deep links |
| `url_launcher` | Abrir URLs externas |
| `glassmorphism` | Efectos de vidrio en UI |
| `equatable` | Comparación de objetos |
| `flutter_svg` | Soporte SVG |
| `timeago` | Fechas relativas |
| `numberpicker` | Selector numérico |
| `percent_indicator` | Indicadores de porcentaje |
| `dartz` | Programación funcional |

---

## Flujo de la aplicación

```
main.dart
  ├── Firebase.initializeApp()
  ├── setupDependencies()          (GetIt)
  ├── AuthStateProvider.init()     (verificar sesión)
  └── runApp(GeniusHormoApp)
        └── GoRouter redirect
              ├── Sin sesión → WelcomeScreen → Login/Register
              └── Con sesión → HomeScreen (bottom nav)
                    ├── Tab 0: DashboardScreen
                    ├── Tab 1: StatsScreen
                    ├── Tab 2: StoreScreen
                    └── Tab 3: SettingsScreen
```

---

## Estructura de assets

```
assets/
└── images/
    ├── icon.jpg          # Icono de la app
    ├── logo.png          # Logo principal
    ├── logo_2.png        # Logo alternativo
    └── splashicon.png    # Icono de splash screen
```

---

## Plataformas soportadas

| Plataforma | Estado |
|---|---|
| iOS | ✅ Principal |
| Android | ✅ Principal |
| Web | ⚠️ Experimental |
| macOS | ⚠️ Experimental |
| Linux | ⚠️ Experimental |
| Windows | ⚠️ Experimental |
