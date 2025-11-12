# 📱 Flujo de Deep Links para Conexión de Dispositivo Spike

## 🎯 ¿Qué son los Deep Links?

Los **deep links** son URLs especiales que permiten abrir tu app directamente desde un navegador externo o desde otra aplicación, y además pueden navegar a una pantalla específica dentro de tu app.

### Tipos de Deep Links:

1. **Custom Scheme** (App Links): `geniushormo://...`
2. **Universal Links** (HTTPS): `https://geniushormo.com/...`

---

## 🔄 Flujo Completo de Conexión del Dispositivo Spike

### **Paso 1: Usuario inicia la conexión desde Settings**

```
Usuario → Tap en "Connect Device" → Settings Screen
```

El usuario hace tap en el botón de conectar dispositivo en Settings.

### **Paso 2: App llama al backend para iniciar integración**

```dart
// En settings.dart
POST /v1/api/spike/add/
Body: { "provider": "whoop" }

Response: {
  "task_id": "abc123",
  "provider": "whoop"
}
```

El backend inicia un **task asíncrono** y devuelve un `task_id`.

### **Paso 3: App hace Long Polling para obtener la URL de autorización**

```dart
// Cada 3 segundos consulta:
GET /v1/api/spike/results/{task_id}/

// Mientras el usuario no autorice en web externa:
Response: { "status": "pending" }

// Cuando el backend prepara la URL:
Response: {
  "status": "completed",
  "result": {
    "data": {
      "integration_url": "https://spike.whoop.com/authorize?..."
    }
  }
}
```

La app espera hasta obtener la **integration_url**.

### **Paso 4: App abre el navegador externo**

```dart
// La app lanza el navegador del sistema
await launchUrl(Uri.parse(integrationUrl));
```

El usuario **sale de la app** y ve la página web de Spike/Whoop donde debe:
- Iniciar sesión con sus credenciales de Whoop
- Dar permiso para que la app acceda a sus datos

### **Paso 5: Usuario autoriza en la web externa**

```
Usuario → Login en Whoop → Autoriza acceso → ✅
```

### **Paso 6: Backend de Spike redirige con Deep Link**

Una vez autorizado, el backend de Spike **redirige automáticamente** al usuario usando un deep link:

```
https://spike.whoop.com → REDIRECCIONA A →
geniushormo://auth/spike/acceptdevice?provider_slug=whoop&user_id=123
```

Este deep link **abre tu app automáticamente** y navega a la pantalla amarilla.

---

## ⚙️ ¿Cómo se Manejan los Deep Links en Flutter?

### **1. Configuración del Deep Link Service**

```dart
// genius_hormo_deep_link_service.dart
class GeniusHormoDeepLinkService {
  // Escucha links entrantes
  void _listenToLinks() {
    _appLinks.uriLinkStream.listen((Uri uri) {
      // Cuando llega: geniushormo://auth/spike/acceptdevice
      _processDeepLink(uri);
    });
  }
}
```

### **2. Parseo del Deep Link**

```dart
// genius_hormo_deep_link_data.dart
final deepLinkData = GeniusHormoDeepLinkData.fromUri(uri);

// URI: geniushormo://auth/spike/acceptdevice?provider_slug=whoop
// Resultado:
// - scheme: "geniushormo"
// - host: "auth"
// - segments: ["spike", "acceptdevice"]
// - queryParameters: {"provider_slug": "whoop", "user_id": "123"}
```

### **3. Mapeo a Rutas de Flutter**

```dart
// deep_link_mapper.dart
DeepLinkRouteConfig? mapDeepLinkToRoute(deepLinkData) {
  if (deepLinkData.segments[0] == 'spike' &&
      deepLinkData.segments[1] == 'acceptdevice') {
    
    return DeepLinkRouteConfig(
      path: '/auth/spike/acceptdevice',
      queryParameters: {...}
    );
  }
}
```

### **4. Navegación con GoRouter**

```dart
// navigation_service.dart
void _navigateToRoute(routeConfig) {
  final router = GoRouter.of(context);
  router.go('/auth/spike/acceptdevice');
}
```

### **5. La App Muestra la Pantalla Amarilla**

```dart
// routes.dart
GoRoute(
  path: '/auth/spike/acceptdevice',
  builder: (context, state) => AcceptDeviceScreen(),
)
```

---

## 📱 Pantalla Accept Device (Pantalla Amarilla)

### **¿Qué hace esta pantalla?**

```dart
class _AcceptDeviceScreenState {
  @override
  void initState() {
    // 1. Obtiene el token del usuario
    final token = await _userStorage.getToken();
    
    // 2. Envía el consent al backend
    POST /v1/api/spike/consent-callback/
    Headers: { Authorization: Bearer <token> }
    Body: { "consent_given": true }
    
    // 3. Si es exitoso, muestra mensaje y botón
    setState(() {
      _success = true;
      _message = 'Dispositivo conectado exitosamente';
    });
  }
}
```

### **Estados de la Pantalla:**

1. **Loading** (⏳):
   - Muestra spinner
   - Texto: "Conectando dispositivo..."

2. **Success** (✅):
   - Icono verde de check
   - Texto: "¡Dispositivo Conectado!"
   - Mensaje: "Dispositivo conectado exitosamente"
   - Botón: "Ir al Dashboard"

