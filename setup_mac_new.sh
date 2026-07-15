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
brew "gh"               # GitHub CLI
brew "uv"               # gerenciador de pacotes/ambientes Python (rápido)

# --- CLIs modernas de terminal ----------------------------------------------
brew "jq"               # processador de JSON
brew "wget"
brew "ripgrep"          # busca em arquivos (rg)
brew "fzf"              # fuzzy finder
brew "bat"              # cat com syntax highlight
brew "eza"              # ls moderno
brew "fd"               # find moderno
brew "zoxide"           # cd inteligente (z)
brew "tree"
brew "htop"             # monitor de processos

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
cask "rectangle"        # gerenciador de janelas por atalho

# --- Fontes ------------------------------------------------------------------
cask "font-meslo-lg-nerd-font"  # necessária para os ícones do starship
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
# 6. Integrações de shell no ~/.zshrc (starship, zoxide)
# ------------------------------------------------------------------------------
if ! grep -q 'starship init zsh' "${HOME}/.zshrc" 2>/dev/null; then
  log "Configurando starship no ~/.zshrc..."
  {
    echo ''
    echo '# starship - prompt'
    echo 'eval "$(starship init zsh)"'
  } >> "${HOME}/.zshrc"
fi
if ! grep -q 'zoxide init zsh' "${HOME}/.zshrc" 2>/dev/null; then
  log "Configurando zoxide no ~/.zshrc..."
  {
    echo ''
    echo '# zoxide - cd inteligente (use "z <pasta>")'
    echo 'eval "$(zoxide init zsh)"'
  } >> "${HOME}/.zshrc"
fi
ok "Integrações de shell configuradas."

# ------------------------------------------------------------------------------
# 7. Configuração básica do Git
# ------------------------------------------------------------------------------
git config --global init.defaultBranch main
git config --global pull.rebase false
git config --global push.autoSetupRemote true
GITIGNORE_GLOBAL="${HOME}/.gitignore_global"
if [[ ! -f "$GITIGNORE_GLOBAL" ]]; then
  printf '.DS_Store\n.env\nnode_modules/\n__pycache__/\n.venv/\n' > "$GITIGNORE_GLOBAL"
fi
git config --global core.excludesfile "$GITIGNORE_GLOBAL"
if [[ -z "$(git config --global user.name || true)" ]]; then
  warn "Git sem user.name/user.email. Configure com:"
  warn "  git config --global user.name \"Seu Nome\""
  warn "  git config --global user.email \"voce@exemplo.com\""
fi
ok "Git configurado (defaults + .gitignore global)."

# ------------------------------------------------------------------------------
# 8. Claude Code CLI
# ------------------------------------------------------------------------------
if ! command -v claude >/dev/null 2>&1; then
  log "Instalando Claude Code CLI..."
  npm install -g @anthropic-ai/claude-code
  ok "Claude Code instalado: $(claude --version 2>/dev/null || echo 'ok')"
else
  ok "Claude Code CLI já instalado."
fi

# ------------------------------------------------------------------------------
# 9. Mac App Store (opcional - requer login na App Store)
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
