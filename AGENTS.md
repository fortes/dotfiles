# Repository Overview

Personal dotfiles repository for managing development environment configuration across macOS, Debian Trixie (server/SSH), and Crostini (Chromebook). Heavily terminal-focused using Ghostty, Bash, Tmux, Neovim, and FZF/fd/ripgrep.

## Key Commands

### Installation

```bash
# Clone and setup (works on macOS and Debian-like systems)
git clone https://github.com/fortes/dotfiles.git
./dotfiles/script/setup
```

### Common Operations
```bash
# Run all steps (idempotent)
./script/setup

# (Debian-only) Update packages installed from GitHub
./script/install_github_packages [package-name ...]

# Update node packages
./script/install_node_packages

# Update python packages
./script/install_python_packages

# Re-link dotfiles when new ones are added
./script/stow

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

## Architecture

### Package Installation

#### MacOS

Package installation is generally all done via homebrew in `script/setup_mac`

#### Debian

Three installation methods:

* Debian-distributed packages via `apt-get` in `script/setup_linux` (including backports)
* Apt packages from third-party repos (1Password, etc.)
* Packages installed from GitHub releases via `script/install_github_packages`. This is used for either packages that aren't in Debian repos or where the Debian version is too old (e.g., `neovim`)

### Configuration with GNU Stow

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
