#!/bin/bash
set -e

# Clona um template LibGDX pré-configurado com Android + Desktop
if [ ! -d "core" ]; then
  git clone --depth=1 https://github.com/libgdx/libgdx-gradle-template libgdx-project
  mv libgdx-project/* .
  mv libgdx-project/.* . 2>/dev/null || true
  rm -rf libgdx-project
fi