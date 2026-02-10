# Genius Hormo - Mobile App

Cross-platform mobile application developed in **Flutter** for hormone health monitoring. It integrates data from wearable devices (Whoop) to estimate testosterone levels and display metrics for sleep, heart rate, SpO2, and calories.

- **Version:** `1.0.10+4`
- **SDK:** Flutter `^3.9.2`
- **Package name:** `genius_hormo`

---

## Prerequisites

- **Flutter SDK** `>=3.9.2`
- **Dart SDK** (included with Flutter)
- **Xcode** (for iOS) with CocoaPods installed
- **Android Studio** (for Android) with SDK configured
- **Firebase CLI** (for push notifications)

---

## Installation and Execution

```bash
# 1. Clone the repository
git clone <repo-url>
cd mobile-hormos

# 2. Install dependencies
flutter pub get

# 3. Install iOS pods (macOS only)
cd ios && pod install && cd ..

# 4. Run in debug mode
flutter run --debug
```

### Useful Commands

```bash
# Analyze code
flutter analyze

# Run tests
flutter test

# Build for iOS
flutter build ios --release

# Build for Android
flutter build apk --release

# Clean project
flutter clean && flutter pub get
```

---

## Environment Configuration

URL and environment configuration is managed in:

**`lib/core/config/app_config.dart`**

```dart
// Staging (current)
static const String baseUrl = 'http://api-staging.geniushpro.com';

// Production
// static const String baseUrl = 'https://main.geniushpro.com';
```

| Variable | Description |
|---|---|
| `baseUrl` | Backend API base URL |
| `loginBaseUrl` | Authentication base URL |
| `spikeApiUrl` | Spike API URL (wearables) |
| `apiVersion` | API version (`v1`) |
| `defaultTimeout` | Default timeout (30s) |

---

## Project Architecture

```
lib/
├── main.dart                    # App entry point
├── home.dart                    # Main screen with bottom navigation
├── welcome.dart                 # Welcome screen (landing)
│
├── app/                         # Application configuration
│   ├── app.dart                 # Root widget (MaterialApp + GoRouter)
│   ├── routes.dart              # Route definitions
│   ├── route_names.dart         # Route name constants
│   ├── safe_navigation.dart     # Safe navigation (avoids locks)
│   └── hot_restart_wrapper.dart # Clean hot restart wrapper
│
├── core/                        # Core layer (infrastructure)
│   ├── api/
│   │   ├── api_helpers.dart     # Helper for executing HTTP requests
│   │   └── api_response.dart    # Generic API response model
│   ├── auth/
│   │   ├── auth_state_provider.dart   # Global authentication state
│   │   └── auth_redirect_service.dart # Redirection based on auth
│   ├── config/
│   │   └── app_config.dart      # Centralized configuration (URLs, keys)
│   ├── deep_link/               # Deep link handling
│   ├── di/
│   │   └── dependency_injection.dart  # Dependency registration (GetIt)
│   ├── guards/
│   │   └── subscription_guard.dart    # Subscription guard
│   ├── navigation/
│   │   └── navigation_service.dart    # Global navigation service
│   └── utils/                   # Core utilities
│
├── features/                    # Feature modules (feature-based)
│   ├── auth/                    # Authentication
│   ├── dashboard/               # Main dashboard
│   ├── stats/                   # Detailed statistics
│   ├── settings/                # User configuration
│   ├── store/                   # Product store
│   ├── chat/                    # AI Chat
│   ├── daily_questions/         # Daily questionnaire
│   ├── notifications/           # Notification center
│   ├── payments/                # Stripe payments
│   ├── subscription/            # Subscription management
│   ├── spike/                   # Spike API integration (wearables)
│   ├── acceptdevice/            # Accept wearable device
│   ├── setup/                   # User initial setup
│   ├── faqs/                    # FAQs
│   └── terms_and_conditions/    # Terms and conditions
│
├── l10n/                        # Internationalization
│   ├── app_localizations.dart   # Main translations class
│   ├── app_localizations_en.dart # English translations
│   ├── app_localizations_es.dart # Spanish translations
│   └── l10n.dart                # Exports
│
├── models/                      # Global models
├── providers/                   # Global providers
│   ├── lang_service.dart        # Language service
│   └── subscription_provider.dart # Subscription provider
│
├── services/                    # Global services
│   ├── firebase_messaging_service.dart  # Push notifications
│   ├── local_notifications_service.dart # Local notifications
│   ├── notification_api_service.dart    # Notification API
│   ├── profile_service.dart             # Profile service
│   └── whoop_promo_service.dart         # Whoop promotion
│
├── theme/                       # Visual theme
│   ├── theme.dart               # Theme definition (dark/light)
│   └── colors_pallete.dart      # Color palette
│
├── utils/                       # General utilities
└── widgets/                     # Reusable global widgets
```

---

## Feature Structure

Each feature follows a consistent structure:

