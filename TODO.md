# TODO

## Open Tasks

### First, after merging the containers branch

Deferred from the branch's testing, to fix forward. MIGRATION.md has the steps for each machine.

- [ ] **Migrate the homelab** (task)
  - Back up `~/dotfiles` and the `.local` files first. If it hasn't pulled `main` since its `.local` files moved out of the repo (#47), do that migration before pulling: its steps were removed from `main`, so read them with `git show 17b1db7^:MIGRATION.md`
  - After `script/setup`: `beet ls` (plugins load, library intact), SSH and Eternal Terminal still connect, tmux, and anything else it serves
  - The `dev` user: `sudo adduser dev`, `sudo loginctl enable-linger dev`, the Mac's container key in its `~/.ssh/authorized_keys` (`ssh-copy-id -i ~/containers/.ssh/client_ed25519.pub dev@homelab`), then as `dev` clone the repo, `script/stow` and `dev create scratch`
  - From the Mac, the `Host dev-*.homelab` entry in `~/.ssh/config.local` (README, Linux: Podman), then `ssh dev-scratch.homelab`
  - `DEV_URL` uses the plain hostname, which needs the LAN's DNS or `avahi-daemon` to resolve from other machines

- [ ] **Migrate Crostini** (task)
  - Lowest stakes. Then a login shell, nvim on a note, and tmux

- [ ] **Move the Coder devbox to the new setup** (task)
  - Per MIGRATION.md once it's on `main`, since the devbox pulls `main` on every start

- [ ] **Try the agent bot's GitHub flow** (task)
  - `new-github-repo fortes/throwaway-test` with `DOTFILES_AGENT_BOT` set, the bot's token in a container's `env`, a PR from the container, and your approval being dismissed by a new commit. Rulesets on private repos need GitHub Pro

- [ ] **Try another model provider in a container** (task)
  - The README's OpenInfer block in a container's `env`, then `claude`

### Priority 1 (High)

