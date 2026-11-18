# Testing the containers branch

Temporary: delete this file before merging. Test from the branch rather than
`main`, so the Coder devbox (which pulls `main` on every start) stays on the
current setup until the merge.

## Build the images locally

From `~/dotfiles` on the Mac, with the branch checked out:

```sh
container build --tag dotfiles .                     # dev image
container build --target host --tag dotfiles-host .  # fresh Debian server running script/setup
```

Until the branch is merged and CI publishes it, `ghcr.io/fortes/dotfiles:latest`
is still the old image, and it's what `dev create` uses by default. Pass
`dotfiles` as the image below.

## A fresh Debian host

```sh
container run --rm --interactive --tty dotfiles-host
```

A stock `debian:trixie` after a sudo user ran `script/setup`, deleted on exit.
Try `nvim` (give the first launch a minute to install plugins and build
parsers), `tmux`, `git log` (pages through delta), `beet --version`, the agents for quick questions (`claude --permission-mode plan`, `codex --sandbox read-only`, `agy --mode plan`), and
`ls -la ~` for the private `.local` copies.

## A throwaway dev container, no agents

```sh
container run --rm --interactive --tty dotfiles bash --login
```

Deleted on exit. Check the toolchain (`node`, `bun`, `pnpm`, `codex --version`,
`claude --version`, `agy --version`), then the same `nvim` and `tmux` checks.

## A dev container with agents

```sh
dev create agents-test dotfiles   # ~/containers/agents-test/{src,state,env}, private logins
dev agents-test                   # shell in /workspaces
```

Inside, sign in and run each agent. Logins stay in
`~/containers/agents-test/state`:

```sh
claude auth login
claude                # skips permission prompts in containers by default

codex login --device-auth
codex

agy                   # signs in on first run
```

Then `ssh dev-agents-test`: it should open the same shell (try `echo $CLAUDE_CONFIG_DIR`), with no port open. Also try an editor's Remote-SSH (VS Code, Zed) and the Claude and Codex apps' SSH support against `dev-agents-test`.

Things worth confirming: `agy` can sign in without a browser on the container,
and `claude`/`codex` still have their logins after
`dev recreate agents-test`.

### GitHub pushes as the bot

1. On the Mac, set `DOTFILES_AGENT_BOT` in `~/.profile.local` and run
   `new-github-repo fortes/throwaway-test`. If it fails at the ruleset step,
   rulesets on private repos need GitHub Pro.
2. Uncomment and fill in `GH_TOKEN` and the git identity in
   `~/containers/agents-test/env`. The next `dev agents-test` shell reads them.
3. In the container, run the two commands `new-github-repo` printed (accept the
   invite, clone), then push a branch and open a PR.
4. Approve and merge it on GitHub as yourself; pushing another commit should
   dismiss the approval.

### Published ports

```sh
dev create --publish 1313 site dotfiles
dev site   # then, inside: cd /tmp && python3 -m http.server 1313 --bind 0.0.0.0
```

Open `http://<Mac's LAN IP>:1313` from a phone on the same network. On the
homelab, the same with podman (`dev create --publish 1313 site` as the `dev`
user) is untested.

### Shared logins

```sh
dev create --shared-state shared-a dotfiles
dev create --shared-state shared-b dotfiles
```

Sign in once in `shared-a`; `shared-b` should already be signed in.

### OpenInfer

`dev create openinfer dotfiles`, paste the README's "Other model providers"
block into `~/containers/openinfer/env` with your key, then `dev openinfer` and
`claude`.

### Cleaning up

```sh
for c in agents-test shared-a shared-b openinfer; do dev rm "$c"; done
rm -rf ~/containers/.state   # only once you're done with the shared logins
```

## This Mac

Already done: the `.local` files are real private files in `~`, and
`script/stow -R` ran from the branch. Still to do:

1. `script/setup`, then the cleanup block in MIGRATION.md section 1.
2. `which claude codex bash-language-server` all point into `/opt/homebrew/bin`
   (old copies in `~/.local/bin` would shadow them).
3. Daily use: nvim on a note and on this repo (formatting, language servers),
   `git show` through delta, tmux, and `make test`.
4. The dev container steps above.

## Other machines

A machine that already ran an earlier version of this branch (like the Debian
VM) needs `rm ~/.local/bin/codex` once before `script/update`: Codex now comes
from npm, which won't overwrite the old GitHub binary.

Follow MIGRATION.md after `git fetch && git checkout containers`. Go from lowest
to highest stakes:

1. **Crostini** (no services). Migrate, `script/setup`, then a login shell,
   nvim on a note, and tmux.
2. **Homelab** (runs services), last:
   - Back up `~/dotfiles` and the `.local` files first.
   - After migrating and `script/setup`: `beet ls` (plugins load, library
     intact), SSH and Eternal Terminal still connect, tmux.
   - Containers: create the `dev` user and `sudo loginctl enable-linger dev`.
     As `dev`, clone the repo and run `script/stow` (not `script/setup`; it has
     no sudo), then `dev create scratch`. This is the first run of `dev`'s
     podman path.
3. **Coder devbox**: after the merge, per MIGRATION.md section 3.

## Rolling a machine back

Untested sketch. The new layout keeps your values in `~`, so going back to
`main` means moving them back into the repo:

```sh
git checkout main
for f in bash/.profile.local git/.gitconfig.local mpd/.mpd/mpd.conf.local mpd/.mpdscribble/mpdscribble.conf; do
  [ -f ~/"${f#*/}" ] && mv ~/"${f#*/}" "stowed-files/$f"
done
script/stow -R && script/lock_local_files
```
