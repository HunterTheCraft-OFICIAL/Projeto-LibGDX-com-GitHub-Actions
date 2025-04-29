# Dockerfile para Ambiente de Build LibGDX (Construído em GitHub Actions)
# Salve como, por exemplo, Dockerfile na raiz do projeto

# ------------------------------------------------------------------------------
# Fase 1: Imagem Base e Dependências Essenciais
# ------------------------------------------------------------------------------
FROM ubuntu:22.04 AS base

# Define argumentos para versões (permite fácil atualização via build args)
ARG JDK_VERSION="17"
ARG ANDROID_CMD_TOOLS_VERSION="11076708" # Verifique https://developer.android.com/studio#command-tools
ARG ANDROID_PLATFORM_VERSION="34"
ARG ANDROID_BUILD_TOOLS_VERSION="34.0.0"

# Evita prompts interativos durante a instalação de pacotes
ENV DEBIAN_FRONTEND=noninteractive

# Atualiza e instala dependências em uma única camada para otimizar cache
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        wget \
        unzip \
        tree \
        # Java
        "openjdk-${JDK_VERSION}-jdk" \
        # Xvfb
        xvfb \
        x11-utils \
        # Dependências 32-bit para Android SDK em x64
        libc6-i386 \
        lib32stdc++6 \
        lib32gcc-s1 \
        lib32ncurses6 \
        lib32z1 \
    # Limpa o cache do apt
    && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------------------------
# Fase 2: Configuração do Ambiente Java e Xvfb
# ------------------------------------------------------------------------------
ENV JAVA_HOME=/usr/lib/jvm/java-${JDK_VERSION}-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH
ENV DISPLAY=:99 # Define display padrão para Xvfb

# ------------------------------------------------------------------------------
# Fase 3: Instalação e Configuração do Android SDK
# ------------------------------------------------------------------------------
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV PATH=$PATH:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools

ARG ANDROID_CMD_TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_CMD_TOOLS_VERSION}_latest.zip"

# Instala Android SDK em uma única camada RUN para otimizar cache
RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools && \
    wget -q ${ANDROID_CMD_TOOLS_URL} -O /tmp/cmdline-tools.zip && \
    unzip -q /tmp/cmdline-tools.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools && \
    mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/latest && \
    rm /tmp/cmdline-tools.zip && \
    # Aceita licenças (essencial!)
    yes | ${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/sdkmanager --licenses > /dev/null && \
    # Instala componentes SDK
    ${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/sdkmanager --update > /dev/null && \
    ${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/sdkmanager \
        "platform-tools" \
        "platforms;android-${ANDROID_PLATFORM_VERSION}" \
        "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" > /dev/null && \
    # Limpeza (opcional)
    rm -rf ${ANDROID_SDK_ROOT}/.temp

# ------------------------------------------------------------------------------
# Fase Final: Configuração do Ambiente de Trabalho
# ------------------------------------------------------------------------------
# Define o diretório de trabalho que será usado pelo 'docker run'
# /github/workspace é onde o Actions monta o código por padrão
WORKDIR /github/workspace

# Exibe versões instaladas para depuração nos logs do Actions
RUN echo "--- Versões na Imagem Docker ---" && \
    java -version && \
    echo "Android SDK Location: ${ANDROID_SDK_ROOT}" && \
    ${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/sdkmanager --version && \
    echo "-------------------------------"

# Nenhum CMD ou ENTRYPOINT é necessário, pois os comandos serão passados via 'docker run'