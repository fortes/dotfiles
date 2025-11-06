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

## Issue Tracking with bd (beads)

**IMPORTANT**: This project uses **bd (beads)** for ALL issue tracking. Do NOT use markdown TODOs, task lists, or other tracking methods.

### Why bd?

- Dependency-aware: Track blockers and relationships between issues
- Git-friendly: Auto-syncs to JSONL for version control
- Agent-optimized: JSON output, ready work detection, discovered-from links
- Prevents duplicate tracking systems and confusion

### Quick Start

**Check for ready work:**
```bash
bd ready --json
```

**Create new issues:**
```bash
bd create "Issue title" -t bug|feature|task -p 0-4 --json
bd create "Issue title" -p 1 --deps discovered-from:bd-123 --json
```

**Claim and update:**
```bash
bd update bd-42 --status in_progress --json
bd update bd-42 --priority 1 --json
```

**Complete work:**
```bash
bd close bd-42 --reason "Completed" --json
```

### Issue Types

- `bug` - Something broken
- `feature` - New functionality
- `task` - Work item (tests, docs, refactoring)
- `epic` - Large feature with subtasks
- `chore` - Maintenance (dependencies, tooling)

### Priorities

- `0` - Critical (security, data loss, broken builds)
- `1` - High (major features, important bugs)
- `2` - Medium (default, nice-to-have)
- `3` - Low (polish, optimization)
- `4` - Backlog (future ideas)

### Workflow for AI Agents

1. **Check ready work**: `bd ready` shows unblocked issues
2. **Claim your task**: `bd update <id> --status in_progress`
3. **Work on it**: Implement, test, document
4. **Discover new work?** Create linked issue:
   - `bd create "Found bug" -p 1 --deps discovered-from:<parent-id>`
5. **Complete**: `bd close <id> --reason "Done"`
6. **Commit together**: Always commit the `.beads/issues.jsonl` file together with the code changes so issue state stays in sync with code state

### Auto-Sync

bd automatically syncs with git:
- Exports to `.beads/issues.jsonl` after changes (5s debounce)
- Imports from JSONL when newer (e.g., after `git pull`)
- No manual export/import needed!

### MCP Server (Recommended)

If using Claude or MCP-compatible clients, install the beads MCP server:

```bash
pip install beads-mcp
```

Add to MCP config (e.g., `~/.config/claude/config.json`):
```json
{
  "beads": {
    "command": "beads-mcp",
    "args": []
  }
}
```

Then use `mcp__beads__*` functions instead of CLI commands.

### Managing AI-Generated Planning Documents

AI assistants often create planning and design documents during development:
- PLAN.md, IMPLEMENTATION.md, ARCHITECTURE.md
- DESIGN.md, CODEBASE_SUMMARY.md, INTEGRATION_PLAN.md
- TESTING_GUIDE.md, TECHNICAL_DESIGN.md, and similar files

**Best Practice: Use a dedicated directory for these ephemeral files**

**Recommended approach:**
- Create a `history/` directory in the project root
- Store ALL AI-generated planning/design docs in `history/`
- Keep the repository root clean and focused on permanent project files
- Only access `history/` when explicitly asked to review past planning

**Example .gitignore entry (optional):**
```
# AI planning documents (ephemeral)
history/
```

**Benefits:**
- ✅ Clean repository root
- ✅ Clear separation between ephemeral and permanent documentation
- ✅ Easy to exclude from version control if desired
- ✅ Preserves planning history for archeological research
- ✅ Reduces noise when browsing the project

### Important Rules

- ✅ Use bd for ALL task tracking
- ✅ Always use `--json` flag for programmatic use
- ✅ Link discovered work with `discovered-from` dependencies
- ✅ Check `bd ready` before asking "what should I work on?"
- ✅ Store AI planning docs in `history/` directory
- ❌ Do NOT create markdown TODO lists
- ❌ Do NOT use external issue trackers
- ❌ Do NOT duplicate tracking systems
- ❌ Do NOT clutter repo root with planning documents

For more details, see README.md and QUICKSTART.md.
