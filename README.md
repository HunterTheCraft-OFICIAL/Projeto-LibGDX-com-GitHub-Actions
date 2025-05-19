# Projeto LibGDX com GitHub Actions

Este projeto demonstra como automatizar a criação, construção e empacotamento de um projeto **LibGDX** usando **GitHub Actions**.

## Funcionalidades

- Geração automatizada da estrutura do projeto LibGDX com suporte para Android e Desktop.
- Build automatizado do APK Android (`assembleDebug`) e do Desktop (`dist`).
- Upload automático dos artefatos (APK e JAR) após o build.
- Cache de dependências Gradle para otimizar builds futuros.
- Totalmente executado na nuvem com runners do GitHub Actions — sem necessidade de máquina local.

## Como usar

1. Faça o fork ou clone deste repositório.
2. Realize um push para acionar o GitHub Actions.
3. Após o sucesso, baixe os artefatos gerados (APK/JAR) diretamente na aba **Actions** do GitHub.

## Observações

- O projeto utiliza Gradle 8.5 para garantir compatibilidade com Java 17.
- A estrutura inicial do projeto é baseada em um template LibGDX público.

---
Criado para demonstrar uma pipeline moderna, 100% baseada em GitHub Actions.