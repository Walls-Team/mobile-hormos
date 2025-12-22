#!/bin/bash

# Script para verificar la configuración de firma de código
# Ejecuta este script antes de compilar para asegurarte que todo está correcto

set -e

echo "🔍 Verificando configuración de firma de código..."
echo ""

IOS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$(dirname "$IOS_DIR")"

# Colores para output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

errors=0
warnings=0

# 1. Verificar que existe el workspace
echo "📋 1. Verificando archivos del proyecto..."
if [ -d "$IOS_DIR/Runner.xcworkspace" ]; then
    echo -e "${GREEN}✓${NC} Runner.xcworkspace existe"
else
    echo -e "${RED}✗${NC} Runner.xcworkspace NO encontrado"
    errors=$((errors+1))
fi

# 2. Verificar que el project.pbxproj tiene la configuración correcta
echo ""
echo "📋 2. Verificando project.pbxproj..."
if grep -q "APS_ENVIRONMENT" "$IOS_DIR/Runner.xcodeproj/project.pbxproj"; then
    echo -e "${GREEN}✓${NC} APS_ENVIRONMENT está configurado"
else
    echo -e "${RED}✗${NC} APS_ENVIRONMENT NO encontrado"
    errors=$((errors+1))
fi

if grep -q "CODE_SIGN_IDENTITY\[sdk=iphoneos\*\]" "$IOS_DIR/Runner.xcodeproj/project.pbxproj"; then
    echo -e "${GREEN}✓${NC} CODE_SIGN_IDENTITY[sdk=iphoneos*] está configurado"
else
    echo -e "${RED}✗${NC} CODE_SIGN_IDENTITY[sdk=iphoneos*] NO encontrado"
    errors=$((errors+1))
fi

# 3. Verificar entitlements
echo ""
echo "📋 3. Verificando Runner.entitlements..."
if [ -f "$IOS_DIR/Runner/Runner.entitlements" ]; then
    if grep -q '\$(APS_ENVIRONMENT)' "$IOS_DIR/Runner/Runner.entitlements"; then
        echo -e "${GREEN}✓${NC} APS_ENVIRONMENT dinámico configurado"
    else
        echo -e "${YELLOW}⚠${NC} APS_ENVIRONMENT no es dinámico"
        warnings=$((warnings+1))
    fi
else
    echo -e "${RED}✗${NC} Runner.entitlements NO encontrado"
    errors=$((errors+1))
fi

# 4. Verificar Pods
echo ""
echo "📋 4. Verificando Pods..."
if [ -d "$IOS_DIR/Pods" ]; then
    echo -e "${GREEN}✓${NC} Directorio Pods existe"
else
    echo -e "${YELLOW}⚠${NC} Directorio Pods NO existe. Ejecuta: pod install"
    warnings=$((warnings+1))
fi

if [ -f "$IOS_DIR/Podfile.lock" ]; then
    echo -e "${GREEN}✓${NC} Podfile.lock existe"
else
    echo -e "${YELLOW}⚠${NC} Podfile.lock NO existe. Ejecuta: pod install"
    warnings=$((warnings+1))
fi

# 5. Verificar certificados de firma
echo ""
echo "📋 5. Verificando certificados de firma..."
cert_count=$(security find-identity -v -p codesigning | grep -c "Apple Development" || echo "0")
if [ "$cert_count" -gt 0 ]; then
    echo -e "${GREEN}✓${NC} Certificados de desarrollo encontrados ($cert_count)"
else
    echo -e "${RED}✗${NC} NO se encontraron certificados de desarrollo"
    echo "   Abre Xcode → Preferences → Accounts → Download Manual Profiles"
    errors=$((errors+1))
fi

# 6. Verificar Team ID en el proyecto
echo ""
echo "📋 6. Verificando Team ID..."
if grep -q "DEVELOPMENT_TEAM = J44B4N22A6" "$IOS_DIR/Runner.xcodeproj/project.pbxproj"; then
    echo -e "${GREEN}✓${NC} DEVELOPMENT_TEAM configurado (J44B4N22A6)"
else
    echo -e "${RED}✗${NC} DEVELOPMENT_TEAM no encontrado o incorrecto"
    errors=$((errors+1))
fi

# 7. Verificar Bundle ID
echo ""
echo "📋 7. Verificando Bundle Identifier..."
if grep -q "PRODUCT_BUNDLE_IDENTIFIER = com.genius.hormos" "$IOS_DIR/Runner.xcodeproj/project.pbxproj"; then
    echo -e "${GREEN}✓${NC} Bundle ID correcto (com.genius.hormos)"
else
    echo -e "${YELLOW}⚠${NC} Bundle ID podría no ser correcto"
    warnings=$((warnings+1))
fi

# 8. Verificar que no existan archivos de build antiguos
echo ""
echo "📋 8. Verificando limpieza de archivos temporales..."
if [ ! -d "$IOS_DIR/build" ]; then
    echo -e "${GREEN}✓${NC} Directorio build no existe (limpio)"
else
    echo -e "${YELLOW}⚠${NC} Directorio build existe. Considera ejecutar: flutter clean"
    warnings=$((warnings+1))
fi

# Resumen
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $errors -eq 0 ] && [ $warnings -eq 0 ]; then
    echo -e "${GREEN}✅ VERIFICACIÓN EXITOSA${NC}"
    echo "   Todo está configurado correctamente."
    echo "   Puedes compilar tu app con: flutter run"
elif [ $errors -eq 0 ]; then
    echo -e "${YELLOW}⚠ VERIFICACIÓN CON ADVERTENCIAS${NC}"
    echo "   $warnings advertencia(s) encontrada(s)"
    echo "   La app debería compilar, pero revisa las advertencias"
else
    echo -e "${RED}❌ VERIFICACIÓN FALLIDA${NC}"
    echo "   $errors error(es) encontrado(s)"
    echo "   $warnings advertencia(s) encontrada(s)"
    echo ""
    echo "   Ejecuta el script de corrección:"
    echo "   ./fix_codesign.sh"
    exit 1
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
