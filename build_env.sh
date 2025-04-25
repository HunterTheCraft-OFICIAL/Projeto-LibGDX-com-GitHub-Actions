#!/bin/bash

# --- Configurações ---
PROJECT_NAME="meu-jogo-libgdx"
OUTPUT_ZIP="${PROJECT_NAME}.zip"
LOG_FILE="build.log"

# --- Funções ---

log() {
  TIMESTAMP=$(date +%Y-%m-%d_%H:%M:%S)
  echo "[${TIMESTAMP}] $1"
}

collect_environment_info() {
  log "--- Informações do Ambiente ---"
  log "Sistema Operacional: $(uname -a)"
  log "Java Version: $(java -version 2>&1)"
  log "Gradle Version: $(./gradlew --version 2>&1)" # Tenta obter a versão do Gradle (se existir)
  log "Estrutura de diretórios:"
  tree -L 2 . # Lista a estrutura de diretórios (requer 'tree' instalado)
  log "--- Downloads ---"
  ls -l gdx-setup.jar # Lista informações do arquivo baixado
  log "-----------------------------"
}

create_libgdx_project() {
  log "Iniciando a criação do projeto LibGDX..."
  if ! command -v java &> /dev/null; then
    log "Erro: Java não encontrado no sistema. A criação do projeto LibGDX requer Java."
    return 1
  fi

  java -jar gdx-setup.jar -name "$PROJECT_NAME" -package com.meugame -mainClass MeuJogo

  if [ $? -eq 0 ]; then
    log "Projeto LibGDX criado com sucesso na pasta '$PROJECT_NAME'."
    return 0
  else
    log "Erro ao criar o projeto LibGDX."
    return 1
  fi
}

zip_project() {
  log "Compactando o projeto para '$OUTPUT_ZIP'..."
  zip -r "$OUTPUT_ZIP" "$PROJECT_NAME"
  if [ $? -eq 0 ]; then
    log "Projeto compactado com sucesso."
    return 0
  else
    log "Erro ao compactar o projeto."
    return 1
  fi
}

build_apk() {
  log "Tentando compilar o APK..."
  cd "$PROJECT_NAME/android" || {
    log "Erro: Não foi possível acessar a pasta 'android'."
    return 1
  }

  ./gradlew assembleDebug

  if [ $? -eq 0 ]; then
    APK_PATH="build/outputs/apk/debug/android-debug.apk"
    if [ -f "$APK_PATH" ]; then
      log "APK compilado com sucesso em '$APK_PATH'."
      APK_OUTPUT="meu-jogo-debug.apk" # Salva o APK sem ZIP por enquanto
      cp "$APK_PATH" "../../../$APK_OUTPUT" # Copia para o diretório raiz
      cd ../../..
      return 0
    else
      log "A compilação do APK parece ter ocorrido sem erros, mas o arquivo APK não foi encontrado em '$APK_PATH'."
      cd ../..
      return 1
    fi
  else
    log "Erro ao compilar o APK. Certifique-se de que o Android SDK e as dependências estão configurados corretamente."
    cd ../..
    return 1
  fi
}

# --- Execução Principal ---

log "Início do script de criação do ambiente de desenvolvimento."

# Coletar informações do ambiente
collect_environment_info

# Criar o projeto LibGDX
if create_libgdx_project; then
  # Compactar o projeto
  zip_project

  # Tentar compilar o APK
  build_apk
else
  log "A criação do projeto LibGDX falhou. As etapas subsequentes serão ignoradas."
fi

log "Fim do script. O log detalhado foi salvo em '$LOG_FILE'."

echo "LOG_FILE=$LOG_FILE" >> $GITHUB_OUTPUT