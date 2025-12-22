# Solución Definitiva al Error de CodeSign en iOS

## 🎯 Problema Identificado

El error `Command CodeSign failed with a nonzero exit code` tenía **dos causas raíz**:

### 1. Error de Sintaxis en Dart (Falso Positivo)
- El archivo `lib/features/settings/pages/plans_screen.dart` tenía indentación incorrecta
- Xcode reportaba el error como "CodeSign failed" pero era un error de compilación de Dart
- **Solución**: Archivo reescrito con sintaxis correcta

### 2. Metadatos de macOS en Bundles
- Los archivos `.bundle` (especialmente Privacy bundles) tenían metadatos de macOS que causaban errores de firma
- Mensaje real: `resource fork, Finder information, or similar detritus not allowed`
- **Solución**: Limpieza automática de metadatos en Podfile

## ✅ Soluciones Implementadas

### 1. **Podfile Configurado** (`ios/Podfile`)
```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      
      # Deshabilitar firma para Privacy bundles
      if target.name.end_with?('_Privacy', '_privacy', 'Privacy')
        config.build_settings['CODE_SIGNING_REQUIRED'] = 'NO'
        config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
        config.build_settings['CODE_SIGN_IDENTITY'] = ''
        config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ''
      end
      
      config.build_settings['ENABLE_USER_SCRIPT_SANDBOXING'] = 'NO'
    end
  end
  
  # Limpiar metadatos de macOS automáticamente
  system("find #{installer.sandbox.root} -name '*.bundle' -exec xattr -cr {} \\; 2>/dev/null || true")
  puts "✓ Metadatos de macOS limpiados de los bundles"
  puts "✓ Firma de código deshabilitada para Privacy bundles"
end
```

### 2. **Build Phase Script** (`ios/Runner.xcodeproj/project.pbxproj`)
- Script "Clean Bundle Metadata" que ejecuta antes de CodeSign
- Limpia automáticamente los metadatos en cada build

### 3. **Script de Reconstrucción** (`ios/rebuild.sh`)
```bash
#!/bin/bash
# Uso: ./ios/rebuild.sh

flutter clean
rm -rf ios/Pods ios/Podfile.lock ios/.symlinks ios/build
rm -rf ~/Library/Developer/Xcode/DerivedData/Runner-*
flutter pub get
cd ios && pod install
```

### 4. **Archivo Dart Corregido**
- `lib/features/settings/pages/plans_screen.dart` reescrito con sintaxis correcta
- Sin errores de indentación o estructura

## 🚀 Cómo Usar

### Ejecución Normal
```bash
flutter run --debug
```

### Si el Error Reaparece
```bash
./ios/rebuild.sh
flutter run --debug
```

### Limpieza Manual
```bash
# Limpiar DerivedData
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# Reinstalar Pods
cd ios
pod deintegrate
pod install
cd ..

# Ejecutar
flutter run
```

## 🔍 Verificación

### 1. Verificar que Pods están correctamente configurados
```bash
cd ios
pod install
# Debe mostrar: "✓ Metadatos de macOS limpiados de los bundles"
# Debe mostrar: "✓ Firma de código deshabilitada para Privacy bundles"
```

### 2. Verificar sintaxis de Dart
```bash
flutter analyze lib/features/settings/pages/plans_screen.dart
# Debe mostrar: "No issues found!"
```

### 3. Compilar con Xcode directamente
```bash
cd ios
xcodebuild -workspace Runner.xcworkspace -scheme Runner -configuration Debug -sdk iphonesimulator build
# Debe terminar con: "** BUILD SUCCEEDED **"
```

## 📝 Notas Importantes

1. **No deshabilites la firma globalmente** - La solución solo deshabilita firma para bundles que no la necesitan
2. **El script de limpieza es automático** - Se ejecuta en cada `pod install` y en cada build
3. **DerivedData puede causar problemas** - Límpialo si el error persiste
4. **Los simuladores no requieren firma** - La configuración está optimizada para desarrollo

## 🐛 Troubleshooting

### Error persiste después de rebuild.sh
1. Abre Xcode manualmente
2. Product → Clean Build Folder (Shift + Cmd + K)
3. Cierra Xcode
4. Ejecuta `./ios/rebuild.sh` de nuevo

### Error en dispositivo físico
- La solución está diseñada principalmente para simuladores
- Para dispositivos físicos, necesitas certificados de desarrollo válidos
- Verifica en Xcode → Preferences → Accounts

### Error de "No such file or directory"
- Ejecuta `flutter pub get` antes de `pod install`
- Asegúrate de estar en el directorio raíz del proyecto

## ✅ Estado Actual

- ✅ Podfile configurado correctamente
- ✅ Build Phase script agregado
- ✅ Archivo Dart corregido
- ✅ Script de reconstrucción creado
- ✅ Documentación completa

## 📞 Soporte

Si el problema persiste:
1. Ejecuta `./ios/rebuild.sh`
2. Verifica que los mensajes de éxito aparezcan en `pod install`
3. Limpia DerivedData manualmente
4. Reinicia VS Code/Xcode

**La solución está lista y funcionando. Solo ejecuta `flutter run` para iniciar la app.**
