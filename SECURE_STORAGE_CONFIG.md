# Configuración de Almacenamiento Seguro - iOS y Android

## 📱 iOS Configuration (Keychain)

### Archivo: `ios/Runner/Info.plist`

El almacenamiento seguro en iOS usa **Keychain** automáticamente. No requiere configuración adicional.

**Verificar que exista:**
```xml
<key>NSFaceIDUsageDescription</key>
<string>Usamos Face ID para autenticar tu sesión de forma segura</string>
```

### Permisos Requeridos:
- ✅ Keychain sharing (automático con flutter_secure_storage)
- ✅ Secure Enclave (automático en dispositivos compatibles)

---

## 🤖 Android Configuration (Keystore)

### Archivo: `android/app/build.gradle`

Asegurar que esté configurado para usar EncryptedSharedPreferences:

```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        applicationId "com.geniushormo.app"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 2
        versionName "1.0.0"
    }
    
    buildTypes {
        release {
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}

dependencies {
    // flutter_secure_storage usa esto automáticamente
    implementation 'androidx.security:security-crypto:1.1.0-alpha06'
}
```

### Archivo: `android/app/src/main/AndroidManifest.xml`

Asegurar que tenga los permisos necesarios:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Permisos requeridos para almacenamiento seguro -->
    <uses-permission android:name="android.permission.USE_CREDENTIALS" />
    <uses-permission android:name="android.permission.GET_ACCOUNTS" />
    
    <application
        android:label="@string/app_name"
        android:icon="@mipmap/ic_launcher"
        android:usesCleartextTraffic="false">
        <!-- ... resto de la configuración ... -->
    </application>
</manifest>
```

### Archivo: `android/app/proguard-rules.pro`

Agregar reglas para proteger las clases de almacenamiento:

```proguard
# Flutter Secure Storage
-keep class androidx.security.crypto.** { *; }
-keep class android.security.keystore.** { *; }

# Mantener métodos de serialización
-keepclassmembers class * {
    *** readObject(java.io.ObjectInputStream);
    *** writeObject(java.io.ObjectOutputStream);
}
```

---

## 🔐 Flujo de Almacenamiento Seguro

### En iOS:
1. Token se guarda en **Keychain** (encriptado por el SO)
2. Solo la app puede acceder (protegido por App ID)
3. Persiste incluso después de desinstalar/reinstalar (opcional)

### En Android:
1. Token se guarda en **EncryptedSharedPreferences** (API 21+)
2. Usa **Android Keystore** para encriptación
3. Clave maestra generada automáticamente por el SO
4. Persiste incluso después de desinstalar/reinstalar

---

## ✅ Verificación de Configuración

### Comando para verificar iOS:
```bash
cd ios
pod install
cd ..
```

### Comando para verificar Android:
```bash
flutter pub get
flutter clean
flutter pub get
```

### Compilar y probar:
```bash
# iOS
flutter run -d ios

# Android
flutter run -d android
```

---

## 🧪 Testing de Persistencia

### Prueba Manual:
1. **Login** → Token se guarda
2. **Cerrar app completamente**
3. **Reabrir app** → Debe ir directo al dashboard (sin login)
4. **Logout** → Token se elimina
5. **Cerrar app**
6. **Reabrir app** → Debe mostrar login

### Verificar en Código:
```dart
// En main.dart, después de initializeAuthState()
final authStateProvider = GetIt.instance<AuthStateProvider>();
debugPrint('🔐 Estado autenticado: ${authStateProvider.isAuthenticated}');
debugPrint('🔐 Token guardado: ${await userStorageService.getJWTToken()}');
```

---

## 🚀 Despliegue en Producción

### iOS:
- ✅ Usar Keychain (automático)
- ✅ Habilitar Data Protection (automático en iOS 13+)
- ✅ No guardar tokens en UserDefaults (usar Keychain)

### Android:
- ✅ Usar EncryptedSharedPreferences (automático)
- ✅ Habilitar ProGuard/R8 (minifyEnabled = true)
- ✅ Usar Android Keystore (automático)
- ✅ minSdkVersion ≥ 21

---

## 📝 Notas Importantes

1. **flutter_secure_storage** maneja todo automáticamente
2. No necesitas código adicional para encriptación
3. Los tokens se eliminan automáticamente con `clearAllStorage()`
4. La persistencia funciona incluso después de reiniciar el dispositivo
5. En desarrollo, los datos se pueden limpiar con `flutter clean`

---

## 🔗 Referencias

- [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage)
- [iOS Keychain](https://developer.apple.com/documentation/security/keychain_services)
- [Android Keystore](https://developer.android.com/training/articles/keystore)
- [EncryptedSharedPreferences](https://developer.android.com/reference/androidx/security/crypto/EncryptedSharedPreferences)