- [ ] **Ship agent config into containers** (feature)
  - Claude Code's `settings.json`, global `CLAUDE.md`, hooks and MCP servers live in each container's `/state`, so every new container starts from defaults. Copy them in from the dotfiles the way `local-templates/` works, so every container's agents behave the same
  - For Claude Code, the image already installs `/etc/claude-code/managed-settings.json` (for the permission defaults, in `script/dev/setup_container`), which takes precedence over user and project settings: add shared hooks, permission rules and MCP servers there (https://code.claude.com/docs/en/devcontainer)

- [ ] **Sign containers into Claude Code with `claude setup-token`** (task)
  - A long-lived `CLAUDE_CODE_OAUTH_TOKEN` in a container's env gives it Claude access without a browser sign-in per container or `--shared-state`, and can be revoked on its own

### Priority 2 (Medium)

- [ ] **Block LAN access from containers** (task)
  - A container can reach every device on the LAN (tested: the router's admin page, and Mac services listening on all interfaces), though not the Mac's localhost-only services. Block private ranges (`10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`) for container traffic on the host, where sudo inside can't undo it: `pf` on the Mac for Apple's container subnet, nftables on the homelab. Published ports keep working, since that traffic is inbound

- [ ] **Sign or pin the dev image** (task)
  - Every container runs `ghcr.io/fortes/dotfiles:latest`, so whoever can push to the GitHub account can change what agents run. Sign it in CI (cosign, attestations) and verify on pull, or have `dev create` use a pinned digest

- [ ] **Add a release cooldown to GitHub release installs** (task)
  - npm, bun and uv skip releases newer than 3 days; `install_github_packages` always takes the latest, for Codex, neovim, fzf, uv and the rest. It already reads the release from GitHub's API, so it could skip releases younger than 3 days

- [ ] **Try Claude Code's auto mode in containers that hold secrets** (task)
  - Instead of `--dangerously-skip-permissions`, auto mode has a classifier review each action before it runs, still without prompts. A middle ground for containers like fil-ter.com's with API keys (https://code.claude.com/docs/en/permission-modes)

- [ ] **Give the agent bot's token an expiry and a rotation reminder** (task)
  - It's a classic `repo`-scope token, reaching every repo the bot is invited to

- [ ] **Test agents on a headless server** (task)
  - Claude Code's sign-in over SSH on the homelab, and `codex --sandbox read-only` running for real there (it can't inside a container). agy's sign-in already works without a browser: it prints a URL and takes the code back

- [ ] **Pin tool versions per project** (task)
  - Starting with fil-ter.com once fortes.com's `make setup` works in Claude's cloud: a `make setup`/`make doctor`, relaxing `check-deps`' exact Node match, and mise or a plain setup script for Node, Bun and Hugo

- [ ] **Generate container env files from 1Password** (task)
  - Keep `~/containers/*/env` as private files, but make 1Password the source of truth: a template of `op://` references per container, turned into the env file with `op inject` by hand when a secret changes. Easy rotation without a Touch ID prompt on every `dev` shell, or one that blocks unattended shells and can't work over SSH on the homelab

- [ ] **Investigate markdown-oxide LSP** (task)
  - Seems like it can work alongside obsidian.nvim, see https://oxide.md/index

- [ ] **Look at Claude hooks from denolfe** (task)
  - Some interesting hooks here including stopping bad Git usage like adding all files: https://github.com/denolfe/dotfiles/tree/main/claude/hooks

### Priority 3 (Low)

- [ ] **Investigate Apple's sandboxy for agent containers** (task)
  - Apple's example runs coding agents in micro VMs whose only way out is a host proxy with a per-hostname allowlist (e.g. `*.anthropic.com`), which would add full egress filtering on top of blocking the LAN: https://github.com/apple/container-examples/tree/main/containerization-sandboxy
  - Experimental, and relies on tools honoring `HTTP_PROXY`. Check whether its `baseImage` can be `ghcr.io/fortes/dotfiles`, or whether to borrow the proxy pattern for `container run` instead
  - Filtering has to be enforced outside the container (host proxy, host network rules): agents have passwordless sudo inside it by design, so an in-container firewall like Anthropic's reference `init-firewall.sh` (iptables with `NET_ADMIN`) could just be turned off

- [ ] **Keep shell history across container rebuilds** (feature)
  - `~/.bash_history` is lost when a container is recreated; point `HISTFILE` into `/state`

- [ ] **Manage homelab services as Quadlet files in the dotfiles** (feature)
  - So a rebuilt NUC gets its services back from `script/setup`, with systemd logs and podman auto-updates

- [ ] **Refresh the image's tools on a schedule** (task)
  - Cached install layers mean a new image doesn't always have newer tools. Either a monthly no-cache build in CI (a new trigger, against the narrow-triggers rule) or a manual `--no-cache` build

- [ ] **Try Incus VMs for agent containers on the homelab** (task)
  - Rootless podman shares the NUC's kernel, unlike Apple's VM per container on the Mac. Incus (trixie has 6.0.4, trixie-backports 7.0.2) can run real KVM VMs, and 6.3+ can run OCI images, so it may run `ghcr.io/fortes/dotfiles` as a VM directly
  - Only after the podman path (separate `dev` user) has been tested on the NUC; it would mean a third `dev` backend. Keep podman and Quadlet for services; plain LXC containers share the kernel too, and Proxmox would replace the Debian host setup

- [ ] **Have editor servers pick up `env` edits** (task)
  - `dev <name>` and each new `ssh dev-<name>` read `~/containers/<name>/env`, but an editor's server inside the container (VS Code, Zed) keeps the environment of the connection that started it, so its terminals miss edits until it restarts. Mounting `env` and reading it from the login shell would cover them

- [ ] **Stop the agent bot from pushing workflow changes** (task)
  - `new-github-repo` only warns that the bot's pushes run `.github/workflows/` changes before review. A push ruleset restricting that path (admin bypass) and read-only default workflow permissions could block it, if the plan allows it. While there, print the invite's ID-based accept command instead of the lookup pipeline

- [ ] **Quiet the image build's locale warnings** (task)
  - The Dockerfile sets `LANG`/`LC_ALL` before `locale-gen` runs, so apt prints perl's "Setting locale failed" during the package install. Set them after

- [ ] **Clean Apple's container images in `cleanup_disk`** (task)
  - It prunes Docker and podman, not Apple's `container` images and builder cache, which the Mac uses now

- [ ] **Let a machine pick `dev create`'s default image** (feature)
  - A `DEV_IMAGE` in `~/.profile.local` (say `dotfiles`, a local build) instead of `ghcr.io/fortes/dotfiles:latest`, for working on the dotfiles themselves. An image named on the command line still wins

- [ ] **Keep pnpm in the image** (task)
  - Each new container downloads pnpm on first use, since the image build clears Corepack's cache with `~/.cache`. Keep that cache, or `corepack prepare` into a folder the cleanup skips

- [ ] **Get folke/sidekick.nvim working** (feature)
  - Install and configure folke/sidekick.nvim plugin for Neovim

- [ ] **Install m4xshen/hardtime.nvim for improving vim motions** (feature)
  - Add hardtime.nvim plugin to help improve vim motion efficiency and habits
