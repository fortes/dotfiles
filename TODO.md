# TODO

## Open Tasks

### Priority 2 (Medium)

- [ ] **Investigate markdown-oxide LSP** (task)
  - Seems like it can work alongside obsidian.nvim, see https://oxide.md/index

- [ ] **Look at Claude hooks from denolfe** (task)
  - Some interesting hooks here including stopping bad Git usage like adding all files: https://github.com/denolfe/dotfiles/tree/main/claude/hooks

### Priority 3 (Low)

- [ ] **Get things working in GitHub Codespaces** (bug)
  - GitHub Codespaces uses Ubuntu 20.04.06 LTS and currently fails silently trying to install backports sources
  - Troubleshooting: https://docs.github.com/en/codespaces/troubleshooting/troubleshooting-personalization-for-codespaces#troubleshooting-dotfiles

- [ ] **Get M1 CI running for build checks** (feature)
  - Figure out how to get M1 CI running to check builds
  - See https://github.blog/changelog/2024-01-30-github-actions-introducing-the-new-m1-macos-runner-available-to-open-source/

- [ ] **Get folke/sidekick.nvim working** (feature)
  - Install and configure folke/sidekick.nvim plugin for Neovim

- [ ] **Test timg image viewer** (task)
  - Evaluate timg (https://github.com/hzeller/timg) as a potential terminal image viewer
  - Check compatibility with Ghostty and other terminals used in the setup
  - Labels: evaluation, terminal, tools

- [ ] **Look at using extrepo on Debian** (task)
  - Investigate using extrepo on Debian to potentially replace manual source additions
  - Lots of sources available at https://salsa.debian.org/extrepo-team/extrepo-data/-/tree/master/repos/debian

- [ ] **Install m4xshen/hardtime.nvim for improving vim motions** (feature)
  - Add hardtime.nvim plugin to help improve vim motion efficiency and habits

### Priority 4 (Backlog)

- [ ] **Look into glances and btop** (task)
  - Evaluate glances and btop as system monitoring tools

- [ ] **Use Hammerspoon to make media keys control cmus** (feature)
  - Figure out how to use Hammerspoon to have media keys control cmus instead of launching iTunes
  - Reference: https://github.com/Hammerspoon/Spoons/blob/master/Source/MusicAppMediaFix.spoon/init.lua

- [ ] **Move from docker to podman** (chore)
  - Migrate Docker usage to Podman

- [ ] **Investigate better dotfile managers than GNU stow** (task)
  - Research dotfile managers that might be better than GNU stow
  - Reference: https://dotfiles.github.io/utilities/
