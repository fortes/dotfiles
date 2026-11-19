# Repository Overview

Personal dotfiles for macOS, Debian Trixie (headless servers, Docker image), Ubuntu devboxes and Crostini. Terminal-focused: Ghostty, Bash, tmux, Neovim, fzf/fd/ripgrep. See README.md for user-facing setup and container usage.

## Commands

```bash
./script/setup    # Provision the platform, stow dotfiles, then run script/update
./script/stow     # Relink dotfiles only (-n dry run, -v verbose, -D/-R)
./script/update   # Install/update user tools; OS packages stay with apt/brew
./script/doctor   # Check the machine against what setup does; changes nothing
make test         # shellcheck + shfmt (also what CI runs)
```

`script/setup` runs `setup_mac`, `setup_linux` (Debian), or `dev/setup_devbox` (Ubuntu or `DOTFILES_DEVBOX=1`: a light, run-on-every-boot subset that leaves system config alone).

## Where things go

- **macOS packages:** `BREW_PACKAGES` / `CASK_PACKAGES` in `script/setup_mac`
- **Debian packages:** `script/apt-packages.txt` (backports when stable is too old), shared by hosts and the image; mark host-only lines `# host-only`. Third-party apt repos get their own `script/install_*`
- **Host tools beyond brew/apt:** the short lists in `script/update`, only for tools used outside code (shell, notes, music, and the agent CLIs for quick questions), so a bad release can't reach host credentials. A few trusted npm globals are fine there (like oxfmt); prefer npm over GitHub releases when a package needs no install scripts, since npm installs get the release cooldown. `script/install_github_packages <name>` and `script/install_docker` cover on-demand installs.
- **Dev environments (opt-in):** `script/dev/`: `setup_container` (what the image adds, including its `/etc` settings: the agents' permission defaults and the `dev-sshd` wrapper for `ssh dev-<name>`), `setup_devbox`, `project-template/`; `dev` (with its completion) and `new-github-repo` live in `stowed-files/bin`. Project dependencies go in a project Dockerfile `FROM ghcr.io/fortes/dotfiles`, not here.
- **Config files:** `stowed-files/<package>/`, mirroring `$HOME`. Each directory is a stow package; `DOTFILES_SKIP_PACKAGES` (space-separated) skips some. `script/stow` links files one by one (`--no-folding`), so directories in `$HOME` stay real and programs never write into the repo.
- **Machine-specific settings:** templates in `local-templates/<package>/` (`.profile.local`, `.gitconfig.local`, MPD's server and mpdscribble's credentials), copied into `$HOME` as private untracked files when that package is stowed and the file is missing. Mark what each machine must fill in (hosts, usernames, secrets) with `REPLACE_ME` so it's greppable. `~/.bashrc.local` and `~/.vimrc.local` are untracked.

Shell startup: `.profile` (environment, PATH, helpers, `IS_DOCKER`; sources `.profile.local` last) → `.bashrc` (interactive; sources `.profile`) → `.aliases`.

Neovim: `init.lua` sources `~/.vimrc`; Neovim 0.12+ loads plugins with the built-in `vim.pack`, while older versions use the base Vim config.
The Obsidian vault is `$NOTES_DIR` (default `~/notes`); `notes` in `.aliases` opens it.

## Conventions

- **Keep it simple.** Scripts are idempotent, so a loud failure plus a rerun is the recovery plan. Don't add retries, traps, fallbacks, marker files or migration code for rare cases. A one-time manual step is fine.
- **Comments:** Explain surprising behavior or constraints; skip comments that only restate the next line.
- **Long options:** Spell out flags whose short form isn't widely known (`fzf --exit-0`, `shfmt --case-indent`) instead of commenting them. Idioms like `grep -v`, `mkdir -p` and `curl -fsSL` stay short, as do flags in macOS-facing code where the BSD tool has no long form (`xargs`, `cut`).
- **No test harnesses.** `make test`, the Docker image build and running setup on the Mac are the tests.
- **CI cost:** `.github/workflows/bash-syntax.yml` has narrow path triggers, and the Docker image build chains off it. Don't widen the triggers; add directories to its sparse checkout instead.
- **Linux-only code:** Scripts only the image runs can assume GNU/Linux. Host scripts and shell config still have to work on macOS.
- **Bash 3.2:** `setup_mac`, `script/stow`, `script/lib.sh` and `script/doctor` can run under macOS's `/bin/bash` before Homebrew bash exists, and so does `dev` when SSH starts `dev proxy` for an app launched from the Dock. Avoid Bash 4 features and GNU-only flags there.
- **`~/.vimrc` stays self-contained.** It's also used via `nvim -u ~/.vimrc` and copied to servers, so it must load without errors on distro Vim/Neovim and `vim.tiny`.
- Use `uname -s` for macOS vs Linux, `IS_DOCKER` for containers, and `DOTFILES_DEV_IMAGE` for the dev image.
