# 🚀 Guía Completa: Configuración de Firebase + Notificaciones Push

## 📋 CHECKLIST RÁPIDO

- [ ] **PASO 1:** Configurar firma de código en Xcode
- [ ] **PASO 2:** Descargar `google-services.json` (Android)
- [ ] **PASO 3:** Verificar `GoogleService-Info.plist` (iOS)
- [ ] **PASO 4:** Agregar Capabilities en Xcode
- [ ] **PASO 5:** Configurar APNs Key en Firebase
- [ ] **PASO 6:** Compilar y probar

---

## 🔧 PASO 1: Solucionar Error de CodeSign en Xcode

### **¿Por qué este error?**
El error `CodeSign failed` significa que Xcode no puede firmar tu app. Esto es necesario para ejecutar en simulador o dispositivo.

### **Solución:**

1. **Abrir el proyecto en Xcode:**
   ```bash
   open ios/Runner.xcworkspace
   ```
   
   ⚠️ **MUY IMPORTANTE:** Abre `Runner.xcworkspace` NO `Runner.xcodeproj`

2. **En Xcode:**
   - Panel izquierdo → Click en **"Runner"** (proyecto azul)
   - Selecciona el target **"Runner"**
   - Ve a la pestaña **"Signing & Capabilities"**

3. **Configurar el Team:**
   - En **"Team"**, selecciona tu Apple ID o Developer Account
   - Si no aparece, click en **"Add Account..."** e inicia sesión
   - Asegúrate de que **"Automatically manage signing"** esté ✅ ACTIVADO

4. **Si aparece un error de Bundle ID:**
   - Click en **"Try Again"** o **"Fix Issue"**
   - Xcode creará automáticamente el perfil de provisioning

5. **Verificar:**
   - Deberías ver **sin errores** en la sección de Signing
   - Bundle Identifier: `com.wallsdev.genius_hormo`
   - Team: Tu nombre o Apple ID
   - Provisioning Profile: (Automatic)

---

## 🔥 PASO 2: Descargar Archivos de Configuración de Firebase

### **2.1 Para Android: `google-services.json`**

