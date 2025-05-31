# 🎮 Projeto Base LibGDX com GitHub Actions - Simulador de IDE

Este repositório funciona como um **Simulador Automatizado de uma IDE** para projetos LibGDX. Ele é responsável por **criar, empacotar e disponibilizar** um projeto base configurado, pronto para ser usado ou compilado, diretamente nos **Lançamentos (Releases)** do GitHub.

---

## 📌 Objetivo

Automatizar o processo de criação de um projeto base com a biblioteca **LibGDX**, utilizando **GitHub Actions** para:

- Simular o setup de uma IDE como IntelliJ/Android Studio.
- Gerar a estrutura inicial do projeto.
- Empacotar o projeto em `.zip` como artefato.
- Anexar o projeto gerado diretamente nos **Lançamentos**.
- Registrar logs detalhados de todo o processo.

---

## 🧩 Estrutura de Repositórios

Este repositório faz parte de um sistema dividido em dois estágios:

| Função                      | Repositório               | Descrição |
|----------------------------|---------------------------|-----------|
| 🛠️ Criação da Base         | **(Este repositório)**    | Gera e empacota o projeto base LibGDX automaticamente. |
| 📦 Compilação e Testes     | *(Repositório 2 futuramente)* | Recebe o projeto `.zip`, compila para Android/Desktop e realiza testes. |

---

## ⚙️ Funcionalidades

- [x] Geração do projeto base usando **LibGDX Setup Tool**.
- [x] Criação de artefatos `.zip` e `.log`.
- [x] Upload automático nos **Lançamentos**.
- [x] Logs detalhados em tempo real no GitHub Actions.
- [x] Separação de logs por fase (instalação, setup, geração, compressão).
- [x] Checkpoints e validação de versões de ferramentas.

---

## 🚀 Como Usar

1. **Acesse a aba "Actions"** neste repositório.
2. Escolha o workflow `Build LibGDX Base`.
3. Clique em **"Run workflow"** (ou aguarde disparo automático).
4. Acesse a aba **Releases** para baixar o `.zip` do projeto gerado.
5. Extraia e abra o projeto em sua IDE de preferência (recomendado: IntelliJ ou Android Studio).

---

## 📁 Artefatos Gerados

- `liggdx-base-project.zip` → Projeto gerado com estrutura completa.
- `setup-log.log` → Log detalhado de todo o processo.
- (Futuramente) `.apk`, `.jar`, `.aab` → via Repositório 2.

---

## 📜 Créditos

- 🔧 Projeto automatizado por [GitHub Actions](https://github.com/features/actions)
- 🎮 Baseado no framework [LibGDX](https://libgdx.com/)
- 🧠 Script de automação e integração por HunterTheCraft (YouTube / GitHub)
- 💻 Assistência IA por ChatGPT (OpenAI)

---

## 📌 Licença

Este projeto é distribuído sob a licença **MIT**. Veja o arquivo `LICENSE` para mais informações.

---

## 📈 Em desenvolvimento...

Futuramente este projeto será integrado com um segundo repositório para realizar:

- Compilação automatizada para Android.
- Geração de `.apk` e `.jar`.
- Testes automatizados de funcionalidade.
- Deploy contínuo para ambientes externos.

