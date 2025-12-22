#!/bin/bash
# Script para ejecutar desde cero limpiando todo

set -e

echo "🧹 Matando procesos..."
pkill -9 -f "Runner.app" 2>/dev/null || true
pkill -9 -f "flutter" 2>/dev/null || true

echo "🧹 Limpiando builds..."
rm -rf build/
rm -rf ios/build/
rm -rf .dart_tool/
rm -rf ~/Library/Developer/Xcode/DerivedData/*

echo "🧹 Flutter clean..."
flutter clean

echo "📦 Flutter pub get..."
flutter pub get

echo "📦 Pod install..."
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..

echo ""
echo "✅ Limpieza completa!"
echo ""
echo "🚀 Ahora ejecuta desde Xcode:"
echo "   1. Abre: ios/Runner.xcworkspace"
echo "   2. STOP cualquier build"
echo "   3. Product → Clean Build Folder (Shift + Cmd + K)"
echo "   4. RUN (Cmd + R)"
