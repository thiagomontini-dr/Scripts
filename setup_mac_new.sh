#!/usr/bin/env bash
#
# setup_mac_new.sh - Provisionamento de um Mac novo (Apple Silicon / Intel)
#
# Idempotente: pode rodar mais de uma vez sem quebrar.
# Uso: chmod +x setup_mac_new.sh && ./setup_mac_new.sh
#
set -euo pipefail

# ------------------------------------------------------------------------------
# Helpers de log
# ------------------------------------------------------------------------------
log()  { printf "\033[1;34m==>\033[0m %s\n" "$1"; }
ok()   { printf "\033[1;32m ✓\033[0m %s\n" "$1"; }
warn() { printf "\033[1;33m ! \033[0m%s\n" "$1"; }

# ------------------------------------------------------------------------------
# 1. Xcode Command Line Tools
# ------------------------------------------------------------------------------
if ! xcode-select -p >/dev/null 2>&1; then
  log "Instalando Xcode Command Line Tools..."
  xcode-select --install || true
  warn "Conclua o instalador gráfico do Xcode CLT e rode este script novamente."
  exit 1
else
  ok "Xcode Command Line Tools presentes."
fi

# ------------------------------------------------------------------------------
# 2. Homebrew
# ------------------------------------------------------------------------------
if ! command -v brew >/dev/null 2>&1; then
  log "Instalando Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Carrega o brew no PATH da sessão atual (Apple Silicon: /opt/homebrew, Intel: /usr/local)
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi
ok "Homebrew disponível: $(brew --version | head -n1)"

log "Atualizando Homebrew..."
brew update

# ------------------------------------------------------------------------------
# 3. Pacotes via Brewfile (brew bundle = idempotente)
# ------------------------------------------------------------------------------
BREWFILE="$(mktemp)"
cat > "$BREWFILE" <<'BREW'
# --- CLI / Ferramentas de desenvolvimento -----------------------------------
brew "git"
brew "fnm"              # gerenciador de versão do Node (rápido, auto-switch)
brew "deno"             # runtime alternativo ao Node
brew "mas"              # instalador da Mac App Store via CLI
brew "starship"         # prompt customizável
brew "python"           # Python 3 mais recente (inclui pip3)

# --- Editores ----------------------------------------------------------------
cask "visual-studio-code"
cask "cursor"           # editor com IA

# --- Terminal / API ----------------------------------------------------------
cask "iterm2"
cask "postman"
cask "insomnia"
cask "flycut"

# --- Containers --------------------------------------------------------------
cask "docker-desktop"   # já traz a CLI do Docker

# --- Comunicação / Produtividade --------------------------------------------
cask "slack"
cask "notion"
cask "zoom"
cask "microsoft-teams"
cask "google-drive"
cask "google-chrome"
cask "alfred"
BREW

log "Instalando pacotes (brew bundle)..."
brew bundle --file="$BREWFILE"
rm -f "$BREWFILE"
ok "Pacotes Homebrew instalados."

# ------------------------------------------------------------------------------
# 4. Node via fnm (não usar brew install node para evitar conflito)
# ------------------------------------------------------------------------------
if ! grep -q 'fnm env' "${HOME}/.zshrc" 2>/dev/null; then
  log "Configurando fnm no ~/.zshrc..."
  {
    echo ''
    echo '# fnm - Node version manager'
    echo 'eval "$(fnm env --use-on-cd)"'
  } >> "${HOME}/.zshrc"
fi
eval "$(fnm env)"
log "Instalando Node LTS via fnm..."
fnm install --lts
fnm default "$(fnm current)"
ok "Node ativo: $(node --version)"

# ------------------------------------------------------------------------------
# 5. Oh My Zsh (unattended, sem interromper o script)
# ------------------------------------------------------------------------------
if [[ ! -d "${HOME}/.oh-my-zsh" ]]; then
  log "Instalando Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  ok "Oh My Zsh já instalado."
fi

# ------------------------------------------------------------------------------
# 6. Claude Code CLI
# ------------------------------------------------------------------------------
if ! command -v claude >/dev/null 2>&1; then
  log "Instalando Claude Code CLI..."
  npm install -g @anthropic-ai/claude-code
  ok "Claude Code instalado: $(claude --version 2>/dev/null || echo 'ok')"
else
  ok "Claude Code CLI já instalado."
fi

# ------------------------------------------------------------------------------
# 7. Mac App Store (opcional - requer login na App Store)
# ------------------------------------------------------------------------------
if mas account >/dev/null 2>&1; then
  log "Instalando apps da Mac App Store..."
  mas install 937984704   # Amphetamine (mantém o Mac acordado)
  mas install 1319778037  # iStat Menus  (ajuste/remova conforme quiser)
  ok "Apps da App Store instalados."
else
  warn "Não logado na Mac App Store - pulando 'mas'. Faça login e rode 'mas install <id>'."
fi

echo ""
ok "Setup concluído! Abra um novo terminal para carregar as configurações."
