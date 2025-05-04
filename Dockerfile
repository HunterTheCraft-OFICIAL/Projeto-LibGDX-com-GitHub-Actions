# Use uma imagem base com OpenJDK 17 e Ubuntu (Jammy é comum nos runners do GitHub)
FROM eclipse-temurin:17-jdk-jammy

# Defina variáveis de ambiente úteis
ENV ANDROID_SDK_ROOT /usr/lib/android-sdk
ENV ANDROID_API_LEVEL 34
ENV ANDROID_BUILD_TOOLS_VERSION 34.0.0
# Ajuste as versões da API e Build Tools conforme necessário

# Variáveis para evitar prompts interativos durante a instalação
ENV DEBIAN_FRONTEND=noninteractive

# Atualize os pacotes e instale dependências essenciais e Xvfb
# - wget, unzip, git, tree: Utilitários solicitados
# - xvfb: Servidor gráfico virtual X
# - libxi6, libxrandr2, libgl1-mesa-glx: Bibliotecas frequentemente necessárias para operações gráficas headless
# - python3, zip: Utilitários adicionais úteis
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    wget \
    unzip \
    git \
    tree \
    xvfb \
    libxi6 \
    libxrandr2 \
    libgl1-mesa-glx \
    ca-certificates \
    python3 \
    zip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Download e instalação das ferramentas de linha de comando do Android SDK
ENV CMDLINE_TOOLS_VERSION 11076708_latest
# Verifique a versão mais recente em https://developer.android.com/studio#command-line-tools-only
RUN wget --quiet --output-document=android-cmdline-tools.zip "https://dl.google.com/android/repository/commandlinetools-linux-${CMDLINE_TOOLS_VERSION}.zip" && \
    mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools && \
    unzip -q android-cmdline-tools.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools && \
    mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/latest && \
    rm android-cmdline-tools.zip

# Adicione as ferramentas do SDK ao PATH
ENV PATH $PATH:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools:${ANDROID_SDK_ROOT}/build-tools/${ANDROID_BUILD_TOOLS_VERSION}

# Aceite as licenças do Android SDK
# Use 'yes' para aceitar todas as licenças automaticamente
RUN yes | sdkmanager --licenses > /dev/null || true
# Instale as plataformas e ferramentas de build necessárias
RUN sdkmanager "platform-tools" "platforms;android-${ANDROID_API_LEVEL}" "build-tools;${ANDROID_BUILD_TOOLS_VERSION}"

# Download do gdx-liftoff (verifique a URL/versão mais recente se necessário)
# A versão pode ser encontrada nas releases do gdx-liftoff no GitHub
ENV GDX_LIFTOFF_VERSION 1.12.1.0
RUN wget "https://github.com/tommyettinger/gdx-liftoff/releases/download/v${GDX_LIFTOFF_VERSION}/gdx-liftoff.jar" -O /usr/local/bin/gdx-liftoff.jar && \
    chmod +x /usr/local/bin/gdx-liftoff.jar

# Defina o diretório de trabalho padrão para corresponder ao workspace do GitHub Actions
WORKDIR /github/workspace

# (Opcional) Exibir versões para depuração
RUN java -version
RUN sdkmanager --version
RUN echo "Android SDK Root: ${ANDROID_SDK_ROOT}"
RUN echo "PATH: ${PATH}"

# Não precisamos de CMD ou ENTRYPOINT, pois executaremos comandos específicos com 'docker run'