3. **Error** (❌):
   - Icono rojo de error
   - Texto: "Error de Conexión"
   - Mensaje: Descripción del error
   - Botón: "Reintentar"
   - Link: "Ir al Dashboard de todas formas"

---

## 🔁 Diagrama de Flujo Completo

```
┌─────────────────────────────────────────────────────────────┐
│ 1. Usuario tap "Connect Device" en Settings                │
└─────────────────┬───────────────────────────────────────────┘
                  ▼
┌─────────────────────────────────────────────────────────────┐
│ 2. POST /spike/add/ → Backend crea task                    │
│    Response: { task_id: "abc123" }                         │
└─────────────────┬───────────────────────────────────────────┘
                  ▼
┌─────────────────────────────────────────────────────────────┐
│ 3. Long Polling: GET /spike/results/abc123/                │
│    (Cada 3 segundos hasta obtener integration_url)         │
└─────────────────┬───────────────────────────────────────────┘
                  ▼
┌─────────────────────────────────────────────────────────────┐
│ 4. App lanza navegador con integration_url                  │
│    Usuario sale de la app → Página web de Whoop            │
└─────────────────┬───────────────────────────────────────────┘
                  ▼
┌─────────────────────────────────────────────────────────────┐
│ 5. Usuario hace login en Whoop y autoriza                  │
└─────────────────┬───────────────────────────────────────────┘
                  ▼
┌─────────────────────────────────────────────────────────────┐
│ 6. Backend de Spike redirige con deep link:                │
│    geniushormo://auth/spike/acceptdevice                    │
└─────────────────┬───────────────────────────────────────────┘
                  ▼
┌─────────────────────────────────────────────────────────────┐
│ 7. App recibe deep link → DeepLinkService lo procesa       │
└─────────────────┬───────────────────────────────────────────┘
                  ▼
┌─────────────────────────────────────────────────────────────┐
│ 8. DeepLinkMapper mapea a ruta Flutter                     │
│    → NavigationService navega a AcceptDeviceScreen         │
└─────────────────┬───────────────────────────────────────────┘
                  ▼
┌─────────────────────────────────────────────────────────────┐
│ 9. AcceptDeviceScreen (Pantalla Amarilla)                  │
│    - Llama POST /spike/consent-callback/                   │
│    - Muestra: "¡Dispositivo Conectado!"                    │
│    - Botón: "Ir al Dashboard"                              │
└─────────────────┬───────────────────────────────────────────┘
                  ▼
┌─────────────────────────────────────────────────────────────┐
│ 10. Usuario tap "Ir al Dashboard" → context.go('/dashboard')│
└─────────────────────────────────────────────────────────────┘
```

---

## 🔑 Conceptos Clave

### **Long Polling**
Es una técnica donde la app consulta repetidamente un endpoint hasta obtener el resultado deseado. En este caso, hasta que el backend tenga la `integration_url`.

### **Deep Link**
URL especial que abre tu app y navega a una pantalla específica.

### **Consent Callback**
Es el endpoint que confirma al backend que el usuario completó la autorización exitosamente.

---

## ✅ Archivos Modificados

1. **spike_providers.dart**
   - Agregado método `consentCallback()`
   - Endpoint: `POST /v1/api/spike/consent-callback/`

2. **accept_device.dart**
   - Pantalla amarilla completamente funcional
   - Llama a `consentCallback()` al cargar
   - Muestra estados: loading, success, error
   - Botón para navegar al dashboard

3. **Archivos de Deep Links** (ya configurados):
   - `genius_hormo_deep_link_service.dart`
   - `deep_link_mapper.dart`
   - `genius_hormo_deep_link_data.dart`
   - `routes.dart`

---

## 🚀 Para Probar

1. Hot restart la app
2. Ve a Settings
3. Tap en "Connect Device"
4. Espera el long polling
5. Se abrirá el navegador con la página de Whoop
6. Haz login y autoriza
7. Automáticamente volverás a la app en la **pantalla amarilla**
8. Verás: "¡Dispositivo Conectado!"
9. Tap en "Ir al Dashboard"

---

## 🛠️ Debugging de Deep Links

Para ver los logs de deep links en la consola:

```
🔗 DeepLinkService: Deep link received
URI completo: geniushormo://auth/spike/acceptdevice?provider_slug=whoop
Scheme: geniushormo
Host: auth
Path: /spike/acceptdevice
Segments: [spike, acceptdevice]
✅ Ruta acceptDevice detectada
```

---

## ❓ FAQ

**P: ¿Por qué necesito long polling?**  
R: Porque el proceso de autorización en Whoop es externo y puede tomar tiempo. El backend necesita comunicarse con Spike primero.

**P: ¿Qué pasa si el usuario cancela la autorización en Whoop?**  
R: El backend no redirigirá con el deep link, y el usuario quedará en el navegador. Puede cerrar el navegador y volver a la app manualmente.

**P: ¿Puedo cambiar el color amarillo?**  
R: Sí, en `accept_device.dart` línea 74: `backgroundColor: const Color(0xFFFFEB3B)`

**P: ¿Funciona en iOS y Android?**  
R: Sí, pero requiere configuración adicional en `AndroidManifest.xml` y `Info.plist` (ya debería estar configurado por el desarrollador anterior).
