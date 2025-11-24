# 🔐 Guía de Autenticación Biométrica

## ✅ Implementación Completada

Se ha implementado un sistema completo de autenticación biométrica para iOS y Android con las siguientes características:

## 📱 Características Implementadas

### 1. **Persistencia de Sesión**
- ✅ Los tokens JWT se guardan en `flutter_secure_storage`
- ✅ La sesión persiste entre reinicios de la app
- ✅ El usuario permanece logueado hasta que cierre sesión manualmente

### 2. **Face ID / Touch ID (iOS)**
- ✅ Soporte para Face ID en iPhones con TrueDepth
- ✅ Soporte para Touch ID en iPhones con sensor de huella
- ✅ Permisos configurados en `Info.plist`

### 3. **Huella Digital (Android)**
- ✅ Soporte para sensores de huella en Android
- ✅ Compatible con Android 6.0+ (API 23+)

### 4. **Login Rápido**
- ✅ Botón de login biométrico en pantalla de bienvenida
- ✅ Login automático sin ingresar credenciales
- ✅ Muestra el email del usuario guardado

## 🎯 Flujos de Usuario

### **Primer Login (Sin biometría habilitada)**
1. Usuario ingresa email y contraseña
2. Login exitoso
3. Se muestra diálogo: "¿Deseas habilitar Face ID/Touch ID?"
4. Si acepta:
   - Se solicita autenticación biométrica
   - Se guardan las credenciales de forma segura
   - Próximo login será rápido
5. Si rechaza:
   - La sesión persiste (tokens guardados)
   - Puede habilitar biometría después desde configuración

### **Próximos Logins (Con biometría habilitada)**
1. Usuario abre la app
2. Ve botón "Continuar con Face ID/Touch ID"
3. Toca el botón
4. Se autentica con Face ID/Touch ID
5. Login automático al dashboard

### **Sin biometría habilitada**
1. Usuario abre la app
2. Si tiene sesión activa (tokens guardados) → Va directo al dashboard
3. Si no tiene sesión → Pantalla de login normal

## 📁 Archivos Creados

### 1. **BiometricAuthService** 
`/lib/features/auth/services/biometric_auth_service.dart`
- Servicio principal de autenticación biométrica
- Métodos principales:
  - `isBiometricAvailable()` - Verifica si el dispositivo soporta biometría
  - `authenticate()` - Solicita autenticación biométrica
  - `enableBiometricAuth()` - Habilita y guarda credenciales
  - `disableBiometricAuth()` - Deshabilita y elimina credenciales
  - `quickLoginWithBiometric()` - Login rápido con biometría

### 2. **BiometricLoginButton**
`/lib/features/auth/widgets/biometric_login_button.dart`
- Widget para login biométrico en welcome screen
- Se oculta automáticamente si no está habilitado
- Muestra el email del usuario guardado

### 3. **BiometricSettings**
`/lib/features/settings/widgets/biometric_settings.dart`
- Widget para gestionar biometría desde settings
- Switch para habilitar/deshabilitar
- Solo se muestra si el dispositivo soporta biometría

## 🔧 Configuración para iOS

Ya configurado en `/ios/Runner/Info.plist`:
```xml
<key>NSFaceIDUsageDescription</key>
<string>Necesitamos acceso a Face ID para permitirle iniciar sesión de forma rápida y segura</string>
```

## 🔧 Configuración para Android

El paquete `local_auth` ya incluye los permisos necesarios en su AndroidManifest.xml.

## 📝 Cómo Agregar el Widget de Configuración

Para agregar el switch de biometría en la pantalla de Settings:

1. Abre `/lib/features/settings/settings.dart`
2. Importa el widget:
```dart
import 'package:genius_hormo/features/settings/widgets/biometric_settings.dart';
```
3. Agrega el widget en la sección de configuración:
```dart
// Dentro de la lista de configuración
BiometricSettings(
  userEmail: _profile?.email, // Opcional: muestra el email
),
```

