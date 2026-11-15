# TODO

## Open Tasks

### Priority 2 (Medium)

- [ ] **Investigate Apple's sandboxy for agent containers** (task)
  - Apple's example runs coding agents in micro VMs whose only way out is a host proxy with a per-hostname allowlist (e.g. `*.anthropic.com`), which would close the open-egress gap in our agent containers: https://github.com/apple/container-examples/tree/main/containerization-sandboxy
  - Experimental, and relies on tools honoring `HTTP_PROXY`. Check whether its `baseImage` can be `ghcr.io/fortes/dotfiles`, or whether to borrow the proxy pattern for `container run` instead

- [ ] **Investigate markdown-oxide LSP** (task)
  - Seems like it can work alongside obsidian.nvim, see https://oxide.md/index

- [ ] **Look at Claude hooks from denolfe** (task)
  - Some interesting hooks here including stopping bad Git usage like adding all files: https://github.com/denolfe/dotfiles/tree/main/claude/hooks

### Priority 3 (Low)

- [ ] **Try Incus VMs for agent containers on the homelab** (task)
  - Rootless podman shares the NUC's kernel, unlike Apple's VM per container on the Mac. Incus (trixie has 6.0.4, trixie-backports 7.0.2) can run real KVM VMs, and 6.3+ can run OCI images, so it may run `ghcr.io/fortes/dotfiles` as a VM directly
  - Only after the podman path (separate `dev` user) has been tested on the NUC; it would mean a third `dev` backend. Keep podman and Quadlet for services; plain LXC containers share the kernel too, and Proxmox would replace the Debian host setup

- [ ] **Get folke/sidekick.nvim working** (feature)
  - Install and configure folke/sidekick.nvim plugin for Neovim

- [ ] **Install m4xshen/hardtime.nvim for improving vim motions** (feature)
  - Add hardtime.nvim plugin to help improve vim motion efficiency and habits
