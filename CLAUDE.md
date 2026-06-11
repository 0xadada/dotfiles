# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a macOS dotfiles repository that provisions a new Apple Macbook. It uses rsync to deploy configuration files from this repo to `$HOME`.

## Key Commands

- **Bootstrap/Install:** `./bootstrap.sh` — installs Homebrew, packages (via `Brewfile`), syncs dotfiles to `$HOME`, provisions Node.js/Volta, vim plugins, and macOS defaults
- **Sync dotfiles only:** The `sync` function in `bootstrap.sh` uses rsync to copy dotfiles to `$HOME`
- **macOS defaults:** `./.macos` — sets macOS system preferences
- **Lint shell scripts:** `shellcheck <file>` (shellcheck is in Brewfile)
- **CI:** GitHub Actions runs `shellcheck bootstrap.sh .macos` on push/PR

## Architecture

- **Shell configuration** loads in this order via `.bash_profile`:
  `.bash_prompt` → `.bash_exports` → `.bash_aliases` → `.bash_custom`
- **`.bash_custom`** is for machine-specific settings not committed to the repo
- **`.config/nvim/init.lua`** — single-file Neovim config using vim-plug, Mason (LSP installer), conform.nvim (formatting), nvim-lint, nvim-cmp (completion), and Telescope
- **`Brewfile`** — Homebrew bundle manifest (brews + casks)
- **`bin/`** — utility scripts deployed to `~/bin`
- **`iTerm/`** — iTerm2 color scheme (gruvbox-dark)
- **`Library/Application Support/iTerm2/`** — iTerm2 preferences

## Conventions

- Shell: Bash (not zsh). Homebrew bash is used as the default shell.
- Editor: Neovim (`nvim`). The git core editor is `nvim -f`.
- Node.js management: Volta (not nvm/fnm)
- Theme: Gruvbox dark (terminal, vim, airline)
- Git commits are GPG-signed by default
- The repo excludes `.git/`, `.github`, `.DS_Store`, `.macos`, `avatar.jpg`, `bootstrap.sh`, `Brewfile`, `iTerm/`, `README.md`, and `LICENSE` from rsync to `$HOME`