```
features/<name>/
├── pages/           # Screens (top-level widgets)
├── components/      # Feature-specific widgets
├── dto/             # Data Transfer Objects (data models)
├── services/        # Services (API calls)
├── models/          # Domain models
├── controllers/     # Logic controllers
├── widgets/         # Reusable feature widgets
└── utils/           # Feature utilities
```

---

## Main Features

### Auth (`features/auth/`)

Handles registration, login, email verification, password recovery, and biometric authentication.

| File | Description |
|---|---|
| `pages/login.dart` | Login screen |
| `pages/register.dart` | Registration screen |
| `pages/email_verification/` | Email verification with code |
| `pages/reset_password/` | Password recovery flow |
| `services/auth_service.dart` | Authentication API calls |
| `services/user_storage_service.dart` | Secure token and profile storage |
| `services/biometric_auth_service.dart` | Biometric authentication (Face ID / Touch ID) |
| `dto/user_profile_dto.dart` | User profile DTO |

### Dashboard (`features/dashboard/`)

Main screen that displays user health metrics.

| File | Description |
|---|---|
| `pages/dashboard.dart` | Main dashboard screen |
| `components/testosterone_chart.dart` | Radial chart of estimated testosterone |
| `components/rem_chart.dart` | REM sleep chart |
| `components/sleep_interruptions_chart.dart` | Sleep interruptions chart |
| `components/spo_chart.dart` | SpO2 chart |
| `components/stats.dart` | Stats cards (efficiency, duration, HRV) |
| `services/dashboard_service.dart` | Dashboard API service |
| `dto/health_data.dart` | Main DTO (contains EnergyData + SleepData) |
| `dto/basic_metrics/sleep_data_dto.dart` | Sleep data DTO |
| `dto/basic_metrics/sleep_summary_dto.dart` | Sleep summary DTO |
| `dto/energy_levels/energy_data.dart` | Energy level data DTO |
| `dto/energy_levels/energy_stats.dart` | Energy statistics DTO |

**Dashboard Endpoints:**
- `GET /v1/api/home/basic-metrics` → Basic sleep metrics
- `GET /v1/api/home/energy-levels` → Energy/testosterone levels

### Stats (`features/stats/`)

Detailed statistics screen with weekly filters.

| File | Description |
|---|---|
| `stats.dart` | Main statistics screen |
| `components/sleep_efficiency_bar_chart.dart` | Sleep efficiency chart |
| `components/sleep_duration_chart.dart` | Sleep duration chart |
| `components/heart_rate_resting_chart.dart` | Heart rate chart |
| `components/spo2_chart.dart` | SpO2 chart |
| `components/calories_burned_chart.dart` | Calories chart |
| `components/sleep_interruptions_stat_chart.dart` | Interruptions chart |
| `components/data_sync_warning.dart` | Synchronization warning widget |
| `service/stats_service.dart` | Statistics API service |
| `dto/dtos.dart` | All statistics DTOs |

**Stats Endpoints:**
- `GET /v1/api/stats/sleep-efficiency`
- `GET /v1/api/stats/sleep-duration`
- `GET /v1/api/stats/heartrate`
- `GET /v1/api/stats/spo2`
- `GET /v1/api/stats/calories`
- `GET /v1/api/stats/sleep-interruptions`

**Time Filters:** 1 week, 2 weeks, 3 weeks, 4 weeks.

### Settings (`features/settings/`)

User profile configuration, devices, language, and account settings.

| File | Description |
|---|---|
| `settings.dart` | Main settings screen |
| `widgets/profile_form.dart` | Profile form |
| `widgets/height_picker.dart` | Height selector (metric/imperial) |
| `widgets/weight_picker.dart` | Weight selector |
| `widgets/birth_date_picker.dart` | Birth date selector |
| `services/plans_api_service.dart` | Plans/subscriptions service |
| `services/stripe_api_service.dart` | Stripe payments service |

### Chat (`features/chat/`)

AI assistant chat for health consultations.

### Store (`features/store/`)

Store with recommended products (vitamins, devices, laboratories).

### Spike (`features/spike/`)

Integration with Spike API to connect wearable devices (Whoop).

---

## Dependency Injection

**GetIt** is used as a service locator. All dependencies are registered in:

**`lib/core/di/dependency_injection.dart`**

Registered services:
- `AuthService` — Authentication
- `UserStorageService` — Secure storage
- `BiometricAuthService` — Biometrics
- `DashBoardService` — Dashboard API
- `StatsService` — Statistics API
- `SpikeApiService` — Wearables API
- `PlansApiService` — Plans/subscriptions
- `StripeApiService` — Stripe payments
- `FirebaseMessagingService` — Push notifications
- `LocalNotificationsService` — Local notifications
- `NotificationApiService` — Notifications API
- `LanguageService` — Language
- `WhoopPromoService` — Whoop promotion
- `SetupStatusService` — Setup state
- `SubscriptionProvider` — Subscription
- `NavigationService` — Global navigation
- `GeniusHormoDeepLinkService` — Deep links

