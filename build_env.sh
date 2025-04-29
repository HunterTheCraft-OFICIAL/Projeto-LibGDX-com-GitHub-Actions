#!/bin/bash

# Endereço: './build_env.sh'

# --- Configurações ---
PROJECT_NAME="meu-jogo-libgdx"
OUTPUT_ZIP="${PROJECT_NAME}.zip"
LOG_FILE="build.log"
ANDROID_SDK_PATH="/opt/android-sdk" # Caminho esperado no container

# --- Funções ---

log() {
  TIMESTAMP=$(date +%Y-%m-%d_%H:%M:%S)
  echo "[${TIMESTAMP}] $1"
}

# Verificar se o Android SDK está presente (opcional)
check_android_sdk() {
  if [ -d "$ANDROID_SDK_PATH" ]; then
    log "Android SDK encontrado em: $ANDROID_SDK_PATH"
    return 0
  else
    log "Aviso: Android SDK não encontrado no caminho esperado: $ANDROID_SDK_PATH"
    return 1
  fi
}

create_libgdx_project() {
  log "Iniciando a criação do projeto LibGDX (não interativo) dentro do Docker..."
  if ! command -v java &> /dev/null; then
    log "Erro: Java não encontrado no sistema (dentro do container)."
    return 1
  fi

  java -jar gdx-setup.jar \
    --dir="$PROJECT_NAME" \
    --name="$PROJECT_NAME" \
    --package="com.meugame" \
    --mainClass="MeuJogo" \
    --sdk="$ANDROID_SDK_PATH" \
    --platforms="desktop,android,ios,web" \
    --extensions="extensions/controllers,extensions/freetype,extensions/ashley,extensions/bullet"

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

log "Início do script de build dentro do Docker."

# Verificar o Android SDK (opcional)
check_android_sdk

# Criar o projeto LibGDX
if create_libgdx_project; then
  # Compactar o projeto
  zip_project
fi

# Tentar compilar o APK (vamos manter isso por enquanto)
build_apk

log "Fim do script. O log detalhado foi salvo em '$LOG_FILE'."

echo "LOG_FILE=$LOG_FILE" >> $GITHUB_OUTPUT