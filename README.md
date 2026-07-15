# Scripts

Scripts de provisionamento para configurar um Mac novo do zero: Homebrew, apps essenciais,
editores (VS Code e Cursor), Node via `fnm`, Oh My Zsh, Starship e Claude Code CLI.

Todos os scripts são **idempotentes** (podem ser executados mais de uma vez sem quebrar).

## Scripts disponíveis

| Script | Para quem | Diferencial |
|--------|-----------|-------------|
| `setup_mac_new.sh` | Qualquer Mac (Intel ou Apple Silicon) | Detecta o caminho do Homebrew automaticamente |
| `setup_mac_m.sh` | Mac com chip Apple Silicon (M1/M2/M3/M4) | Instala Rosetta 2 e fixa o Homebrew em `/opt/homebrew` |

Se você tem um Mac com processador M, use o `setup_mac_m.sh`. Nos demais casos, use o `setup_mac_new.sh`.

## Como usar

### Opção 1 - Instalação direta via curl (recomendado)

Cole no Terminal o comando correspondente ao seu Mac.

Mac com chip Apple Silicon (M1/M2/M3/M4):

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/thiagomontini-dr/Scripts/main/setup_mac_m.sh)"
```

Qualquer Mac (Intel ou Apple Silicon):

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/thiagomontini-dr/Scripts/main/setup_mac_new.sh)"
```

### Opção 2 - Clonar o repositório e executar

```bash
git clone https://github.com/thiagomontini-dr/Scripts.git
cd Scripts

# Apple Silicon (M)
chmod +x setup_mac_m.sh && ./setup_mac_m.sh

# ou qualquer Mac
chmod +x setup_mac_new.sh && ./setup_mac_new.sh
```

## O que é instalado

- **Xcode Command Line Tools** (pré-requisito do Homebrew)
- **Rosetta 2** (apenas no `setup_mac_m.sh`, para apps x86)
- **Homebrew** e atualização dos formulae
- **CLI:** `git`, `fnm`, `deno`, `mas`, `starship`
- **Editores:** Visual Studio Code, Cursor
- **Terminal / API:** iTerm2, Postman, Insomnia, Cyberduck, Flycut
- **Containers:** Docker Desktop
- **Comunicação / Produtividade:** Slack, Notion, Zoom, Microsoft Teams, Google Drive, Google Chrome, Alfred
- **Node.js** (LTS via `fnm`, com auto-switch por projeto)
- **Oh My Zsh** (instalação unattended)
- **Claude Code CLI** (`@anthropic-ai/claude-code`)
- **Apps da Mac App Store** via `mas` (opcional, requer login na App Store)

## Observações

- Ao final, abra um novo terminal para carregar as configurações (`fnm`, Homebrew, etc.).
- A seção da Mac App Store (`mas`) só roda se você estiver logado na App Store; caso contrário, é ignorada com um aviso.
- Node é gerenciado por `fnm` (não por `brew install node`) para evitar conflito de versões.
- Ajuste os IDs de apps da App Store no final do script conforme sua preferência (use `mas search "nome"` para descobrir o ID).

## Datas

- Criado em: 2026-07-15
- Última atualização: 2026-07-15
