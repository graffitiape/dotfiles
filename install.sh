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
      mkdir -p "$BRAIN/Projects/Work" "$BRAIN/Projects/Hobby" \
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

# Install Nerd Font (macOS only)
if [[ "$(uname)" == "Darwin" ]] && ! ls ~/Library/Fonts/MesloLG* &>/dev/null; then
  echo "Installing MesloLG Nerd Font..."
  brew install --cask font-meslo-lg-nerd-font
fi

echo ""
echo "Done! Restart your terminal or run: source ~/.zshrc"
