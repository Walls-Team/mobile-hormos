#!/bin/bash

# 🚀 Script de Build para App Store - Genius Hormo
# Este script limpia los atributos problemáticos ANTES del build

set -e  # Exit on error

echo "🧹 Limpiando proyecto..."
flutter clean

echo "📦 Obteniendo dependencias..."
flutter pub get

echo "🔧 Instalando pods..."
cd ios
pod install
cd ..

echo "🧹 Limpiando atributos extendidos..."
# Limpiar DerivedData
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# Limpiar atributos de archivos que pueden causar problemas
find . -name ".DS_Store" -delete 2>/dev/null || true
xattr -cr ios/ 2>/dev/null || true
xattr -cr macos/ 2>/dev/null || true

echo "📱 Construyendo IPA para App Store..."
flutter build ipa --release

echo ""
echo "✅ Build completado exitosamente!"
echo ""
echo "📍 Ubicación del IPA:"
echo "   build/ios/ipa/genius_hormo.ipa"
echo ""
echo "📦 Para subir a App Store:"
echo "   1. Abre Transporter"
echo "   2. Arrastra el archivo IPA"
echo "   3. Espera la subida"
echo ""
