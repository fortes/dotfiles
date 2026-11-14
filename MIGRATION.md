# Moving a machine to the containers layout

Temporary: delete this file once every machine is moved. This Mac (already
done) is the reference.

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
# Relink one file at a time; this unfolds the old directory links
script/stow -R
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
brew uninstall rust bun docker docker-compose colima podman f2 difftastic cloudflared
# Old npm globals (codex, language servers, prettier, qmd, ...) and Corepack shims
rm -rf ~/.local/lib/node_modules
# Native Claude Code install (the cask replaces it; ~/.claude is untouched)
rm -f ~/.local/bin/claude && rm -rf ~/.local/share/claude
# Old uv tools and cargo installs
uv tool uninstall epy-reader pynvim pyright ruff streamdown beets
rm -rf ~/.local/share/cargo
# Links left dangling by the removals above
find ~/.local/bin -type l ! -exec test -e {} \; -print -delete
```

Start Apple's container service once with `container system start`.

## 3. Debian hosts (homelab, Crostini)

```sh
script/setup
```

That adds `build-essential` and `git-delta` from apt. Then remove what moved to
apt, became on-demand, or went away:

```sh
# GitHub binaries no longer installed on hosts (delta now comes from apt)
# (codex, agy and claude stay: hosts keep them for quick questions)
rm -f ~/.local/bin/{bun,bunx,gemini-api,fx,yq,delta,difft,hugo}
rm -rf ~/.local/share/lua-language-server
# Their .deb installs; keep cloudflared if the homelab uses it
sudo apt-get remove gh sad f2 hugo
# Dropped apt packages
sudo apt-get purge cargo python3-dev python3-pip python3-venv python3-virtualenv
sudo apt-get autoremove
# npm, uv and cargo globals (beets stays: the homelab imports with it)
rm -rf ~/.local/lib/node_modules ~/.local/share/cargo
uv tool uninstall epy-reader pynvim pyright ruff streamdown
find ~/.local/bin -type l ! -exec test -e {} \; -print -delete
```

For dev containers on the homelab, create the separate `dev` user (README,
Linux: Podman) and run `dev create` as them.

## 4. Coder devbox

Coder runs `~/figma/dotfiles/users/ffortes/install.sh` on every start, and its
`git pull --ff-only` fails while the skip-worktree files are there, so run step
1 once in the workspace. The matching `install.sh` changes are already made in
`~/figma/dotfiles` but not committed: its delta fallback checks for the real
`~/.gitconfig.local` file instead of a stow link, the difftastic fallback is
gone, and it skips the `mpd` and `rmpc` packages. Commit and push those first.

## 5. Once, for agents

- Create the agent bot GitHub account and a classic `repo`-scope token for it
  (README, Agent GitHub access). Set `DOTFILES_AGENT_BOT` in the Mac's
  `~/.profile.local`.
- `dev create personal`, put the bot's token and git identity in
  `~/containers/personal/env`, then `dev personal` and sign in each agent
  (README, Signing in agents).
- Rotate the Linear API key that showed up in an agent session.
