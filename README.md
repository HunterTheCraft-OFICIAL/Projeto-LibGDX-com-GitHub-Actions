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

  # Comando para criar o projeto LibGDX (você pode precisar ajustar a versão)
  java -jar gdx-setup.jar -name "$PROJECT_NAME" -package com.meugame -mainClass MeuJogo -androidSdk .

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

  # Tentar compilar o APK (ciente de que pode falhar)
  build_apk
else
  log "A criação do projeto LibGDX falhou. As etapas subsequentes serão ignoradas."
fi

# Sempre salvar o arquivo de log
log "Fim do script. O log detalhado foi salvo em '$LOG_FILE'."

# Para que o GitHub Actions possa salvar o log como um artefato
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

on: [push] # Ou outro evento que você preferir (por exemplo, workflow_dispatch para execução manual)

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
        java-version: '17' # Ou outra versão compatível

    - name: Download LibGDX Setup
      run: wget [https://github.com/libgdx/libgdx/releases/download/1.12.1/gdx-setup.jar](https://github.com/libgdx/libgdx/releases/download/1.12.1/gdx-setup.jar) # Verifique a versão mais recente em [https://libgdx.com/download/](https://libgdx.com/download/)

    - name: Make script executable
      run: chmod +x build_env.sh

    - name: Run build script
      id: build_script
      run: ./build_env.sh

    - name: Upload Project ZIP
      uses: actions/upload-artifact@v4
      with:
        name: project-zip
        path: ${{ steps.build_script.outputs.LOG_FILE == '' && 'meu-jogo-libgdx.zip' || 'meu-jogo-libgdx.zip' }}

    - name: Upload APK ZIP (se gerado)
      if: steps.build_script.outputs.LOG_FILE == '' && -f meu-jogo-debug.apk.zip
      uses: actions/upload-artifact@v4
      with:
        name: apk-zip
        path: meu-jogo-debug.apk.zip

    - name: Upload Logs
      uses: actions/upload-artifact@v4
      with:
        name: build-logs
        path: ${{ steps.build_script.outputs.LOG_FILE }}
```

 * Certifique-se de que o arquivo build_env.sh esteja na raiz do seu repositório.
As seções seguintes do README.md (Executando o Workflow, Verificando os Resultados e Logs, Dica para Verificar Logs Anteriores e Próximos Passos) permanecem as mesmas e explicam como interagir com o workflow no GitHub Actions.
