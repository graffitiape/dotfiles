# dotfiles

My personal configs for zsh, neovim, tmux, and ghostty.

## What's included

- **Zsh** — Oh My Zsh + Powerlevel10k (minimal style, Catppuccin Macchiato colors)
- **Neovim** — Lazy.nvim plugin manager, LSP, Treesitter, Telescope, Harpoon, and more
- **Tmux** — Dracula theme with custom orange accent, vim-style pane navigation
- **Ghostty** — Catppuccin Macchiato theme, semi-transparent background
- **Claude Code** — Global instructions, plugins, and Obsidian Brain mind map (auto-detects vault per machine)

## Setup

```bash
git clone https://github.com/graffitiape/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

The install script will:
- Symlink all configs to their expected locations
- Back up any existing configs as `.bak`
- Install Oh My Zsh, Powerlevel10k, zsh-syntax-highlighting, and zsh-autosuggestions if missing
- Install MesloLG Nerd Font on macOS via Homebrew
- Detect Obsidian vault and configure Claude Code brain path + permissions

After running, set your terminal font to **MesloLGM Nerd Font** and restart your shell.

## Updating

Edit files directly in `~/dotfiles` — they're symlinked, so changes apply immediately. Then push:

```bash
cd ~/dotfiles
git add -A && git commit -m "update configs"
git push
```

On other machines, just `git pull` from `~/dotfiles`.
