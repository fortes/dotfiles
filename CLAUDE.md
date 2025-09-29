# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Personal dotfiles repository for managing development environment configuration across macOS, Debian Trixie (server/SSH), and Crostini (Chromebook). Heavily terminal-focused using Ghostty, Bash, Tmux, Neovim, and FZF/fd/ripgrep.

## Key Commands

### Initial Setup
```bash
# Clone and setup (works on macOS and Debian-like systems)
git clone https://github.com/fortes/dotfiles.git
./dotfiles/script/setup
```

### Common Operations
```bash
# Re-apply dotfile symlinks (safe to run multiple times)
./script/stow

# Platform-specific setup
./script/setup_mac           # macOS only
./script/setup_linux         # Debian-based systems only

# Install specific components
./script/install_node_packages
./script/install_python_packages
./script/install_llm_plugins
./script/install_yazi_plugins
./script/install_github_packages  # Installs fzf, hugo, neovim from GitHub releases
./script/install_vscode_extensions
./script/generate_completions

# Check health (currently a placeholder)
./script/check_health

# Ignore changes to a tracked file
git update-index --skip-worktree ./path/to/file
git update-index --no-skip-worktree ./path/to/file  # To undo
```

### Docker

**Build locally:**
```bash
docker build -t dotfiles .
```

**Direct usage (for SSH/tmux development):**
```bash
# Run container with shared src directory (maps ~/src to /workspaces in container)
docker run -it --rm --name dotfiles -v ~/src:/workspaces dotfiles

# In another terminal, attach to tmux session
docker exec -it dotfiles tmux attach

# Claude Code credentials persist in /workspaces/.claude-container (survives container restarts)
```

### Devcontainer

This repo includes a devcontainer configuration for use with VS Code, Cursor, and GitHub Codespaces.

**Using this repo as a devcontainer:**
- Open the repo in VS Code/Cursor and select "Reopen in Container"
- Or open in GitHub Codespaces for cloud development
- Your full terminal environment (bash, neovim, tmux, fzf, etc.) will be available
- Claude Code credentials are stored in `/workspaces/.claude-container` and persist
- First time: authenticate with `claude auth login` - credentials will be saved and reused
- Settings come from stowed `~/.claude/settings.json`

**Using as a base image for other projects:**

Published images are available at `ghcr.io/fortes/dotfiles` with tags:
- `latest` - Built from main branch
- `1.x.x` - Semantic version tags

Create a `.devcontainer/devcontainer.json` in your project (assuming it lives in `~/src/my-project`):
```json
{
  "name": "My Project",
  "image": "ghcr.io/fortes/dotfiles:latest",
  "workspaceFolder": "/workspaces/my-project",
  "mounts": [
    "source=${localEnv:HOME}/src,target=/workspaces,type=bind"
  ],
  "customizations": {
    "vscode": {
      "extensions": [
        "project-specific-extensions"
      ],
      "settings": {
        "project.specific": "settings"
      }
    }
  }
}
```

**Important notes for base image usage:**
- The container runs as user `fortes` (uid 1000) with your full dotfiles environment
- For local development: mount `~/src` to `/workspaces` and set `workspaceFolder` to your project path
- For GitHub Codespaces: no mounts needed, just use the default `/workspaces/<repo-name>`
- All your shell aliases, neovim config, tmux setup, etc. are pre-configured
- Add project-specific extensions and settings in the `customizations` section
- Claude Code credentials automatically persist in `/workspaces/.claude-container`

**Passing secrets/API keys to containers:**

Option 1 - From host environment variables:
```json
{
  "containerEnv": {
    "OPENAI_API_KEY": "${localEnv:OPENAI_API_KEY}",
  }
}
```
Set these in your host's `~/.profile.local` or `~/.bashrc.local`.

Option 2 - Using a `.env` file:
```json
{
  "runArgs": ["--env-file", ".env"]
}
```
Create `.env` at your project root with your secrets (add to `.gitignore`).

**Publishing new versions:**
- Push to `main` branch → publishes `latest` tag automatically
- Create a git tag like `v1.2.3` → publishes versioned images (`1.2.3`, `1.2`, `1`)
- Multi-platform images support both amd64 and arm64

