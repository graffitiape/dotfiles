# dotfiles

My personal shell config plus submodule links to standalone editor, terminal, tmux, and AI brain repos.

## What's included

- **Zsh** — Oh My Zsh + Powerlevel10k (minimal style, Catppuccin Macchiato colors)
- **Neovim** — `graffitiape/nvim` submodule
- **Tmux** — `graffitiape/tmux` submodule
- **Ghostty** — `graffitiape/ghostty-config` submodule
- **Brain** — `graffitiape/brain` submodule for Claude Code, Codex, and shared Obsidian Brain setup

## Setup

```bash
git clone --recurse-submodules https://github.com/graffitiape/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

The install script will:
- Symlink all configs to their expected locations
- Back up any existing configs as `.bak`
- Initialize/update submodules
- Install Oh My Zsh, Powerlevel10k, zsh-syntax-highlighting, and zsh-autosuggestions if missing
- Install MesloLG Nerd Font on macOS via Homebrew
- Delegate Claude Code and Codex setup to the `brain` submodule

After running, set your terminal font to **MesloLGM Nerd Font** and restart your shell.

## Updating

Edit shell files directly in `~/dotfiles`. Edit submodule-owned configs inside their submodule directories, then commit both the submodule repo and the parent pointer:

```bash
cd ~/dotfiles

cd .config/nvim
git add -A && git commit -m "chore: update nvim config"
git push

cd ../..
git add .config/nvim
git commit -m "chore: update nvim submodule"
git push
```

On other machines:

```bash
cd ~/dotfiles
git pull
git submodule update --init --recursive
```
