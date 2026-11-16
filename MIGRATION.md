# Moving a machine to the containers layout

Temporary: delete this file once every machine is moved. This Mac (already
done) is the reference. Section 1 is the same as on `main`; skip it on machines
that already did it.

## 1. Every machine with an old checkout

Do this before pulling. `.profile.local` and friends are symlinks into the repo
today, holding your real values in skip-worktree files that the pull deletes.
Back the machine up first if you can.

First turn each link into a real, private file in `~`. This touches nothing in
the repo, stops at the first failure, and only prints the last line once none of
them is a link anymore:

```sh
bash -euo pipefail <<'EOF'
cd ~/dotfiles
for f in .profile.local .gitconfig.local .mpd/mpd.conf.local .mpdscribble/mpdscribble.conf; do
  [[ -L ~/"$f" ]] || continue
  (umask 077; cp ~/"$f" ~/"$f.new")
  mv -f ~/"$f.new" ~/"$f"
done
for f in .profile.local .gitconfig.local .mpd/mpd.conf.local .mpdscribble/mpdscribble.conf; do
  [[ ! -L ~/"$f" ]]
done
echo "Your local settings are real files in ~ now"
EOF
```

Only after that line prints, put the four tracked files back to their
templates, so the pull can delete them, and relink. Other edits in the checkout
are left alone:

```sh
bash -euo pipefail <<'EOF'
cd ~/dotfiles
tracked=(stowed-files/bash/.profile.local stowed-files/git/.gitconfig.local
  stowed-files/mpd/.mpd/mpd.conf.local stowed-files/mpd/.mpdscribble/mpdscribble.conf)
git update-index --no-skip-worktree "${tracked[@]}"
git checkout -- "${tracked[@]}"
git pull
if [[ "$(uname -s)" != Darwin ]]; then
  # Linux no longer stows the Mac-only packages. Only known files go, and the
  # directories only if empty, so a real ~/Music stays
  script/stow -D ghostty mpd rmpc
  rm -f ~/.mpd/mpd.conf.local ~/.mpdscribble/mpdscribble.conf ~/Music/.mpdignore
  rmdir ~/.mpd/playlists ~/.mpd ~/.mpdscribble ~/Music ~/.config/ghostty \
    ~/.config/rmpc/themes ~/.config/rmpc 2>/dev/null || true
fi
# Relink one file at a time; this unfolds the old directory links
script/stow -R
# Programs wrote some files into the repo through those old links (Neovim's
# plugin lockfile and spell files, ~/.ssh's known_hosts, keys and agent socket
# link), and stow just linked them back. Move each into place in ~
git ls-files --others -z stowed-files | while IFS= read -r -d '' f; do
  rel="${f#stowed-files/*/}"
  [[ -L ~/"$rel" ]] || continue
  rm ~/"$rel"
  mv "$f" ~/"$rel"
done
# Links left dangling by removed packages and scripts (epy, prettier, ...)
find ~ -maxdepth 5 -lname '*dotfiles/stowed-files*' ! -exec test -e {} \; -exec rm -v {} + 2>/dev/null || true
# And folders that deleted packages left in the repo once their files moved out
find stowed-files -type d -empty -delete
EOF
```

Check that a new login shell still has your settings, for example
`bash -lc 'echo $DEFAULT_USERNAME'`.

## 2. Mac

```sh
script/setup
```

That installs the new formulae and casks (`claude-code`, `codex`, the language
servers, `oxfmt`, `beets`, `container`). Then remove what moved or went away.
Homebrew doesn't uninstall dropped formulae, and old installs in `~/.local/bin`
shadow the new ones because it comes first on `PATH`:

```sh
brew uninstall rust docker docker-compose colima podman f2 difftastic cloudflared lua-language-server
# Old npm globals (codex, language servers, prettier, qmd, ...) and Corepack shims
rm -rf ~/.local/lib/node_modules
# Native Claude Code install (the cask replaces it; ~/.claude is untouched)
rm -f ~/.local/bin/claude && rm -rf ~/.local/share/claude
# Old uv tools and cargo installs
uv tool uninstall epy-reader pynvim pyright ruff streamdown vim-vint beets
rm -rf ~/.local/share/cargo
# Links left dangling by the removals above
find ~/.local/bin -type l ! -exec test -e {} \; -print -delete
```

Start Apple's container service once with `container system start`.

`mpd-sync` replaces `mpd-sync-playlists`, and also copies the server's beets
library for `play-albums`, so it no longer needs the media share or `BEETSDIR`.
It finds `beets.db` next to the music directory, which port 8090 doesn't
serve: switch `music_directory` in `~/.mpd/mpd.conf.local` to the server's
HTTPS address, restart MPD, and sync:

```sh
sed -i '' 's|^music_directory "http://\([^:]*\):8090/music/"|music_directory "https://\1/music/"|' ~/.mpd/mpd.conf.local
rm -f ~/.local/bin/mpd-sync-playlists
brew services restart mpd && mpd-sync
```

## 3. Debian hosts (homelab, Crostini)

First remove what moved to apt, became on-demand, or went away:

```sh
# GitHub binaries no longer installed on hosts (delta now comes from apt, codex
# from npm, which won't overwrite an existing binary; bun, agy and claude stay)
rm -f ~/.local/bin/{gemini-api,fx,yq,delta,difft,hugo,codex}
rm -rf ~/.local/share/lua-language-server
# Their .deb installs; keep cloudflared if the homelab uses it
sudo apt-get remove gh sad f2 hugo
# Dropped apt packages
sudo apt-get purge cargo python3-dev python3-pip python3-venv python3-virtualenv
sudo apt-get autoremove
# npm, uv and cargo globals (beets stays: the homelab imports with it)
rm -rf ~/.local/lib/node_modules ~/.local/share/cargo
uv tool uninstall epy-reader pynvim pyright ruff streamdown vim-vint
find ~/.local/bin -type l ! -exec test -e {} \; -print -delete
```

Then run setup, which installs the new pieces (`build-essential`, `git-delta`,
oxfmt from npm) after the cleanup above removed the old npm globals:

```sh
script/setup
```

For dev containers on the homelab, create the separate `dev` user (README,
Linux: Podman) and run `dev create` as them.

## 4. Coder devbox

Coder runs `~/figma/dotfiles/users/ffortes/install.sh` on every start, and its
`git pull --ff-only` fails while the skip-worktree files are there, so run step
1 once in the workspace, with `export DOTFILES_SKIP_PACKAGES=npm` first:
`~/.bashrc.local` sets it, but step 1's non-interactive shells don't read it,
so `script/stow -R` would otherwise link `~/.npmrc` (or conflict with the
image's). Then run `script/setup`, which adds the `fd` and `bat` links.

The matching `install.sh` changes are already made in `~/figma/dotfiles` but
not committed: its delta fallback checks for the real `~/.gitconfig.local` file
instead of a stow link, and the difftastic fallback is gone. Commit and push
those first.

## 5. Once, for agents

- For containers where agents run unattended, create the agent bot GitHub
  account and a classic `repo`-scope token for it (README, GitHub access), and
  set `DOTFILES_AGENT_BOT` in the Mac's `~/.profile.local`. Trusted containers
  can use a fine-grained token of your own instead.
- `dev create personal`, put the token (and, for the bot, its git identity) in
  `~/containers/personal/env`, then `dev personal` and sign in each agent
  (README, Signing in agents).
- Rotate the Linear API key that showed up in an agent session.
