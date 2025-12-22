# Solución Definitiva para Problemas de Firma de Código en iOS

## 🎯 Problema Resuelto

Este documento detalla la solución implementada para el error recurrente:
```
Failed to build iOS app
Uncategorized (Xcode): Command CodeSign failed with a nonzero exit code
```

### 🔍 Causa Raíz Identificada

El error real era causado por **metadatos de macOS** (resource forks, Finder information) en archivos `.bundle` que impedían la firma de código con el mensaje:
```
resource fork, Finder information, or similar detritus not allowed
```

## ✅ Cambios Implementados

### 1. **Entitlements Dinámicos** (`Runner/Runner.entitlements`)
- **Antes**: `aps-environment` estaba fijo en "development"
- **Ahora**: Usa variable `$(APS_ENVIRONMENT)` que cambia según la configuración
  - Debug → `development`
  - Release/Profile → `production`
- **Beneficio**: Evita conflictos entre entitlements y perfiles de aprovisionamiento

### 2. **Configuración de Firma Consistente** (`project.pbxproj`)

Configuraciones añadidas en **Debug, Release y Profile**:

```
APS_ENVIRONMENT = development/production
CODE_SIGN_IDENTITY = "Apple Development"
CODE_SIGN_IDENTITY[sdk=iphoneos*] = "iPhone Developer"
PROVISIONING_PROFILE_SPECIFIER = ""
ONLY_ACTIVE_ARCH = YES (solo Debug)
```

**Beneficio**: Configuración uniforme que evita fallos intermitentes

### 3. **Post-Install de CocoaPods** (`Podfile`)

Configuraciones añadidas para todos los pods:
- Firma de código consistente
- Deshabilitación de script sandboxing
- Configuración correcta de ONLY_ACTIVE_ARCH
- **Limpieza automática de metadatos** de bundles después de `pod install`

**Beneficio**: Asegura que todas las dependencias tengan la misma configuración de firma

### 4. **Build Phase Script Automático** (`Clean Bundle Metadata`)

**LA SOLUCIÓN CLAVE**: Agregado un Build Phase script en Xcode que se ejecuta automáticamente antes de CodeSign:
- Se ejecuta después de copiar recursos de Pods
- Limpia metadatos de macOS de TODOS los archivos `.bundle`
- Usa `xattr -cr` para eliminar resource forks y Finder information
- Se ejecuta en cada build automáticamente

**Beneficio**: Elimina la causa raíz del error de forma permanente sin intervención manual

## 🚀 Cómo Usar la Solución

### Opción 1: Script Automático (Recomendado)

Ejecuta el script de limpieza cuando tengas problemas:

```bash
cd ios
./fix_codesign.sh
```

Este script:
1. ✅ Limpia Flutter (`flutter clean`)
2. ✅ Elimina Pods y reinstala
3. ✅ Limpia DerivedData de Xcode
4. ✅ Limpia cachés de perfiles de aprovisionamiento
5. ✅ Reinstala todas las dependencias

### Opción 2: Comandos Manuales

Si prefieres hacerlo manualmente:

```bash
# Desde la raíz del proyecto
flutter clean
cd ios
rm -rf Pods Podfile.lock .symlinks/ build/
rm -rf ~/Library/Developer/Xcode/DerivedData/*
cd ..
flutter pub get
cd ios
pod install --repo-update
```

## 🛡️ Prevención a Largo Plazo

### ✅ Mejores Prácticas

1. **Siempre usa el workspace, no el proyecto**
   ```bash
   # ❌ No abras esto
   open ios/Runner.xcodeproj
   
   # ✅ Abre esto
   open ios/Runner.xcworkspace
   ```

2. **Limpia el proyecto después de cambios importantes**
   - Después de actualizar dependencias
   - Después de cambiar versión de Flutter/Xcode
   - Después de cambiar certificados o perfiles

3. **Verifica tu configuración en Xcode**
   - Ve a: Runner → Signing & Capabilities
   - Asegúrate que "Automatically manage signing" esté activado
   - Verifica que tu Team esté seleccionado (J44B4N22A6)

4. **Mantén Xcode y CocoaPods actualizados**
   ```bash
   # Actualizar CocoaPods
   sudo gem install cocoapods
   
   # Actualizar repositorio de pods
   pod repo update
   ```

### 🔍 Diagnóstico de Problemas

Si aún tienes errores después de aplicar la solución:

1. **Verifica tu Team ID en Xcode**
   - Abre Xcode → Preferences → Accounts
   - Asegúrate que tu cuenta de Apple Developer está agregada
   - El Team ID debe ser: **J44B4N22A6**

2. **Verifica los perfiles de aprovisionamiento**
   ```bash
   # Lista los perfiles instalados
   security find-identity -v -p codesigning
   ```

3. **Limpia el Keychain (si es necesario)**
   - Abre Keychain Access
   - Ve a "login" keychain
   - Busca certificados duplicados de "Apple Development"
   - Elimina los duplicados o expirados

4. **Revisa los logs detallados**
   ```bash
   # Compila con logs verbosos
   flutter run -v
   ```

## 📱 Compilación

### Para Simulador (Debug)
```bash
flutter run
# o
flutter run --debug
```

### Para Dispositivo Real (Debug)
```bash
flutter run -d <device-id>
```

### Para Release
```bash
flutter build ios --release
```

## 🆘 Solución de Problemas Comunes

### Error: "Signing for Runner requires a development team"
**Solución**: Abre `ios/Runner.xcworkspace` en Xcode y selecciona tu team en Signing & Capabilities.

### Error: "Provisioning profile doesn't include signing certificate"
**Solución**: 
1. Ejecuta `./fix_codesign.sh`
2. Abre Xcode
3. Ve a Preferences → Accounts → Download Manual Profiles

### Error: "The operation couldn't be completed"
**Solución**: Reinicia Xcode y ejecuta `./fix_codesign.sh`

### Error persistente después de todos los pasos
**Solución**: 
1. Cierra Xcode completamente
2. Ejecuta:
   ```bash
   killall Xcode
   rm -rf ~/Library/Developer/Xcode/DerivedData/*
   ./fix_codesign.sh
   ```
3. Abre Xcode y compila de nuevo

## 📋 Checklist de Verificación

Antes de compilar, asegúrate que:

- [ ] El Team ID está configurado (J44B4N22A6)
- [ ] "Automatically manage signing" está activado
- [ ] Bundle Identifier es `com.genius.hormos`
- [ ] Estás abriendo `.xcworkspace` y no `.xcodeproj`
- [ ] No hay errores en Pods (sin warnings rojos)
- [ ] DerivedData está limpio después de cambios importantes

## 🎓 Documentación Adicional

- [Code Signing Guide - Apple](https://developer.apple.com/support/code-signing/)
- [Flutter iOS Deployment](https://docs.flutter.dev/deployment/ios)
- [CocoaPods Troubleshooting](https://guides.cocoapods.org/using/troubleshooting)

---

**Última actualización**: Diciembre 2024
**Versión de la solución**: 1.0
**Mantenedor**: Equipo de Desarrollo
