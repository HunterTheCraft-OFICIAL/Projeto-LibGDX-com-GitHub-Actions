#!/bin/bash

# --- Configurações ---
PROJECT_NAME="meu-jogo-libgdx" # Nome padrão do projeto (pode ser alterado)
OUTPUT_ZIP="${PROJECT_NAME}.zip"
LOG_FILE="build.log"

# --- Funções ---

# Função para registrar mensagens no log
log() {
  TIMESTAMP=$(date +%Y-%m-%d_%H:%M:%S)
  echo "[${TIMESTAMP}] $1" >> "$LOG_FILE"
}

# Função para criar o projeto LibGDX
create_libgdx_project() {
  log "Iniciando a criação do projeto LibGDX..."
  if ! command -v java &> /dev/null; then
    log "Erro: Java não encontrado no sistema. A criação do projeto LibGDX requer Java."
    return 1
  fi

  # Comando para criar o projeto LibGDX (removendo a dependência do Android SDK neste momento)
  java -jar gdx-setup.jar -name "$PROJECT_NAME" -package com.meugame -mainClass MeuJogo

  if [ $? -eq 0 ]; then
    log "Projeto LibGDX criado com sucesso na pasta '$PROJECT_NAME'."
    return 0
  else
    log "Erro ao criar o projeto LibGDX."
    return 1
  fi
}

# Função para compactar o projeto em um arquivo ZIP
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

# Função para tentar compilar o APK (pode falhar sem Android SDK configurado)
build_apk() {
  log "Tentando compilar o APK..."
  cd "$PROJECT_NAME/android" || {
    log "Erro: Não foi possível acessar a pasta 'android'."
    return 1
  }

  # Este comando pode variar dependendo da sua configuração e versão do Gradle
  ./gradlew assembleDebug

  if [ $? -eq 0 ]; then
    APK_PATH="build/outputs/apk/debug/android-debug.apk"
    if [ -f "$APK_PATH" ]; then
      log "APK compilado com sucesso em '$APK_PATH'."
      # Podemos tentar zipar o APK também
      APK_OUTPUT="meu-jogo-debug.apk.zip"
      zip "$APK_OUTPUT" "$APK_PATH" && log "APK também compactado como '$APK_OUTPUT'."
      cd ../..
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

# Criar o projeto LibGDX
if create_libgdx_project; then
  # Compactar o projeto
  zip_project

  # Tentar compilar o APK (ciente de que pode falhar sem Android SDK configurado)
  build_apk
else
  log "A criação do projeto LibGDX falhou. As etapas subsequentes serão ignoradas."
fi

# Sempre salvar o arquivo de log
log "Fim do script. O log detalhado foi salvo em '$LOG_FILE'."

# Para que o GitHub Actions possa salvar o log como um artefato
echo "LOG_FILE=$LOG_FILE" >> $GITHUB_OUTPUT