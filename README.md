# Dotfiles

This is only public so I can easily share it across machines. There is probably nothing of interest for you here ... or is there?

My usage is mostly terminal-based on MacOS, Debian Trixie over SSH, or sometimes Crostini (Debian) on Chromebook. Making heavy use of:

- Ghostty
- bash / tmux
- Neovim
- fzf / fd / ripgrep
- MPD with rmpc

## Letting me own your machine

```sh
git clone https://github.com/fortes/dotfiles.git
./dotfiles/script/setup
```

A fresh Debian install (netinst, Crostini) has no `git`: run `sudo apt-get update && sudo apt-get install --yes git` first.

On Ubuntu (22.04 or later, which Coder devboxes and most devcontainers use), `script/setup` runs a lighter setup instead that only installs a few packages and links dotfiles, and is safe to run on every boot (requires root or sudo access). For the same on other pre-provisioned machines, like a Debian 13 (Trixie) devcontainer:

```sh
DOTFILES_DEVBOX=1 ./dotfiles/script/setup
```

Devbox setup never upgrades its GitHub binaries or npm language servers; run `script/update` for that, with the same `DOTFILES_DEVBOX=1` (or export it in `~/.profile.local`).

Set `DOTFILES_SKIP_PACKAGES="bash ssh"` (for example) to leave stow packages alone, like `bash` to keep machine-provided shell startup files. Stowing `bash` backs up existing shell files, including `.hushlogin`, before linking them.

## Setup and updates

| Command | Behavior |
| --- | --- |
| `script/setup` | Provision the platform, install/update tools, and link configuration. |
| `script/stow` | Relink configuration without package installs. |
| `script/update` | Update user tools, not OS config; in the image, also `script/dev/setup_container`. |
| `script/doctor` | Check this machine (or dev container) against what setup does, and say how to fix what doesn't. Changes nothing. |

On Linux, some GitHub binaries aren't installed by default, like cloudflared, difftastic and hugo. Install them when needed with `script/install_github_packages <name>`; `--help` lists them all. Likewise, `script/install_docker` sets up Docker on Debian when a project needs it (use `sudo docker`, since it skips the docker group).

