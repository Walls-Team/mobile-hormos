#!/bin/bash
# Script para limpiar metadatos de macOS de los bundles antes de firmar
# Esto previene el error: "resource fork, Finder information, or similar detritus not allowed"

set -e

echo "🧹 Limpiando metadatos de macOS de los bundles..."

# Limpiar en build directory
if [ -d "${BUILD_DIR}" ]; then
    find "${BUILD_DIR}" -name "*.bundle" -exec xattr -cr {} \; 2>/dev/null || true
    echo "✓ Limpieza completada en ${BUILD_DIR}"
fi

# Limpiar en Pods
if [ -d "${PODS_ROOT}" ]; then
    find "${PODS_ROOT}" -name "*.bundle" -exec xattr -cr {} \; 2>/dev/null || true
    echo "✓ Limpieza completada en ${PODS_ROOT}"
fi

# Limpiar en DerivedData
if [ -d "${DERIVED_FILE_DIR}" ]; then
    DERIVED_DATA_DIR=$(dirname $(dirname "${DERIVED_FILE_DIR}"))
    find "${DERIVED_DATA_DIR}" -name "*.bundle" -exec xattr -cr {} \; 2>/dev/null || true
    echo "✓ Limpieza completada en DerivedData"
fi

echo "✅ Metadatos de macOS limpiados exitosamente"
