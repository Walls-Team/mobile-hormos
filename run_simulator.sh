#!/bin/bash
# Script para ejecutar en simulador sin problemas de firma

set -e

echo "🚀 Ejecutando en simulador..."

# Forzar uso de simulador y configuración debug
flutter run \
  --debug \
  --flavor development \
  --dart-define=FLUTTER_WEB_AUTO_DETECT=true 2>&1 || flutter run --debug