1. Ve a [Firebase Console](https://console.firebase.google.com)
2. Selecciona tu proyecto
3. Click en ⚙️ → **"Configuración del proyecto"**
4. Scroll hasta **"Tus apps"**

5. **Si tu app Android ya existe:**
   - Busca el ícono de Android con nombre: `com.wallsdev.genius_hormo`
   - Click en ella
   - Scroll hasta **"Tus apps de Firebase"**
   - Click en **"google-services.json"** (botón de descarga)

6. **Si NO existe, créala:**
   - Click en **"+ Agregar app"** → Selecciona **Android**
   - **Nombre del paquete Android:** `com.wallsdev.genius_hormo`
   - **Sobrenombre de la app:** `Genius Hormo Android` (opcional)
   - Click en **"Registrar app"**
   - **Descarga `google-services.json`**
   - Click en **"Siguiente"** hasta finalizar

7. **Colocar el archivo:**
   ```
   📁 mobile-hormos/
   └── 📁 android/
       └── 📁 app/
           └── 📄 google-services.json  ← AQUÍ
   ```
   
   **Ruta completa:** `/Users/luisparedes/Desktop/mobile-hormos/android/app/google-services.json`

### **2.2 Para iOS: `GoogleService-Info.plist`**

1. En Firebase Console, misma pantalla de **"Tus apps"**

2. **Si tu app iOS ya existe:**
   - Busca el ícono de iOS con Bundle ID: `com.wallsdev.genius_hormo`
   - Verifica que el archivo ya esté en: `/ios/Runner/GoogleService-Info.plist`
   - ✅ Si ya existe, **no necesitas hacer nada**

3. **Si NO existe, créala:**
   - Click en **"+ Agregar app"** → Selecciona **iOS**
   - **ID del paquete de iOS:** `com.wallsdev.genius_hormo`
   - **Sobrenombre de la app:** `Genius Hormo iOS` (opcional)
   - **ID de App Store:** (dejar vacío por ahora)
   - Click en **"Registrar app"**
   - **Descarga `GoogleService-Info.plist`**
   - Click en **"Siguiente"** hasta finalizar

4. **Colocar el archivo (si no existe):**
   ```
   📁 mobile-hormos/
   └── 📁 ios/
       └── 📁 Runner/
           └── 📄 GoogleService-Info.plist  ← AQUÍ
   ```

---

## 📱 PASO 3: Configurar Capabilities en Xcode

Todavía en Xcode (con `Runner.xcworkspace` abierto):

### **3.1 Agregar "Push Notifications"**

1. Asegúrate de estar en la pestaña **"Signing & Capabilities"**
2. Click en el botón **"+ Capability"** (esquina superior izquierda)
3. En el buscador, escribe: **"Push Notifications"**
4. Haz doble click en **"Push Notifications"**
5. Deberías ver una nueva tarjeta con el título **"Push Notifications"** ✅

### **3.2 Agregar "Background Modes"**

1. Click nuevamente en **"+ Capability"**
2. Busca: **"Background Modes"**
3. Haz doble click en **"Background Modes"**
4. Verás una tarjeta con varias opciones
5. **Marca las siguientes casillas:**
   - ✅ **Remote notifications** ← OBLIGATORIO
   - ✅ **Background fetch** ← Opcional pero recomendado

### **3.3 Verificar el resultado**

Tu pestaña **"Signing & Capabilities"** debería verse así:

```
┌─────────────────────────────────────┐
│ Signing & Capabilities              │
├─────────────────────────────────────┤
│                                     │
│ ✅ Signing (Debug)                  │
│    Team: Tu nombre                  │
│    Bundle ID: com.wallsdev...       │
│                                     │
│ ✅ Push Notifications               │
│                                     │
│ ✅ Background Modes                 │
│    ✓ Remote notifications           │
│    ✓ Background fetch               │
└─────────────────────────────────────┘
```

6. **Cierra Xcode** (guarda los cambios al cerrar)

---

## 🔑 PASO 4: Configurar APNs en Firebase Console

Para que las notificaciones push funcionen en iOS, Firebase necesita comunicarse con los servidores de Apple (APNs). Hay dos formas:

### **Opción A: APNs Authentication Key (⭐ RECOMENDADO)**

#### **4.1 Crear la Key en Apple Developer**

1. Ve a [Apple Developer Portal - Keys](https://developer.apple.com/account/resources/authkeys/list)
2. **Inicia sesión** con tu Apple ID (el mismo que usas en Xcode)
3. En el menú izquierdo, click en **"Keys"**
4. Click en el botón **"+"** (Create a key)

5. **Configurar la key:**
   - **Key Name:** `Firebase Push Notifications`
   - **Key Services:** Marca la casilla ✅ **"Apple Push Notifications service (APNs)"**
   - Click en **"Continue"**

6. **Registrar y descargar:**
   - Click en **"Register"**
   - Click en **"Download"**
   - **IMPORTANTE:** Guarda el archivo `.p8` en un lugar seguro
   - **SOLO puedes descargarlo UNA VEZ**

7. **Anotar información importante:**
   Verás una pantalla con:
   - **Key ID:** (ejemplo: `ABC123DEFG`) ← Anótalo
   - **Download Your Key:** (archivo .p8)
   
   También necesitas tu **Team ID:**
   - Está en la esquina superior derecha del portal
   - O en **"Membership"** en el menú izquierdo
   - (ejemplo: `J44B4N22A6`) ← Anótalo

#### **4.2 Subir la Key a Firebase**

1. Ve a [Firebase Console](https://console.firebase.google.com)
2. Selecciona tu proyecto
3. ⚙️ → **"Configuración del proyecto"**
4. Pestaña **"Cloud Messaging"**
5. Scroll hasta la sección **"Apple app configuration"**

6. **Subir la key:**
   - En "APNs Authentication Key", click en **"Upload"**
   - Selecciona el archivo `.p8` que descargaste
   - **APNs authentication key:** (examinar archivo .p8)
   - **Key ID:** (el que anotaste, ej: ABC123DEFG)
   - **Team ID:** (el que anotaste, ej: J44B4N22A6)
   - Click en **"Upload"**

7. **Verificar:**
   - Deberías ver: ✅ "APNs Authentication Key uploaded successfully"

---

### **Opción B: APNs Certificate (Alternativa)**

Si prefieres usar certificado en lugar de key:

1. Genera un certificado APNs desde Xcode o Keychain
2. Exporta como archivo `.p12`
3. En Firebase Console → Cloud Messaging → Apple app configuration
4. Sube el archivo `.p12` en "APNs Certificates"
5. Ingresa la contraseña del certificado

---

## ✅ PASO 5: Compilar y Ejecutar

Una vez completados TODOS los pasos anteriores:

### **5.1 Limpiar el proyecto**

```bash
cd /Users/luisparedes/Desktop/mobile-hormos
flutter clean
flutter pub get
```

### **5.2 Reinstalar pods de iOS**

```bash
cd ios
pod deintegrate
pod install
cd ..
```

### **5.3 Compilar**

```bash
flutter run
```

---

## 🧪 PASO 6: Probar las Notificaciones

### **6.1 Verificar los logs**

Cuando la app se inicie, busca en la consola:

```
🔥 Inicializando Firebase...
✅ Firebase inicializado
🔔 Inicializando Firebase Messaging...
📱 Permiso de notificaciones: authorized
🎫 FCM Token: eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...
✅ Firebase Messaging inicializado correctamente
📬 Inicializando servicio de notificaciones locales...
✅ Notificaciones cargadas: 0
📧 No leídas: 0
✅ Servicio de notificaciones locales inicializado
✅ Suscrito al topic: all_users
✅ Suscrito al topic: complete_profiles
✅ Sistema de notificaciones configurado correctamente
```

### **6.2 Copiar el FCM Token**

Del log de arriba, copia el **FCM Token** (la cadena larga después de `🎫 FCM Token:`)

### **6.3 Enviar notificación de prueba**

1. Ve a [Firebase Console](https://console.firebase.google.com)
2. En el menú izquierdo, click en **"Cloud Messaging"**
3. Click en **"Enviar tu primera notificación"** o **"Nueva campaña"**

4. **Completar el formulario:**
   - **Título:** "Prueba"
   - **Texto:** "Esta es una notificación de prueba"
   - Click en **"Enviar mensaje de prueba"**

5. **Pegar el FCM Token:**
   - Pega el token que copiaste
   - Click en el botón **"+"** (agregar)
   - Click en **"Probar"**

### **6.4 Verificar que funciona:**

- ✅ Si la app está abierta (foreground):
  - Verás el badge 🔔 **(1)** en la campana del header
  - Toca la campana → Deberías ver la notificación en la lista

- ✅ Si la app está en background:
  - Recibirás una notificación push en el dispositivo
  - Al abrir la app, la notificación también aparecerá en la lista

---

## 🎯 Resumen Visual del Flujo

```
📱 Usuario abre la app
    ↓
🔥 Firebase se inicializa
    ↓
🔔 Firebase Messaging solicita permisos
    ↓
✅ Usuario acepta
    ↓
🎫 Se genera un FCM Token único
    ↓
☁️ Token se envía a Firebase servers
    ↓
📨 Firebase Console puede enviar notificaciones
    ↓
📲 Usuario recibe notificación push
    ↓
💾 Se guarda localmente en la app
    ↓
🔔 Aparece el badge en la campana
    ↓
👆 Usuario toca la campana
    ↓
📋 Ve lista de notificaciones
```

---

## ⚠️ Solución de Problemas Comunes

### **Error: "CodeSign failed"**
- ✅ Verifica que hayas seleccionado un Team en Xcode
- ✅ Asegúrate de que "Automatically manage signing" esté activado
- ✅ Cierra y vuelve a abrir Xcode

### **Error: "google-services.json not found"**
- ✅ Verifica que esté en `android/app/google-services.json`
- ✅ NO en `android/google-services.json`
- ✅ Ejecuta `flutter clean` y `flutter pub get`

### **Error: "No Firebase App '[DEFAULT]' has been created"**
- ✅ Verifica que `Firebase.initializeApp()` esté en `main.dart`
- ✅ Revisa que los archivos de configuración sean correctos
- ✅ Ejecuta `flutter clean`

### **iOS: Push notifications not working**
- ✅ Verifica que las Capabilities estén habilitadas en Xcode
- ✅ Asegúrate de tener APNs Key configurado en Firebase Console
- ✅ **Prueba en un dispositivo físico** (no funciona en simulador)
- ✅ Verifica que los permisos de notificaciones estén aceptados

### **Android: Notifications not showing**
- ✅ Verifica que la app tenga permisos de notificaciones
- ✅ Revisa que `minSdk = 21` en `build.gradle.kts`
- ✅ Asegúrate de que Google Play Services esté instalado

---

## 📚 Archivos Importantes

### **Archivos que DEBES tener:**

```
mobile-hormos/
├── android/
│   └── app/
│       └── google-services.json          ← OBLIGATORIO
├── ios/
│   └── Runner/
│       ├── GoogleService-Info.plist      ← OBLIGATORIO
│       ├── Runner.entitlements           ← Auto-generado por Xcode
│       └── Info.plist                    ← Ya modificado
└── lib/
    ├── main.dart                         ← Ya modificado (Firebase init)
    └── services/
        ├── firebase_messaging_service.dart      ← Ya creado
        └── local_notifications_service.dart     ← Ya creado
```

---

## ✅ Checklist Final

Antes de ejecutar `flutter run`, asegúrate de que:

- [ ] Archivo `google-services.json` está en `android/app/`
- [ ] Archivo `GoogleService-Info.plist` está en `ios/Runner/`
- [ ] Team configurado en Xcode (Signing & Capabilities)
- [ ] Push Notifications capability agregada en Xcode
- [ ] Background Modes capability agregada en Xcode
- [ ] APNs Key subida a Firebase Console
- [ ] `flutter pub get` ejecutado
- [ ] `pod install` ejecutado (iOS)
- [ ] Xcode cerrado (para guardar cambios)

---

## 🎉 ¡Listo!

Si completaste todos los pasos, ejecuta:

```bash
flutter run
```

Y deberías ver la app funcionando con notificaciones push completamente configuradas.

---

## 📞 Próximos Pasos (Opcional)

Una vez que todo funcione:

1. **Enviar el token al backend** (para notificaciones personalizadas)
2. **Implementar navegación** según tipo de notificación
3. **Agregar notificaciones programadas localmente**
4. **Personalizar el diseño** de las notificaciones

---

**¿Necesitas ayuda con algún paso específico? ¡Avísame!** 🚀
