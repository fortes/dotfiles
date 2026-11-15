# TODO

## Open Tasks

### Priority 1 (High)

- [ ] **Keep container secrets out of plaintext env files** (task)
  - `~/containers/*/env` holds the bot token and API keys in plain text, readable by anything running as you. Have `dev` fill them from 1Password at shell time (`op inject` or `op run`), so the files only hold `op://` references

- [ ] **Check Apple's container service survives a reboot** (task)
  - `container system start` registers a launchd service, but a reboot was never tested. If it doesn't come back, `dev` fails until it's started again; decide whether `dev` should say so or start it

- [ ] **Ship agent config into containers** (feature)
  - Claude Code's `settings.json`, global `CLAUDE.md`, hooks and MCP servers live in each container's `/state`, so every new container starts from defaults. Copy them in from the dotfiles the way `local-templates/` works, so every container's agents behave the same

### Priority 2 (Medium)

- [ ] **Sign or pin the dev image** (task)
  - Every container runs `ghcr.io/fortes/dotfiles:latest`, so whoever can push to the GitHub account can change what agents run. Sign it in CI (cosign, attestations) and verify on pull, or have `dev create` use a pinned digest

- [ ] **Give the agent bot's token an expiry and a rotation reminder** (task)
  - It's a classic `repo`-scope token, reaching every repo the bot is invited to

- [ ] **Test agents on a headless server** (task)
  - Claude Code's and agy's sign-in over SSH on the homelab, and `codex --sandbox read-only` running for real there (it can't inside a container)

- [ ] **Pin tool versions per project** (task)
  - Starting with fil-ter.com once fortes.com's `make setup` works in Claude's cloud: a `make setup`/`make doctor`, relaxing `check-deps`' exact Node match, and mise or a plain setup script for Node, Bun and Hugo

- [ ] **Investigate Apple's sandboxy for agent containers** (task)
  - Apple's example runs coding agents in micro VMs whose only way out is a host proxy with a per-hostname allowlist (e.g. `*.anthropic.com`), which would close the open-egress gap in our agent containers: https://github.com/apple/container-examples/tree/main/containerization-sandboxy
  - Experimental, and relies on tools honoring `HTTP_PROXY`. Check whether its `baseImage` can be `ghcr.io/fortes/dotfiles`, or whether to borrow the proxy pattern for `container run` instead

- [ ] **Investigate markdown-oxide LSP** (task)
  - Seems like it can work alongside obsidian.nvim, see https://oxide.md/index

- [ ] **Look at Claude hooks from denolfe** (task)
  - Some interesting hooks here including stopping bad Git usage like adding all files: https://github.com/denolfe/dotfiles/tree/main/claude/hooks

### Priority 3 (Low)

- [ ] **Keep shell history across container rebuilds** (feature)
  - `~/.bash_history` is lost when a container is recreated; point `HISTFILE` into `/state`

- [ ] **Manage homelab services as Quadlet files in the dotfiles** (feature)
  - So a rebuilt NUC gets its services back from `script/setup`, with systemd logs and podman auto-updates

- [ ] **Refresh the image's tools on a schedule** (task)
  - Cached install layers mean a new image doesn't always have newer tools. Either a monthly no-cache build in CI (a new trigger, against the narrow-triggers rule) or a manual `--no-cache` build

- [ ] **Try the rollback from BRANCH-TESTING.md once** (task)
  - It's untested; Crostini is the lowest-stakes machine to try it on

- [ ] **Try Incus VMs for agent containers on the homelab** (task)
  - Rootless podman shares the NUC's kernel, unlike Apple's VM per container on the Mac. Incus (trixie has 6.0.4, trixie-backports 7.0.2) can run real KVM VMs, and 6.3+ can run OCI images, so it may run `ghcr.io/fortes/dotfiles` as a VM directly
  - Only after the podman path (separate `dev` user) has been tested on the NUC; it would mean a third `dev` backend. Keep podman and Quadlet for services; plain LXC containers share the kernel too, and Proxmox would replace the Debian host setup

- [ ] **Get folke/sidekick.nvim working** (feature)
  - Install and configure folke/sidekick.nvim plugin for Neovim

- [ ] **Install m4xshen/hardtime.nvim for improving vim motions** (feature)
  - Add hardtime.nvim plugin to help improve vim motion efficiency and habits