## Architecture

### Configuration Management with GNU Stow

All user configuration files live in `stowed-files/` and are symlinked to `$HOME` using GNU Stow. Each subdirectory represents a "package" that can be independently stowed:

```
stowed-files/
├── bash/          # Shell config (.bashrc, .profile, .aliases, etc.)
├── nvim/          # Neovim config (init.lua + legacy .vimrc)
├── git/           # Git configuration
├── tmux/          # Tmux configuration
├── ghostty/       # Ghostty terminal emulator config
├── yazi/          # File manager config
├── Code/          # VS Code settings
├── mozilla/       # Firefox user.js (with special stowing logic)
└── [38 other packages]
```

The `script/stow` wrapper handles:
- Stowing all packages to `$HOME`
- Special case for Firefox profiles (dynamically finds `*.default*` dirs)
- Uses `.stow-local-ignore` files to prevent certain files from being stowed

### Shell Configuration Flow

1. **`.profile`** - Non-interactive setup, always loaded first
   - Defines helper functions: `add_to_path()`, `source_if_exists()`, `command_exists()`
   - Sets `$EDITOR` and `$VISUAL` (prefers Neovim)
   - Loads Homebrew environment (macOS)
   - Sets up fnm for Node version management
   - Configures environment variables

2. **`.bashrc`** - Interactive shell setup
   - Sources `.profile` first to ensure it's loaded
   - Sets history options (unlimited history)
   - Configures bash options (globstar, autocd, etc.)
   - Sets up prompt with git branch info
   - Loads completions and aliases

3. **`.aliases`** - Command aliases and shortcuts

4. **`.profile.local`** / **`.bashrc.local`** - Machine-specific overrides (not in repo)

### Neovim Configuration

- **`init.lua`** - Main Neovim config, sources legacy `.vimrc`
- Uses `lazy.nvim` for plugin management
- LSP setup with special handling for:
  - `denols` - Only in projects with `deno.json`/`deno.jsonc`
  - `eslint` - Disabled in Deno projects
  - Default Neovim 0.11+ LSP keymaps enabled (`grn`, `grr`, `gri`, `gO`, `gra`)
- Diagnostic configuration with virtual text/lines

### Platform Detection

Scripts detect the environment via:
- `IS_HEADLESS` - No GUI packages
- `IS_DOCKER` - Running in Docker
- `IS_CROSTINI` - Chromebook Linux container
- Platform check: `uname -s` for macOS vs Linux

### Setup Script Flow

**macOS** (`setup_mac`):
1. Install Xcode Command Line Tools
2. Install Homebrew
3. Install brew packages (bash, neovim, fzf, etc.)
4. Install casks (1Password, Firefox, VS Code, Ghostty, etc.)
5. Run `script/stow` to symlink dotfiles
6. Change shell to Homebrew bash
7. Install non-brew packages (Node, Python, llm plugins, yazi plugins)
8. Generate shell completions

**Linux** (`setup_linux`):
1. Check prerequisites (apt-get, lsb-release)
2. Set up non-free repos and backports
3. Install apt packages (headless or GUI set)
4. Install 1Password CLI, Firefox, et, snap packages, GitHub releases
5. Run `script/stow` to symlink dotfiles
6. Configure system (keyboard, locale, Docker group, max watchers)
7. Install non-apt packages (Node, Python, llm plugins, yazi plugins)
8. Generate shell completions

**Debian Sources**: Trixie moved to new deb822 format in `/etc/apt/sources.list.d/debian.sources`

### File Locking

`script/lock_local_files` uses `git update-index --skip-worktree` on `.local` files to prevent accidental commits of machine-specific config.

## Important Notes

- The `script/setup` dispatcher auto-detects macOS vs Debian systems
- Backports must be manually specified when installing (e.g., `sudo apt install -t trixie-backports <package>`)
- Firefox cask updates via Homebrew are currently broken; manual updates required
- WSL2 and Linux GUI (Sway/i3) support was removed but exists in git history
- Docker Mac has issues with `/etc/sysctl.d` configuration