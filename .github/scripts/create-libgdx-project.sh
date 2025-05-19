#!/bin/bash
set -e

if [ ! -d "core" ]; then
  git clone --depth=1 https://github.com/libgdx/libgdx-gradle-template libgdx-project
  mv libgdx-project/* .
  mv libgdx-project/.* . 2>/dev/null || true
  rm -rf libgdx-project

  # Substituir wrapper para usar versão 8.5
  mkdir -p gradle/wrapper
  echo 'distributionUrl=https\://services.gradle.org/distributions/gradle-8.5-bin.zip' > gradle/wrapper/gradle-wrapper.properties
fi