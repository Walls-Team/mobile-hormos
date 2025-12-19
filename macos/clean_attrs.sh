#!/bin/bash
# Clean extended attributes that cause codesigning issues
find "${BUILT_PRODUCTS_DIR}" -type f -exec xattr -c {} \; 2>/dev/null || true
