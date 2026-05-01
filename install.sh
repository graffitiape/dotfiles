#!/bin/bash
set -e

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

link() {
  local src="$DOTFILES/$1"
  local dst="$HOME/$1"

  mkdir -p "$(dirname "$dst")"

  if [ -L "$dst" ]; then
    rm "$dst"
  elif [ -e "$dst" ]; then
    echo "Backing up existing $dst -> $dst.bak"
    mv "$dst" "$dst.bak"
  fi

  ln -s "$src" "$dst"
  echo "Linked $dst -> $src"
}

ensure_toml_top_level_key() {
  local file="$1"
  local key="$2"
  local value="$3"

  if grep -q "^$key *= *" "$file"; then
    return
  fi

  local tmp
  tmp="$(mktemp)"
  awk -v line="$key = $value" '
    !inserted && /^\[/ { print line; inserted=1 }
    { print }
    END { if (!inserted) print line }
  ' "$file" > "$tmp"
  mv "$tmp" "$file"
}

# Shell
link .zshrc
link .p10k.zsh
link .tmux.conf

# Ghostty
link .config/ghostty/config

# Neovim
link .config/nvim/init.lua
link .config/nvim/lua
link .config/nvim/lazy-lock.json

# Install oh-my-zsh if missing
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install powerlevel10k if missing
P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [ ! -d "$P10K_DIR" ]; then
  echo "Installing Powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
fi

# Install zsh plugins if missing
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  echo "Installing zsh-syntax-highlighting..."
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  echo "Installing zsh-autosuggestions..."
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

# Claude Code
link .claude/CLAUDE.md
link .claude/settings.json
link .claude/hooks

# Claude Code — detect Obsidian vault and configure brain path
if [ ! -f "$HOME/.claude/obsidian-brain-path" ]; then
  OBSIDIAN_VAULT=""

  # macOS iCloud Obsidian
  if [[ "$(uname)" == "Darwin" ]]; then
    ICLOUD_OBSIDIAN="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents"
    if [ -d "$ICLOUD_OBSIDIAN" ]; then
      # Find first vault (directory containing .obsidian/)
      OBSIDIAN_VAULT=$(find "$ICLOUD_OBSIDIAN" -maxdepth 2 -name ".obsidian" -type d 2>/dev/null | head -1 | xargs dirname 2>/dev/null)
    fi
  fi

  # Fallback: common Linux/generic locations
  if [ -z "$OBSIDIAN_VAULT" ]; then
    for dir in "$HOME/Documents" "$HOME/Obsidian" "$HOME"; do
      if [ -d "$dir" ]; then
        OBSIDIAN_VAULT=$(find "$dir" -maxdepth 3 -name ".obsidian" -type d 2>/dev/null | head -1 | xargs dirname 2>/dev/null)
        [ -n "$OBSIDIAN_VAULT" ] && break
      fi
    done
  fi

  if [ -n "$OBSIDIAN_VAULT" ]; then
    echo "$OBSIDIAN_VAULT" > "$HOME/.claude/obsidian-brain-path"
    echo "Detected Obsidian vault: $OBSIDIAN_VAULT"

    # Create Claude Brain folder structure if missing
    BRAIN="$OBSIDIAN_VAULT/Claude Brain"
    if [ ! -d "$BRAIN" ]; then
      mkdir -p "$BRAIN/Projects/Work" "$BRAIN/Projects/Hobby" "$BRAIN/Projects/Side-Projects" \
               "$BRAIN/Learnings" "$BRAIN/Decisions" \
               "$BRAIN/Sessions" "$BRAIN/Preferences"
      echo "Created Claude Brain folder structure in vault"
    fi

    # Create/update settings.local.json with brain write permissions
    LOCAL_SETTINGS="$HOME/.claude/settings.local.json"
    if [ ! -f "$LOCAL_SETTINGS" ]; then
      cat > "$LOCAL_SETTINGS" << EOJSON
{
  "permissions": {
    "allow": [
      "Read($OBSIDIAN_VAULT/Claude Brain/**)",
      "Write($OBSIDIAN_VAULT/Claude Brain/**)",
      "Edit($OBSIDIAN_VAULT/Claude Brain/**)"
    ]
  }
}
EOJSON
      echo "Created settings.local.json with brain permissions"
    else
      echo "Note: settings.local.json already exists — you may need to manually add brain write permissions"
    fi
  else
    echo "Warning: No Obsidian vault found. Claude Brain will auto-detect on first session."
  fi
fi

# Codex
link .codex/AGENTS.md
link .codex/hooks.json
link .codex/hooks/obsidian_session_start.sh
link .codex/hooks/obsidian_stop.sh

# Codex — detect Obsidian vault and configure brain path/hooks
mkdir -p "$HOME/.codex"
CODEX_OBSIDIAN_VAULT=""

if [ -f "$HOME/.codex/obsidian-brain-path" ]; then
  CODEX_OBSIDIAN_VAULT="$(cat "$HOME/.codex/obsidian-brain-path")"
elif [ -f "$HOME/.claude/obsidian-brain-path" ]; then
  CODEX_OBSIDIAN_VAULT="$(cat "$HOME/.claude/obsidian-brain-path")"
fi

if [ -z "$CODEX_OBSIDIAN_VAULT" ] || [ ! -d "$CODEX_OBSIDIAN_VAULT" ]; then
  CODEX_OBSIDIAN_VAULT=""

  # macOS iCloud Obsidian
  if [[ "$(uname)" == "Darwin" ]]; then
    ICLOUD_OBSIDIAN="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents"
    if [ -d "$ICLOUD_OBSIDIAN" ]; then
      CODEX_OBSIDIAN_VAULT=$(find "$ICLOUD_OBSIDIAN" -maxdepth 2 -name ".obsidian" -type d 2>/dev/null | head -1 | xargs dirname 2>/dev/null)
    fi
  fi

  # Fallback: common Linux/generic locations
  if [ -z "$CODEX_OBSIDIAN_VAULT" ]; then
    for dir in "$HOME/Documents" "$HOME/Obsidian" "$HOME"; do
      if [ -d "$dir" ]; then
        CODEX_OBSIDIAN_VAULT=$(find "$dir" -maxdepth 3 -name ".obsidian" -type d 2>/dev/null | head -1 | xargs dirname 2>/dev/null)
        [ -n "$CODEX_OBSIDIAN_VAULT" ] && break
      fi
    done
  fi
fi

if [ -n "$CODEX_OBSIDIAN_VAULT" ]; then
  echo "$CODEX_OBSIDIAN_VAULT" > "$HOME/.codex/obsidian-brain-path"
  echo "Configured Codex Obsidian brain path: $CODEX_OBSIDIAN_VAULT"

  CODEX_BRAIN="$CODEX_OBSIDIAN_VAULT/Claude Brain"
  mkdir -p "$CODEX_BRAIN/Projects/Work" "$CODEX_BRAIN/Projects/Hobby" "$CODEX_BRAIN/Projects/Side-Projects" \
           "$CODEX_BRAIN/Learnings" "$CODEX_BRAIN/Decisions" \
           "$CODEX_BRAIN/Sessions" "$CODEX_BRAIN/Preferences"

  CODEX_CONFIG="$HOME/.codex/config.toml"
  touch "$CODEX_CONFIG"
  ensure_toml_top_level_key "$CODEX_CONFIG" "commit_attribution" '""'

  if command -v codex >/dev/null 2>&1; then
    codex features enable codex_hooks >/dev/null 2>&1 || echo "Note: could not enable Codex hooks automatically"
  elif ! grep -q "^codex_hooks *= *true" "$CODEX_CONFIG"; then
    if grep -q "^\[features\]" "$CODEX_CONFIG"; then
      echo "Note: add 'codex_hooks = true' under [features] in $CODEX_CONFIG"
    else
      cat >> "$CODEX_CONFIG" << EOTOML

[features]
codex_hooks = true
EOTOML
    fi
  fi

  if ! grep -Fq "$CODEX_BRAIN" "$CODEX_CONFIG"; then
    if grep -q "^\[sandbox_workspace_write\]" "$CODEX_CONFIG"; then
      echo "Note: add '$CODEX_BRAIN' to sandbox_workspace_write.writable_roots in $CODEX_CONFIG"
    else
      cat >> "$CODEX_CONFIG" << EOTOML

[sandbox_workspace_write]
writable_roots = ["$CODEX_BRAIN"]
EOTOML
    fi
  fi
else
  echo "Warning: No Obsidian vault found. Codex Brain will auto-detect using AGENTS.md fallback instructions."
fi

# Install Nerd Font (macOS only)
if [[ "$(uname)" == "Darwin" ]] && ! ls ~/Library/Fonts/MesloLG* &>/dev/null; then
  echo "Installing MesloLG Nerd Font..."
  brew install --cask font-meslo-lg-nerd-font
fi

echo ""
echo "Done! Restart your terminal or run: source ~/.zshrc"
