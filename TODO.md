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

- [ ] **Get folke/sidekick.nvim working** (feature)
  - Install and configure folke/sidekick.nvim plugin for Neovim

- [ ] **Install m4xshen/hardtime.nvim for improving vim motions** (feature)
  - Add hardtime.nvim plugin to help improve vim motion efficiency and habits