---

## Navigation

**GoRouter** is used for declarative navigation.

### Public routes (no authentication)

| Route | Screen |
|---|---|
| `/` | Welcome (landing) |
| `/auth/login` | Login |
| `/auth/register` | Register |
| `/auth/forgot_password` | Password recovery |

### Private routes (authentication required)

| Route | Screen |
|---|---|
| `/dashboard` | Home (with bottom nav) |
| `/stats` | Statistics |
| `/store` | Store |
| `/settings` | Settings |
| `/auth/spike/acceptdevice` | Accept device |
| `/stripe/success` | Payment successful |
| `/stripe/cancel` | Payment canceled |

Authentication is automatically validated in GoRouter's `redirect` using `AuthRedirectService`.

---

## Internationalization (i18n)

Supported languages: **Spanish** (`es`) and **English** (`en`).

Translation files are located in `lib/l10n/`:
- `app_localizations_es.dart` — Spanish translations
- `app_localizations_en.dart` — English translations

### Usage in code

```dart
// Access via [] operator
final localizations = AppLocalizations.of(context)!;
localizations['dashboard']['sleepEfficiency']

// Access via typed getters
localizations.dashboardOverview
localizations.settingsPersonalData
```

---

## 404 Error Handling (No Data)

When the backend responds with **HTTP 404** indicating that no data is available (new user or Whoop not synchronized), the app:

1. **Shows no error** — Instead of crashing, it returns empty DTOs
2. **Shows graphs with zero values** — All charts render with zero values
3. **Shows warning** — `DataSyncWarning` widget informs the user to wait 24h for synchronization

### Files involved

- `lib/features/stats/service/stats_service.dart` — `_safeGet()` fallback per endpoint
- `lib/features/dashboard/services/dashboard_service.dart` — `.catchError()` for each future
- `lib/features/stats/components/data_sync_warning.dart` — Warning widget
- All DTOs have `empty()` factory to create empty instances
- `AllStats.isSynchronizing` and `HealthData.isSynchronizing` detect empty state

---

## Push Notifications

**Firebase Cloud Messaging (FCM)** is used for push notifications.

- `lib/services/firebase_messaging_service.dart` — FCM configuration
- `lib/services/local_notifications_service.dart` — Local notifications
- `lib/services/notification_api_service.dart` — Notification API
- `lib/features/notifications/notifications_screen.dart` — Notification center

### Firebase Configuration

- **Android:** `android/app/google-services.json`
- **iOS:** `ios/Runner/GoogleService-Info.plist`

---

## Theme and Styles

The theme is defined in `lib/theme/`:

- `theme.dart` — Main theme (supports dark mode)
- `colors_pallete.dart` — Custom color palette

**Syncfusion Flutter Charts** (`syncfusion_flutter_charts`) are used for graphs.

---

## Main Dependencies

| Package | Usage |
|---|---|
| `go_router` | Declarative navigation |
| `get_it` | Dependency injection |
| `provider` | State management |
| `http` | HTTP client |
| `firebase_core` | Firebase base |
| `firebase_messaging` | Push notifications |
| `syncfusion_flutter_charts` | Data charts |
| `flutter_secure_storage` | Secure storage |
| `shared_preferences` | Local preferences |
| `local_auth` | Biometric authentication |
| `flutter_localization` | Internationalization |
| `intl` | Date/number formatting |
| `app_links` | Deep links |
| `url_launcher` | Open external URLs |
| `glassmorphism` | Glass UI effects |
| `equatable` | Object comparison |
| `flutter_svg` | SVG support |
| `timeago` | Relative dates |
| `numberpicker` | Numeric selector |
| `percent_indicator` | Percentage indicators |
| `dartz` | Functional programming |

---

## Application Flow

```
main.dart
  ├── Firebase.initializeApp()
  ├── setupDependencies()          (GetIt)
  ├── AuthStateProvider.init()     (verify session)
  └── runApp(GeniusHormoApp)
        └── GoRouter redirect
              ├── No session → WelcomeScreen → Login/Register
              └── With session → HomeScreen (bottom nav)
                    ├── Tab 0: DashboardScreen
                    ├── Tab 1: StatsScreen
                    ├── Tab 2: StoreScreen
                    └── Tab 3: SettingsScreen
```

---

## Asset Structure

```
assets/
└── images/
    ├── icon.jpg          # App icon
    ├── logo.png          # Main logo
    ├── logo_2.png        # Alternative logo
    └── splashicon.png    # Splash screen icon
```

---

## Supported Platforms

| Platform | Status |
|---|---|
| iOS | ✅ Primary |
| Android | ✅ Primary |
| Web | ⚠️ Experimental |
| macOS | ⚠️ Experimental |
| Linux | ⚠️ Experimental |
| Windows | ⚠️ Experimental |
