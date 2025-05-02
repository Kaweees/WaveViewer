#!/bin/bash

# Format script called by the CI
# Usage:
#    format.sh format

#
#  Private Impl
#

# Ensure emscripten is available
if ! command -v emcmake &> /dev/null; then
    echo "emcmake not found. Please install and activate Emscripten"
    exit 1
fi

# Build
make -j$(nproc)

# Copy web files
mv ./*.wasm ./public/
mv ./*.js ./public/
mv ./*.data ./public/

cd ..
ls -la