Run `make test` for shell checks; see [Building locally](#building-locally) for image builds.

## Post-Setup

Once you've run setup, you'll still have to do the following universal manual steps (see platform-specific sections for more):

1. Generate the machine's SSH keys via 1Password, then add the key into GitHub and wherever else

2. Add any additional ssh keys into `~/.ssh`

3. If it's a server, may want to authorize your other public keys on the new machine:

   ```sh
   ssh-import-id gh:fortes
   ```

4. Add your favorite servers into `.ssh/config.local`

5. Adjust `~/.gitconfig.local`, e.g. per-directory config:

   ```
   [includeIf "gitdir:~/src/company/"]
     path = ~/.gitconfig.company
   ```

6. Fill in the placeholders in your copies of the templates (see [Machine-specific settings](#machine-specific-settings)), for the parts you use:

   ```sh
   rg -l REPLACE_ME ~/.profile.local ~/.gitconfig.local ~/.mpd/mpd.conf.local ~/.mpdscribble/mpdscribble.conf
   ```

7. On the Mac, log into the GitHub CLI (`gh auth login`) and launch `claude` and `codex` (and `agy`, if installed) once each to sign in. Containers sign in separately (see [Signing in agents](#signing-in-agents)).

## Stale links

When a file is deleted from the repo, `script/stow` (and so `script/setup`) removes the link it left in `$HOME`: any link into `stowed-files` whose file is gone, in `~` and the folders packages link into.

## Machine-specific settings

Per-machine settings and secrets live in real files in your home directory, which git never sees: `~/.profile.local`, `~/.gitconfig.local`, `~/.mpd/mpd.conf.local` and `~/.mpdscribble/mpdscribble.conf`. `script/stow` copies each one from `local-templates/<package>/` the first time, private to you, and never overwrites it. Fill in its `REPLACE_ME`s afterwards. To pick up later template changes, compare by hand:

```sh
diff ~/.profile.local local-templates/bash/.profile.local
```

`~/.bashrc.local`, `~/.vimrc.local` and `~/.ssh/config.local` are yours to create; nothing copies them.

## Apps and platforms

### Neovim

The very first `nvim` launch on a new machine installs the plugins itself:
`vim.pack.add()` prompts to confirm, then downloads them and compiles the
treesitter parsers (which blocks for a minute or two, with progress). They are
usable straight away, but anything that already ran during that startup won't
pick them up — the file you opened has had its `FileType` autocmds fire before
any parser existed — so `:restart` once it finishes.

Afterwards, to update plugins, rebuild native components (the fzf sorter) and
refresh parsers:

```vim
:lua vim.pack.update()
" Must do `:write` to accept the updates, then `:restart`
```

Re-run this command whenever you pull updates that add or change plugins.

Dropping a plugin from `init.lua` stops it loading but leaves it on disk. To
clean those up:

```vim
:lua vim.pack.del(vim.iter(vim.pack.get()):filter(function(p) return not p.active end):map(function(p) return p.spec.name end):totable())
```

### Firefox

- Log into sync accounts, extensions should automatically install
- Configure uBlock Origin
  - Enable in private mode
  - Enable cloud storage mode. Should do the following for you, but doesn't always work:
    - Enable annoyances filters
    - Add [Bypass paywalls clean filter](https://gitflic.ru/project/magnolia1234/bypass-paywalls-clean-filters) by copy-pasting the contents

### Chrome

- Log into sync accounts, extensions should automatically install
- Log into 1Password extension

### Mac

- Set up Touch ID, Apple account if required
- Remove all the junk from the dock
- Enable _Night Shift_ and set to _Sunset to Sunrise_
- Turn off Natural Scrolling
- Increase keyboard repeat rate to max, delay to minimum
- Change Globe key to Control dictation
- Disable iCloud syncing of all but Find My Mac & Safari
- Set `terminal.app` profile, send option as meta key
- May want to install command line tools manually in order to get `git`: `xcode-select --install`
- Run `script/setup`
- Install apps by hand. They update themselves, which leaves Homebrew's casks stale, so setup skips them. Skip any that MDM already installed:

  ```sh
  brew install --cask 1password chatgpt claude firefox ghostty google-chrome obsidian raycast
  # Optional
  brew install --cask antigravity antigravity-cli
  # Personal machines
  brew install --cask plexamp signal
  ```
- Make sure keys repeat properly in apps that disable it by default:
  - Antigravity: `defaults write com.google.antigravity ApplePressAndHoldEnabled -bool false`
  - Obsidian: `defaults write md.obsidian ApplePressAndHoldEnabled -bool false`
  - For other apps that have this issue, do the following:
    ```sh
    # Get the app id
    osascript -e 'id of app "Cursor"'
    # Outputs something like `com.todesktop.xxxxx`
    defaults write com.todesktop.xxxxx ApplePressAndHoldEnabled -bool false
    ```
- `terminal.app` sucks with colors, switch to Ghostty and pin it in the dock
- In Raycast's Window Management settings, switch to the Rectangle-style hotkeys and turn on cycling through displays
- Install the 1Password extension in Safari (others should sync automatically)
- Start Apple's container service with `container system start`; the first run downloads a Linux kernel (see [Containers](#containers)).

- If gaming, install battle.net/Steam via brew:

  ```sh
  # May require this first in order to run Battle.net
  # (Steam has a beta that doesn't require Rosetta)
  softwareupdate --install-rosetta --agree-to-license

  brew install --cask battle-net steam
  # For battle.net, will need to manually run setup to install the app
  # open /opt/homebrew/Caskroom/battle-net/VERSION/Battle.net-Setup.app
  ```
- Log into PlexAmp, and set `music-decoy` to open it with the play button:

  ```sh
  defaults write com.lowtechguys.MusicDecoy mediaAppPath /Applications/Plexamp.app
  ```
- Optionally, to browse the server's music in Finder, automount the media share at a fixed path (MPD and `play-albums` don't need it). Unlike Finder mounts, it remounts on access and doesn't litter `/Volumes`. macOS upgrades may reset `/etc/auto_master`; re-run the first command if so. Use the share's read-only login; guest access fails with the misleading "No locks available" (errno 77, an SMB auth error):

  ```sh
  echo '/-    auto_smb    -nosuid,nobrowse' | sudo tee -a /etc/auto_master
  echo '/System/Volumes/Data/mnt/media  -fstype=smbfs,soft,ro,filemode=0644,dirmode=0755  ://media:REPLACE_ME@REPLACE_ME/media' | sudo tee /etc/auto_smb
  sudo automount -cv
  ln -s /System/Volumes/Data/mnt/media/music ~/Music/SERVER
  ```
- Start MPD, which plays here using the server's library, then use `rmpc` or `play-albums`. Set the server's address in `~/.mpd/mpd.conf.local`, replacing `REPLACE_ME`; it's the one place the scripts read it from too. MPD needs System Settings → Privacy & Security → Local Network access to reach the server, otherwise it fails with "No route to host". Homebrew upgrades may ask again:

  ```sh
  brew services start mpd
  ```
- Copy the server's playlists and beets library to this Mac. The proxy database doesn't share playlists, so this puts its `.m3u` files in `~/.mpd/playlists` for rmpc's Playlists tab; beets (`play-albums`, or `beet` itself) uses the library copy in `BEETSDIR`, which `~/.profile` sets to `~/.mpd/beets`, offline too. The library only downloads when the server's is newer. Rerun after the server regenerates them. Large playlists load slowly, since MPD looks up each song on the server:

  ```sh
  mpd-sync
  ```
- Load the Raycast extension in `src/raycast`, whose Play Albums command searches the same beets library: Enter replaces the queue with an album, ⌘↵ adds it to the end. Raycast keeps it after `npm run dev` exits (Ctrl-C); rerun that after changing it:

  ```sh
  cd ~/dotfiles/src/raycast && npm ci && npm run dev
  ```
- Offline, `mpd-offline on` swaps MPD to the albums synced from the server into `~/Music/albums`, with its own queue; `mpd-offline off` goes back to the server's library. Only local albums play, from rmpc, playlists or `play-albums`. Scrobbles wait in mpdscribble's journal until the network returns. Offline mode doesn't survive a reboot: run `mpd-offline on` again, or `mpd-offline off` to go back.
- Scrobble MPD plays to Libre.fm and ListenBrainz: fill in the `REPLACE_ME`s in `~/.mpdscribble/mpdscribble.conf` (a private copy of the template, outside git), then start it:

  ```sh
  brew services start mpdscribble
  ```
- Media keys and Control Centre's Now Playing control MPD through `mpd-now-playable`. Setup writes its LaunchAgent; start it once and it runs at login after that:

  ```sh
  launchctl bootstrap "gui/$(id -u)" ~/Library/LaunchAgents/local.mpd-now-playable.plist
  ```

### Debian Server / Crostini

- For servers, make sure to set up [email delivery](https://fortes.com/2020/getting-debian-to-send-emails-that-actually-get-delivered/)
- Setup installs `unattended-upgrades` for automatic security updates; `sudo dpkg-reconfigure unattended-upgrades` to check or change it
- You may need to install `avahi-daemon`, `avahi-dnsconfd`, `avahi-utils`, and `libnss-mdns` to get `.local` hostnames to resolve properly
- `mergerfs` if you want to do any pooling of drives
- `cifs-utils` may also be useful to have installed for mounting Windows shares

### Chromebook

- All the steps from `Chrome` section above
- Set up "Night Light" if it didn't automatically sync
- Enable Linux, choose a larger disk size (20GB fine?). Double check which debian version it is via `grep VERSION_CODENAME /etc/os-release` (should be `trixie`)
- Install git, which the image lacks, then clone the repo and run `script/setup` (skips podman: Crostini is already a container). Setup also adds Debian's security and stable-update sources, which ChromeOS's image ships without:

  ```sh
  sudo apt-get update && sudo apt-get install --yes git
  git clone https://github.com/fortes/dotfiles.git ~/dotfiles && ~/dotfiles/script/setup
  ```
- Share `Downloads` folder with Linux, then symlink via `ln -s /mnt/chromeos/MyFiles/Downloads ~/downloads`
- Change terminal font by going to `chrome-untrusted://terminal/html/nassh_preferences_editor.html`
  - Add `'DejaVu Sans Mono Nerd'` to the beginning of "Text Font Family"
  - Add the following to custom CSS:
    ```css
    @font-face {
      font-family: 'DejaVu Sans Mono Nerd';
      src: url(https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/patched-fonts/DejaVuSansMono/Regular/DejaVuSansMNerdFontMono-Regular.ttf);
      font-weight: normal;
      font-style: normal;
    }
    ```

### Containers

Coding and unattended agents run in containers. Hosts (macOS, Debian servers, Crostini) get Homebrew or apt packages plus the short lists in `script/update`; hosts also keep Claude Code, Codex and agy for quick questions (plus a few language servers and the oxfmt formatter, for notes and config files), with their own prompts and sandboxes. The image adds the coding toolchain with `script/dev/setup_container`. That way a compromised package release, or an agent running with `--dangerously-skip-permissions`, only reaches what one container holds.

What keeps that boundary intact:

- **One container per trust group, not per project.** Projects that share a token can share a container. Clone untrusted repos into a throwaway container with no token.
- **Each repo lives on one side.** Clone a container's repos into its `src` and do their git work inside it. Running host git in a checkout a container wrote can run that checkout's `.git/hooks` or `core.fsmonitor` on the host.
- **Mount only the container's `src` and its state,** never `~` or all of `~/src`.
- **Agents have passwordless sudo inside,** so they can install whatever a project needs. Treat everything in a container as theirs: the protections are what it's given (mounts, `env`, tokens), not restrictions inside it.
- **Logins live in each container's own `state`,** mounted at `/state` (`CLAUDE_CONFIG_DIR`, `CODEX_HOME`, `GH_CONFIG_DIR`, plus links for agy), so they survive image upgrades and the projects can't see them, though anything running in the container can. `dev create --shared-state` links it to `~/containers/.state` instead, shared by every container created that way: one sign-in, but each of them can read the others' logins. Keep untrusted repos out of the shared ones. GitHub comes from a `gh auth login` there (shared the same way) or a `GH_TOKEN` in the container's `env`, which overrides it.

To switch an existing container between its own logins and the shared ones (`dev recreate` keeps whichever it has):

```sh
cd ~/containers/<name>
# To shared: optionally copy its logins in first (same-named files get overwritten)
cp -a state/. ../.state/ && rm -rf state && ln -s ../.state state
# Or back to its own: drops only the link, then sign in again inside
rm state && mkdir -m 700 state
dev recreate <name>
```

#### Using containers

`dev` (in `~/.local/bin`) wraps Apple's `container` on macOS and podman elsewhere:

```sh
dev create personal   # ~/containers/personal/{src,state,env} and the container
dev personal          # Login shell in /workspaces, starting the container if needed
dev list              # Your containers: running or stopped, image and ports (or just `dev`)
dev stop personal     # Stop it, keeping everything (or --all); dev personal restarts it
dev rm personal       # Delete it and ~/containers/personal, after you type its name
```

Run `dev` from a host tmux window rather than nesting tmux. Pass an image as the last argument to use a project's own, e.g. `dev create new-project new-project`.

`ssh dev-<name>` opens a shell in the container over SSH, starting in your home folder there, for editors and apps that work on remote machines (VS Code or Cursor Remote-SSH, Zed, and any other that reads `~/.ssh/config`). The stowed SSH config sends it through `dev proxy`, which runs the container's `sshd` over the runtime's exec instead of the network, so no port is open. Connections use a key of their own, `~/containers/.ssh/client_ed25519`, which `dev` makes once without a passphrase: it only opens your containers, which your account can enter with `dev` anyway, so editors and apps connect without your agent, 1Password, Keychain or askpass. The same folder has the one host key all of this machine's containers use. Your agent is never forwarded. SSH sessions get the container's environment and `env` file like `dev <name>` does. Containers made before SSH access need one `dev recreate <name>`.

Each container gets a random port of its own (20000–29999), served on the same number on every interface of the host and kept across recreates, so a dev server is reachable from the Mac and other machines on the LAN (a phone, another laptop) with no setup: inside, `PORT` holds it and `DEV_URL` the address to open (`http://<host>.local:<port>`). Many servers read `PORT` themselves; others take it as a flag (`hugo server --bind 0.0.0.0 --port $PORT --baseURL $DEV_URL/`). They must bind to `0.0.0.0`, not `127.0.0.1`. `dev list` shows each container's port. That includes public Wi-Fi, where others on the network can reach whatever an agent serves on it. For a fixed number on top, publish it when creating the container: `dev create --publish 1313 site`. To change them later, edit `~/containers/<name>/ports` (one per line) and run `dev recreate <name>`. On the Mac, the firewall may ask once whether to let `container` accept incoming connections.

`dev create` writes `~/containers/<name>/env` with commented-out variables (a `GH_TOKEN`, yours or the bot's per [GitHub access](#github-access), its git identity, `GEMINI_API_KEY`). It's read each time `dev` opens a shell, so edits apply to the next one without recreating anything; leave the GitHub lines commented out for a container with no GitHub access, or one signed in with `gh auth login`. Git pushes over HTTPS through `gh`, so the token or login is all GitHub needs.

Inside, `claude`, `codex` and `agy` run without permission prompts by default, since the container is the sandbox: the image ships Claude Code's managed settings and Codex's system config in `/etc`, and an alias adds agy's flag. For one session with prompts, run `claude --permission-mode default`, `codex --ask-for-approval on-request --sandbox workspace-write` or `command agy`. On hosts, keep their prompts, or for a quick question start them read-only: `claude --permission-mode plan`, `codex --sandbox read-only`, `agy --mode plan`.

Images are built with some frequency, via CI, for amd64 and arm64. Builds reuse cached install layers until the scripts or package lists change, so a new image doesn't always mean newer tools; `container build --no-cache` (or `podman build --no-cache`) refreshes everything. To move a container to a new image, keeping its `src`, `env`, logins and ports, `dev recreate personal` pulls the image and replaces the container.

Anything installed in a container outside `/workspaces` and `/state` is lost when it's recreated. Containers keep running until you stop them or the Mac restarts. An idle one uses almost no memory, but what's still running inside does (agents, dev servers, an app's SSH server), so `dev stop` the ones you're done with for a while.

#### Signing in agents

Hosts and containers each sign in separately; the Mac's agent logins can't be shared with containers anyway (Claude Code keeps them in the Keychain). GitHub's can, below.

| Tool | Mac | Debian hosts and containers |
| --- | --- | --- |
| Claude Code | Run `claude` | `claude auth login` |
| Codex | Run `codex` | `codex login --device-auth`, or `codex login` with the callback step below |
| agy | Install the `antigravity-cli` cask by hand, run `agy` | Run `agy` and follow its sign-in |
| gemini-api | `gemini-api configure` with an [AI Studio key](https://aistudio.google.com/apikey) | Containers only: `GEMINI_API_KEY` in the container's `env` |
| GitHub | `gh auth login` as yourself | Containers: `gh auth login` (saved in `/state`, shared with `--shared-state`; see below to reuse the Mac's) or a `GH_TOKEN` in `env`, yours or the bot's |

**Codex when device codes are off.** Some ChatGPT workspaces disable `--device-auth`, and plain `codex login` redirects the browser to `http://127.0.0.1:1455/auth/callback`, which on the Mac reaches the Mac, not the container (Codex only listens on the container's loopback, so publishing the port doesn't help). Hand the callback over yourself:

1. In the container, run `codex login`, open the URL it prints on the Mac and sign in. Leave it running.
2. The browser then fails to load `http://127.0.0.1:1455/auth/callback?code=…`; copy that whole URL.
3. In a second shell in the same container (`dev <name>` in another tmux pane), run `curl -sS '<the URL>'`, in single quotes. The first shell's login finishes and lands in `/state/codex`.

The URL only works for the `codex login` that's still running, so start over if it exits.

**GitHub from the Mac's login.** To sign a container's `gh` in without a browser, pipe the Mac's token in, from the Mac (`podman exec` on Linux):

```sh
gh auth token | container exec --interactive <name> gh auth login --with-token
```

It's saved in `/state/gh`, so every `--shared-state` container is signed in at once. It's as broad as your own login, and signing out of `gh` on the Mac cuts it off too. Or inside the container, run `gh auth login`, choose "Paste an authentication token" and paste the Mac's `gh auth token`. (`gh auth login --with-token` also works, but waits silently for the token on stdin until Ctrl-D.)

Claude Code and agy update themselves. On Linux, `script/update` updates Codex (always the newest release, skipping the cooldown) and the rest; containers can also move to a new image. On the Mac, `brew upgrade` covers the casks, and `script/update` covers gemini-api.

#### Other model providers

Point Claude Code at another Anthropic-compatible provider from a container of its own, so the provider's key is all that container holds and no other container's `claude` changes. For example, [OpenInfer](https://console.openinfer.ai/docs/getting-started/coding-agents): `dev create openinfer`, then in `~/containers/openinfer/env`:

```sh
ANTHROPIC_BASE_URL=https://api.openinfer.ai
ANTHROPIC_AUTH_TOKEN=REPLACE_ME
# Empty rather than unset, so Claude Code uses the token above
ANTHROPIC_API_KEY=
ANTHROPIC_MODEL=@oi/GLM-5.3-Flash
ANTHROPIC_DEFAULT_OPUS_MODEL=@oi/GLM-5.3-Flash
ANTHROPIC_DEFAULT_SONNET_MODEL=@oi/GLM-5.3-Flash
ANTHROPIC_DEFAULT_HAIKU_MODEL=@oi/Qwen3.5-9B
CLAUDE_CODE_SUBAGENT_MODEL=@oi/GLM-5.3-Flash
# The model's real context window, compacting at about three quarters of it
CLAUDE_CODE_MAX_CONTEXT_TOKENS=131072
CLAUDE_CODE_AUTO_COMPACT_WINDOW=98304
```

Check the provider's terms before giving it code: only clone repos into that container that you'd be fine sending there.

#### GitHub access

A container's GitHub login (`gh auth login`, shared across `--shared-state` containers, or a `GH_TOKEN` in its `env`, which wins) decides who its pushes come from. Pick per container:

- **Your own token**, for trusted work where you don't need to review what lands on `main` (your blog, small personal projects). Use a fine-grained token limited to those repos, with Contents and Pull requests read/write. You and agents push to `main` directly as you, no rulesets needed, and repos are plain `gh repo create`.
- **The agent bot's token**, for containers where agents run unattended and you want to review everything first. Its PRs need your approval to merge, set up as below. Changes you make yourself in such a container go through a PR too.

To set up the bot:

1. Create a machine account (GitHub allows one per person), and set `DOTFILES_AGENT_BOT` to its login in `~/.profile.local`.
2. Give it a classic token with the `repo` scope, for the containers' `env`. Fine-grained tokens only cover repos the token's own account (or its orgs) owns.
3. Create repos agents work on with `new-github-repo <owner/name>`. It adds a ruleset on the default branch requiring a pull request with one approval (dismissed by new commits) and blocking force pushes and deletion, which you as admin can bypass, then invites the bot. Rulesets on private repos need GitHub Pro.
4. The bot can push branches whose workflow changes run before any review, so keep Actions secrets on agent repos in an environment that requires your approval.

#### Starting a project

1. On the Mac: `new-github-repo fortes/new-project`.
2. In a container whose `env` has the bot's token, run the two commands it prints: accept the invite, and clone. (For a repo you'll only work on with your own token, `gh repo create` and `git clone` are enough.)
3. Start from the template: `cp -R ~/dotfiles/script/dev/project-template/. .` It has an `AGENTS.md` and a `Makefile` with `setup`, `doctor` and `check`, backed by `script/setup` and `script/doctor`. Pin tool versions and lock dependencies there, so every environment runs the same `make setup`: dev containers, CI, Claude's and Codex's cloud setup scripts, and a devcontainer's `postCreateCommand` if the project ever wants one.
4. Agents work on branches, push as the bot and open PRs; you review and merge on GitHub.
5. When the project needs more than the image has (a browser, a database, its own secrets), give it a Dockerfile `FROM ghcr.io/fortes/dotfiles` and its own container: `container build --tag new-project .`, then `dev create new-project new-project` and clone it there.

#### macOS: Apple container

Homebrew installs [`container`](https://github.com/apple/container), which runs each container in its own lightweight VM. Files containers write to mounts belong to your Mac user. It has no Docker-compatible API, so devcontainer tooling (VS Code, the `devcontainer` CLI) needs Docker or podman, which setup no longer installs on the Mac.

#### Linux: Podman

Podman runs containers rootless and is installed by `script/setup`, and `dev` uses it when Apple's `container` isn't there. Unlike Apple's VM per container, rootless Podman shares the host kernel, so on a server run dev containers as a separate user (`sudo adduser dev`) and SSH in as them. A container escape then lands in an account without your SSH keys or 1Password.

Rootless containers stop when their user logs out. Run `sudo loginctl enable-linger dev` to keep long-running ones alive. The `dev` user has no sudo, so it only clones the repo and runs `script/stow` for the `dev` helper and shell config; the host's own setup installed podman.

To reach a server's containers over SSH from the Mac (for `ssh` itself, editors, and the Claude and Codex apps), chain through the `dev` login, which only needs the server's own SSH port. In the Mac's `~/.ssh/config.local`, before any matching `Host *` block (the stowed `Host dev-*` block skips names with a dot, so this one sets the user, forwarding and known-hosts file itself):

```
Host dev-*.homelab
  ProxyCommand ssh -a dev@homelab .local/bin/dev proxy %n
  User fortes
  ForwardAgent no
  UserKnownHostsFile ~/.ssh/known_hosts.dev
  StrictHostKeyChecking accept-new
```

Both hops authenticate from the Mac using your usual keys and agent: first as `dev` on the server, then as `fortes` in the container. The container trusts plain public-key entries from the server account’s `~/.ssh/authorized_keys`; entries prefixed with options such as `restrict` or `from=` are skipped. Agent forwarding stays off on both hops. Settings under `Host homelab` apply only to the first hop; if your `IdentityFile` or `IdentityAgent` settings live there, repeat them in `Host dev-*.homelab` too. The shared config sets `IdentitiesOnly yes`, so an agent key needs a matching `IdentityFile` (a public-key file is enough when the private key lives in 1Password). Connecting may prompt your agent, unlike containers on the Mac itself.

To avoid agent prompts, allow the Mac's container key into the `dev` account once (`ssh-copy-id -i ~/containers/.ssh/client_ed25519.pub dev@homelab`, after the Mac has run `dev create`) and set `IdentityFile ~/containers/.ssh/client_ed25519`, `IdentitiesOnly yes` and `IdentityAgent none` in the block, plus `-i ~/containers/.ssh/client_ed25519 -o IdentitiesOnly=yes -o IdentityAgent=none` on its inner `ssh`. That key has no passphrase, so it can then log in as `dev` there too, the account kept free of anything worth taking.

Then `ssh dev-blog.homelab` runs `dev proxy` there, which connects to the container `blog`. Its containers copy those plain public-key entries as of their last create or recreate, so after adding one there, `dev recreate` them. All of a machine's containers share one host key (in `~/containers/.ssh`), so reusing a name doesn't upset SSH.

Each container's `DEV_URL` uses the server's plain hostname (`http://homelab:<port>`; the Mac uses its `.local` name), so it only works from other machines if the network's DNS resolves that name. Otherwise install `avahi-daemon` on the server and use `http://homelab.local:<port>`, or its IP.

#### Building locally

```sh
container build --tag dotfiles .                     # dev image (podman build on Linux)
container build --target host --tag dotfiles-host .  # fresh Debian server running script/setup, as CI does
```

Then use `dotfiles` in place of `ghcr.io/fortes/dotfiles:latest`, or `container run --rm --interactive --tty dotfiles-host` to look around the fresh server.

## Other Notes

### Finding packages in backports

Since you have to manually install packages from backports, can be tricky to know what is available. To find out, run the following:

```sh
# Installed packages with a newer version in backports
sudo apt-get -s upgrade -t "$(. /etc/os-release && echo "$VERSION_CODENAME")-backports" \
  | grep Backports

# Or the full picture for one package
apt-cache policy neovim
```

This will list out all the packages installed, then need to search through to manually check which have backports available (pipe to `nvim -`).

## License

This repository is licensed under the BSD 3-Clause License. See the LICENSE file for more information.
