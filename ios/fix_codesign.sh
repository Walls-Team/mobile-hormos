#!/bin/bash

# Script para solucionar problemas de firma de código en iOS
# Este script limpia todos los cachés y reconstruye el proyecto

set -e

echo "🔧 Iniciando limpieza profunda del proyecto iOS..."

# Directorio base
IOS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$(dirname "$IOS_DIR")"

echo "📂 Directorio del proyecto: $PROJECT_DIR"
echo "📂 Directorio iOS: $IOS_DIR"

# 1. Limpiar Flutter
echo ""
echo "🧹 Paso 1/6: Limpiando Flutter..."
cd "$PROJECT_DIR"
flutter clean

# 2. Limpiar Pods
echo ""
echo "🧹 Paso 2/6: Limpiando Pods..."
cd "$IOS_DIR"
rm -rf Pods
rm -rf Podfile.lock
rm -rf .symlinks/

# 3. Limpiar build y DerivedData
echo ""
echo "🧹 Paso 3/6: Limpiando build y DerivedData..."
rm -rf build/
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# 4. Limpiar cachés de código de firma
echo ""
echo "🧹 Paso 4/6: Limpiando cachés de firma..."
rm -rf ~/Library/MobileDevice/Provisioning\ Profiles/*

# 5. Reinstalar Pods
echo ""
echo "📦 Paso 5/6: Instalando Pods..."
cd "$PROJECT_DIR"
flutter pub get
cd "$IOS_DIR"
pod install --repo-update

# 6. Limpiar workspace de Xcode
echo ""
echo "🧹 Paso 6/6: Limpiando workspace de Xcode..."
xcodebuild clean -workspace Runner.xcworkspace -scheme Runner -configuration Debug 2>/dev/null || true
xcodebuild clean -workspace Runner.xcworkspace -scheme Runner -configuration Release 2>/dev/null || true

echo ""
echo "✅ Limpieza completada exitosamente!"
echo ""
echo "🚀 Ahora puedes compilar tu app con:"
echo "   flutter run"
echo ""
echo "O desde Xcode:"
echo "   open ios/Runner.xcworkspace"
echo ""
