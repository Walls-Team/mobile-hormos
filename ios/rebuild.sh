#!/bin/bash
# Script de reconstrucción completa para resolver problemas de CodeSign

set -e

echo "🔧 Reconstrucción completa del proyecto iOS..."

# Directorio base
IOS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$(dirname "$IOS_DIR")"

cd "$PROJECT_DIR"

# Limpiar todo
echo "🧹 Limpiando proyecto..."
flutter clean
rm -rf ios/Pods ios/Podfile.lock ios/.symlinks ios/build
rm -rf ~/.local/share/flutter/ios-deploy ~/.pub-cache/hosted/pub.dev/*/ios/Pods 2>/dev/null || true
rm -rf ~/Library/Developer/Xcode/DerivedData/Runner-* 2>/dev/null || true

# Reinstalar dependencias
echo "📦 Reinstalando dependencias..."
flutter pub get

# Reinstalar Pods
echo "📦 Reinstalando Pods..."
cd ios
pod deintegrate 2>/dev/null || true
pod install --repo-update

# Limpiar metadatos
echo "🧹 Limpiando metadatos de bundles..."
find Pods -name "*.bundle" -exec xattr -cr {} \; 2>/dev/null || true

cd "$PROJECT_DIR"

echo ""
echo "✅ Reconstrucción completada!"
echo ""
echo "🚀 Ejecuta: flutter run"