## 🧪 Cómo Probar

### En iOS Simulator:
1. El simulador soporta Face ID simulado
2. Ve a: `Features > Face ID > Enrolled`
3. Para simular autenticación exitosa: `Features > Face ID > Matching Face`
4. Para simular fallo: `Features > Face ID > Non-matching Face`

### En Android Emulator:
1. El emulador soporta huella simulada
2. Ve a: `Settings > Security > Fingerprint`
3. Registra una huella usando el emulador
4. Para simular huella: Usa el botón en el panel del emulador

### En Dispositivo Real:
- Asegúrate de tener Face ID/Touch ID/Huella configurada en el dispositivo
- La app solicitará autenticación real

## 🔒 Seguridad

### Credenciales Guardadas:
- ✅ Se guardan en `flutter_secure_storage`
- ✅ Encriptadas por el sistema operativo
- ✅ Protegidas por Keychain (iOS) / Keystore (Android)
- ✅ Solo accesibles después de autenticación biométrica exitosa

### Tokens JWT:
- ✅ Guardados en `flutter_secure_storage`
- ✅ Persisten entre sesiones
- ✅ Se eliminan al cerrar sesión

## 📊 Estados de Sesión

| Escenario | Tiene Token | Biometría Habilitada | Resultado |
|-----------|-------------|----------------------|-----------|
| Primera vez | ❌ | ❌ | Login normal |
| Login exitoso | ✅ | ❌ | Ofrecen habilitar biometría |
| Login exitoso (rechazó biometría) | ✅ | ❌ | Sesión activa, login normal próxima vez |
| Login exitoso (aceptó biometría) | ✅ | ✅ | Sesión activa + Login rápido disponible |
| Reabre app con sesión | ✅ | ❌ | Va directo al dashboard |
| Reabre app con biometría | ✅ | ✅ | Muestra botón de login rápido |
| Cierra sesión | ❌ | ✅ | Biometría sigue habilitada para próximo login |

## 🎨 UX/UI

### Botón de Login Biométrico:
- 👆 Solo aparece si la biometría está habilitada
- 👤 Muestra el email del usuario
- 🔄 Muestra estado de carga durante autenticación
- 📱 Icono adaptativo (👤 Face ID, 👆 Touch ID)

### Diálogo de Habilitación:
- 🔐 Aparece automáticamente después del primer login exitoso
- ⚡ Permite habilitar con un toque
- ❌ Se puede rechazar y habilitar después

### Settings:
- ⚙️ Switch para habilitar/deshabilitar
- 🔒 Requiere contraseña para habilitar
- ✅ Confirmación para deshabilitar

## 🚀 Próximos Pasos Sugeridos

1. **Agregar el widget de configuración a Settings**
2. **Probar en dispositivo real iOS/Android**
3. **Personalizar textos/traducciones si es necesario**
4. **Considerar agregar timeout de sesión opcional**

## ❓ FAQ

**P: ¿Funciona en Web?**
R: No, la autenticación biométrica solo funciona en iOS y Android. En Web, la sesión persiste con tokens.

**P: ¿Qué pasa si cambio de contraseña?**
R: Debes deshabilitar y volver a habilitar la biometría para actualizar las credenciales guardadas.

**P: ¿Puedo usar PIN como fallback?**
R: Sí, si el usuario cancela Face ID/Touch ID, puede usar PIN del dispositivo (configurado en `biometricOnly: false`).

**P: ¿Es seguro guardar la contraseña?**
R: Sí, se guarda encriptada en Keychain/Keystore y solo es accesible tras autenticación biométrica exitosa.

## 📞 Soporte

Si tienes dudas o necesitas ayuda, revisa:
- Documentación de `local_auth`: https://pub.dev/packages/local_auth
- Documentación de `flutter_secure_storage`: https://pub.dev/packages/flutter_secure_storage
