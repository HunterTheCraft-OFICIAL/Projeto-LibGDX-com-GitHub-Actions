# Projeto LibGDX com GitHub Actions

Este projeto demonstra como automatizar a criação, construção e empacotamento de um projeto **LibGDX** usando **GitHub Actions**.

## Funcionalidades

- Geração automatizada da estrutura do projeto LibGDX com suporte para Android e Desktop.
- Build automatizado do APK Android (`assembleDebug`) e do Desktop (`dist`).
- Upload automático dos artefatos (APK e JAR) após o build.
- Cache de dependências Gradle para otimizar builds futuros.
- Totalmente executado na nuvem com runners do GitHub Actions — sem necessidade de máquina local.

## Estrutura

```
.github/
 ┣ workflows/
 ┃ ┗ build.yml              # Workflow de build automatizado
 ┗ scripts/
   ┗ create-libgdx-project.sh  # Script que clona template LibGDX
README.md                    # Este arquivo
```

## Como usar

1. Faça o fork ou clone deste repositório.
2. Realize um push para acionar o GitHub Actions.
3. Após o sucesso, baixe os artefatos gerados (APK/JAR) diretamente na aba **Actions** do GitHub.

## Observações

- Certifique-se de que seu template LibGDX usa uma versão recente do Gradle e está funcional via CLI.
- Se necessário, edite o script de geração para usar um fork personalizado do template LibGDX.

---

Criado para demonstrar uma pipeline moderna, 100% baseada em GitHub Actions.