# Tutorial de Configuração do GitHub Actions para Inicializar Projeto LibGDX

Este tutorial explica como configurar o GitHub Actions neste repositório para automatizar a criação de um projeto LibGDX, compactá-lo em um arquivo ZIP e, opcionalmente, tentar compilar um APK. Uma vez que o workflow do GitHub Actions for configurado e executado com sucesso, um arquivo ZIP contendo a estrutura inicial do projeto LibGDX será gerado como um artefato.

**Observação Importante:** Inicialmente, este repositório não contém o projeto LibGDX em si. O objetivo desta configuração é usar o GitHub Actions para gerar esse projeto inicial. Após a primeira execução bem-sucedida do workflow, este `README.md` será atualizado com a estrutura real do projeto.

## 1. Pré-requisitos

* Você deve ter uma conta no GitHub.
* Você deve ter criado um repositório no GitHub para este projeto (mesmo que esteja vazio inicialmente).
* Você precisará criar um arquivo chamado `build_env.sh` na raiz do seu repositório com o seguinte conteúdo.
* Você deverá enviar este arquivo `README.md` e o script de build (`build_env.sh`) para o seu repositório.

## 2. Criando o Script de Build (`build_env.sh`)

Crie um arquivo chamado `build_env.sh` na raiz do seu repositório e cole o seguinte código dentro dele:

```bash
#!/bin/bash

# Endereço: './build_env.sh'

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
```

3. Configurando o Workflow do GitHub Actions
Agora, siga estes passos para criar o workflow que executará o script acima:
 * Crie um diretório .github na raiz do seu repositório.
 * Dentro do diretório .github, crie outro diretório chamado workflows.
 * Dentro do diretório workflows, crie um arquivo com a extensão .yml (por exemplo, build.yml).
 * Copie e cole o seguinte conteúdo no arquivo build.yml:

```bash
name: Build LibGDX Environment

on: [push]

permissions:
  contents: write

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout repository
      uses: actions/checkout@v4

    - name: Set up Java
      uses: actions/setup-java@v4
      with:
        distribution: 'temurin'
        java-version: '17'

    - name: Install 'tree'
      run: sudo apt-get update && sudo apt-get install -y tree # Instala o 'tree' para o log

    - name: Download LibGDX Liftoff
      run: wget https://github.com/libgdx/gdx-liftoff/releases/download/v1.13.1.3/gdx-liftoff-1.13.1.3.jar -O gdx-setup.jar

    - name: Make script executable
      run: chmod +x build_env.sh

    - name: Run build script and collect info
      id: build_script
      run: ./build_env.sh > build.log 2>&1

    - name: Upload Log File
      uses: actions/upload-artifact@v4
      with:
        name: build-log
        path: build.log

    - name: Check for Project ZIP
      id: check_project_zip
      run: |
        if [ -f meu-jogo-libgdx.zip ]; then
          echo "PROJECT_ZIP_EXISTS=true" >> "$GITHUB_OUTPUT"
        else
          echo "PROJECT_ZIP_EXISTS=false" >> "$GITHUB_OUTPUT"
        fi

    - name: Upload Project ZIP (se criado)
      if: steps.build_script.outcome == 'success' && steps.check_project_zip.outputs.PROJECT_ZIP_EXISTS == 'true'
      uses: actions/upload-artifact@v4
      with:
        name: project-zip
        path: meu-jogo-libgdx.zip

    - name: Check for APK
      id: check_apk
      run: |
        if [ -f meu-jogo-debug.apk ]; then
          echo "APK_EXISTS=true" >> "$GITHUB_OUTPUT"
        else
          echo "APK_EXISTS=false" >> "$GITHUB_OUTPUT"
        fi

    - name: Upload APK (se gerado)
      if: steps.build_script.outcome == 'success' && steps.check_apk.outputs.APK_EXISTS == 'true'
      uses: actions/upload-artifact@v4
      with:
        name: debug-apk
        path: meu-jogo-debug.apk

    - name: Upload Liftoff JAR
      uses: actions/upload-artifact@v4
      with:
        name: liftoff-jar
        path: gdx-setup.jar

    - name: Create Release (with Log Mention)
      if: always()
      uses: actions/create-release@v1
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      with:
        tag_name: ${{ github.run_id }}
        release_name: Build Log - ${{ github.run_id }}
        body: |
          Logs da execução do workflow: ${{ github.run_id }}

          Você pode encontrar o arquivo de log completo como um artefato ('build-log') na página desta execução do workflow.
          O JAR do Liftoff também está disponível como um artefato ('liftoff-jar').
          ${{ steps.check_project_zip.outputs.PROJECT_ZIP_EXISTS == 'true' && 'O ZIP do projeto está disponível como um artefato (project-zip).' || '' }}
          ${{ steps.check_apk.outputs.APK_EXISTS == 'true' && 'O APK de debug está disponível como um artefato (debug-apk).' || '' }}
        draft: false
        prerelease: true
```

 * Certifique-se de que o arquivo build_env.sh esteja na raiz do seu repositório.
As seções seguintes do README.md (Executando o Workflow, Verificando os Resultados e Logs, Dica para Verificar Logs Anteriores e Próximos Passos) permanecem as mesmas e explicam como interagir com o workflow no GitHub Actions.
