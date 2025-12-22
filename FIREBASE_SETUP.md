# 🔥 Guía de Configuración de Firebase Cloud Messaging (FCM)

## ✅ Lo que ya está hecho (en el código)

- ✅ Dependencias agregadas en `pubspec.yaml`
- ✅ Firebase Core y Messaging configurados en `main.dart`
- ✅ Servicio de notificaciones creado (`firebase_messaging_service.dart`)
- ✅ iOS configurado en `AppDelegate.swift`
- ✅ Android configurado en `build.gradle.kts`
- ✅ Inicialización automática en `home.dart`

---

## 📋 Pasos que DEBES completar

### **PASO 1: Descargar archivos de configuración de Firebase**

#### 1.1 Para Android (`google-services.json`)

1. Ve a [Firebase Console](https://console.firebase.google.com)
2. Selecciona tu proyecto
3. Click en el ⚙️ (Configuración del proyecto)
4. Baja hasta **"Tus apps"**
5. Busca tu app Android o agrégala si no existe:
   - **Nombre del paquete Android:** `com.wallsdev.genius_hormo`
   - Click en **"Registrar app"** si es nueva
6. **Descarga `google-services.json`**
7. **Coloca el archivo en:**
   ```
   /Users/luisparedes/Desktop/mobile-hormos/android/app/google-services.json
   ```

#### 1.2 Para iOS (ya tienes el archivo)

- ✅ Ya tienes `/ios/Runner/GoogleService-Info.plist`
- Si necesitas actualizarlo, descárgalo de Firebase Console y reemplázalo

---

### **PASO 2: Instalar dependencias de Flutter**

Ejecuta en la terminal:

```bash
cd /Users/luisparedes/Desktop/mobile-hormos
flutter pub get
```

---

### **PASO 3: Configurar iOS (Capabilities en Xcode)**

1. Abre el proyecto iOS en Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. Selecciona el target **"Runner"** en el navegador de proyectos

3. Ve a la pestaña **"Signing & Capabilities"**

4. Click en **"+ Capability"**

5. Agrega:
   - **Push Notifications** ← IMPORTANTE
   - **Background Modes** ← IMPORTANTE
     - Dentro de Background Modes, marca:
       - ✅ Remote notifications
       - ✅ Background fetch (opcional)

6. Cierra Xcode

---

### **PASO 4: Configurar APNs en Firebase Console (Solo iOS)**

1. Ve a [Firebase Console](https://console.firebase.google.com)
2. Selecciona tu proyecto
3. Ve a **Configuración del proyecto** → Pestaña **"Cloud Messaging"**
4. Scroll hasta **"Apple app configuration"**
5. Sube tu **APNs Authentication Key** o **Certificate**:

   **Opción A - Authentication Key (Recomendado):**
   - Ve a [Apple Developer Portal](https://developer.apple.com/account/resources/authkeys/list)
   - Crea una nueva Key con **"Apple Push Notifications service (APNs)"**
   - Descarga el archivo `.p8`
   - Sube el archivo en Firebase
   - Ingresa el **Key ID** y **Team ID**

   **Opción B - Certificate:**
   - Genera un certificado APNs desde Xcode o Keychain
   - Sube el archivo `.p12` en Firebase

---

### **PASO 5: Limpiar y Compilar**

```bash
# Limpiar proyecto
flutter clean

# Reinstalar pods de iOS
cd ios
pod install
cd ..

# Reinstalar dependencias
flutter pub get

# Compilar Android
flutter build apk --debug

# Compilar iOS
flutter build ios --debug
```

---

### **PASO 6: Probar notificaciones**

#### Desde Firebase Console:

1. Ve a **"Cloud Messaging"** en el menú izquierdo
2. Click en **"Enviar tu primera notificación"**
3. Completa:
   - **Título:** "Prueba"
   - **Texto:** "Esta es una prueba de notificación"
4. Click en **"Enviar mensaje de prueba"**
5. Pega el **FCM Token** (lo verás en los logs de la app cuando se inicie)
6. Click en **"Probar"**

#### Verificar en logs:

Cuando ejecutes la app, busca estos logs:

```
🔥 Inicializando Firebase...
✅ Firebase inicializado
🔔 Inicializando Firebase Messaging...
📱 Permiso de notificaciones: authorized
🎫 FCM Token: [tu-token-aquí]
✅ Firebase Messaging inicializado correctamente
✅ Suscrito al topic: all_users
✅ Suscrito al topic: complete_profiles
```

---

## 🎯 Estructura de Notificaciones

### Tipos de notificaciones soportadas:

1. **daily_reminder** - Recordatorio del cuestionario diario
2. **new_data** - Nuevos datos disponibles
3. **device_sync** - Sincronización del dispositivo

### Formato del payload:

```json
{
  "notification": {
    "title": "Título",
    "body": "Mensaje"
  },
  "data": {
    "type": "daily_reminder",
    "click_action": "FLUTTER_NOTIFICATION_CLICK"
  }
}
```

---

## 📱 Topics disponibles:

- `all_users` - Todos los usuarios
- `complete_profiles` - Usuarios con perfil completo
- `device_connected` - Usuarios con dispositivo conectado

---

## 🔧 Comandos útiles

```bash
# Ver logs en tiempo real (Android)
adb logcat | grep -i firebase

# Ver logs en tiempo real (iOS)
# En Xcode: Product → Scheme → Edit Scheme → Run → Arguments
# Agregar: -FIRDebugEnabled

# Limpiar todo
flutter clean
cd ios && pod deintegrate && pod install && cd ..
flutter pub get
```

---

## ⚠️ Solución de problemas comunes

### Error: "google-services.json not found"
- Asegúrate de que el archivo esté en `android/app/google-services.json`
- NO en `android/google-services.json`

### Error: "No Firebase App '[DEFAULT]' has been created"
- Verifica que `Firebase.initializeApp()` se ejecute en `main.dart`
- Revisa que los archivos de configuración estén correctos

### Error: "MissingPluginException"
- Ejecuta `flutter clean`
- Ejecuta `flutter pub get`
- Reinicia completamente la app (cierra y abre de nuevo)

### iOS: "Push notifications not working"
- Verifica que las Capabilities estén habilitadas en Xcode
- Asegúrate de tener configurado APNs en Firebase Console
- Prueba en un dispositivo físico (no funciona en simulador)

### Android: "Notifications not showing"
- Verifica que la app tenga permisos de notificaciones
- Revisa que `minSdk = 21` en `build.gradle.kts`
- Asegúrate de que Google Play Services esté instalado

---

## 📚 Documentación adicional

- [Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging)
- [FlutterFire Messaging](https://firebase.flutter.dev/docs/messaging/overview)
- [APNs Configuration](https://firebase.google.com/docs/cloud-messaging/ios/client)

---

## ✅ Checklist final

- [ ] `google-services.json` en `android/app/`
- [ ] `GoogleService-Info.plist` en `ios/Runner/`
- [ ] Push Notifications capability habilitada en Xcode
- [ ] Background Modes capability habilitada en Xcode
- [ ] APNs Key/Certificate configurado en Firebase Console
- [ ] `flutter pub get` ejecutado
- [ ] Pods instalados (`cd ios && pod install`)
- [ ] App compilada sin errores
- [ ] Notificación de prueba recibida

---

**¡Listo! Una vez completados estos pasos, las notificaciones push estarán funcionando.** 🎉
