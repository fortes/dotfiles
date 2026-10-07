# Repository Overview

Personal dotfiles for macOS, Debian Trixie (headless servers, Docker image), Ubuntu devboxes and Crostini. Terminal-focused: Ghostty, Bash, tmux, Neovim, fzf/fd/ripgrep. See README.md for user-facing setup and container usage.

## Commands

```bash
./script/setup    # Provision the platform, stow dotfiles, then run script/update
./script/stow     # Relink dotfiles only (-n dry run, -v verbose, -D/-R)
./script/update   # Install/update user tools; OS packages stay with apt/brew
make test         # shellcheck + shfmt (also what CI runs)
```

`script/setup` runs `setup_mac`, `setup_linux` (Debian), or `setup_devbox` (Ubuntu, or `DOTFILES_DEVBOX=1`). `setup_devbox` is a light, run-on-every-boot subset that leaves system config alone.

## Where things go

- **macOS packages:** `BREW_PACKAGES` / `CASK_PACKAGES` in `script/setup_mac`
- **Debian packages:** `script/apt-packages.txt`; third-party apt repos get their own `script/install_*`
- **Binaries missing or too old in Debian:** Either use backports or via `script/install_github_packages`
- **npm / uv / cargo globals:** `script/install_{node,python,cargo}_packages`
- **Config files:** `stowed-files/<package>/`, mirroring `$HOME`. Each directory is a stow package; `DOTFILES_SKIP_PACKAGES` (space-separated) skips some. Directories programs write into (`REAL_DIRS` in `script/stow`, e.g. `~/.ssh`) are created first so stow doesn't fold them into the repo.
- **Machine-specific settings:** tracked `*.local` templates (`.profile.local`, `.gitconfig.local`) are stowed and marked skip-worktree by `script/lock_local_files`, so per-machine edits stay out of git. `~/.bashrc.local` and `~/.vimrc.local` are untracked.

Shell startup: `.profile` (environment, PATH, helpers, `IS_DOCKER`; sources `.profile.local` last) → `.bashrc` (interactive; sources `.profile`) → `.aliases`.

Neovim: `init.lua` sources `~/.vimrc`, and plugins use the built-in `vim.pack`.

## Conventions

- **Keep it simple.** Scripts are idempotent, so a loud failure plus a rerun is the recovery plan. Don't add retries, traps, fallbacks, marker files or migration code for rare cases. A one-time manual step is fine.
- **No test harnesses.** `make test`, the Docker image build and running setup on the Mac are the tests.
- **CI cost:** `.github/workflows/bash-syntax.yml` has narrow path triggers, and the Docker image build chains off it. Don't widen the triggers; add directories to its sparse checkout instead.
- **Bash 3.2:** `setup_mac` and `script/lib.sh` run under macOS's `/bin/bash` before Homebrew bash exists, so avoid Bash 4 features and GNU-only flags there.
- **`~/.vimrc` stays self-contained.** It's also used via `nvim -u ~/.vimrc` and copied to servers, so it must load without errors on distro Vim/Neovim and `vim.tiny`.
- Use `uname -s` for macOS vs Linux and `IS_DOCKER` for containers.
