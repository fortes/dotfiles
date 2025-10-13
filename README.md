# Dotfiles

This is only public so I can easily share it across machines. There is probably nothing of interest for you here ... or is there?

My usage is mostly terminal-based on MacOS, Debian Trixie over SSH, or sometimes Crostini (Debian) on Chromebook. Making heavy use of:

- Ghostty
- Bash / Tmux
- Neovim
- FZF / fd / ripgrep
- cmus

## Letting me own your machine

```sh
git clone https://github.com/fortes/dotfiles.git
./dotfiles/script/setup
```

## Post-Setup

Once you've run setup, you'll still have to do the following universal manual steps (see platform-specific sections for more):

1. Generate the machine's SSH keys via 1Password, then add the key into GitHub and wherever else

2. Add any additional ssh keys into `~/.ssh`

3. If it's a server, may want to authorize your other public keys on the new machine:

   ```sh
   ssh-import-id gh:fortes
   ```

4. Add your favorite servers into `.ssh/config.local`

5. Setup `.gitconfig.local`:

   ```
   [user]
     name = Your Name
     email = xyz@abc.com
   ```

   If you need to tweak any config based upon the directory path, do something like

   ```
   [includeIf "gitdir:~/src/company/"]
     path = ~/.config/git/company.gitconfig
   ```

6. Log into GitHub Copilot / Claude Code

   ```sh
   # GitHub CLI client
   gh auth login
   # Install the Copilot extension
   gh extension install github/gh-copilot
   # May also need to update the Copilot extensions
   gh extension upgrade gh-copilot

   # Launch Claude Code, which will take you through the flow
   claude

   # Launch codex CLI to log in
   codex

   # Copilot Vim extension by doing `:Copilot auth`
   # Make sure `ENABLE_GITHUB_COPILOT` variable is set in `~/.profile.local`

   # Launch Copilot CLI agent, open and do `/login
   copilot

   # Launch Gemini CLI agent, open and do `/login
   gemini
   ```

7. Add keys for `llm` via `llm keys set xxx` (or copy over from another machine from `~/.config/io.datasette.llm`)

## Ignoring changes to a file

```sh
git update-index --skip-worktree ./symlinks/npmrc
```

To make changes in the future:

```sh
git update-index --no-skip-worktree ./symlinks/npmrc
```

### Firefox

- Log into sync accounts, extensions should automatically install
- Run `dotfiles/script/stow` manually to make sure to link `user.js` for Firefox now that a profile has been created
- Configure uBlock Origin
  - Enable in private mode
  - Enable cloud storage mode. Should do the following for you, but doesn't always work:
    - Enable annoyances filters
    - Add [Bypass paywalls clean filter](https://gitflic.ru/project/magnolia1234/bypass-paywalls-clean-filters)

### Chrome

- Log into sync accounts, extensions should automatically install
- Log into 1Password extension

### Mac

- Set up TouchID, Apple account if required
- Remove all the junk from the dock
- Enable _Night Shift_ and set to _Sunset to Sunrise_
- Turn off Natural Scrolling
- Increase keyboard repeat rate to max, delay to min
- Change Globe key to Control dictation
- Disable iCloud syncing of all but Find My Mac & Safari
- Set `terminal.app` profile, send option as meta key
- May want to install command line tools manually in order to get `git`: `xcode-select --install`
- Run `setup_mac`
- Make sure keys repeat properly in VSCode: `defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false`
  - For other apps that have this issue, do the following:
    ```sh
    # Get the app id
    osascript -e 'id of app "Cursor"'
    # Outputs something like `com.todesktop.xxxxx`
    defaults write -g com.todesktop.xxxxx ApplePressAndHoldEnabled -bool false
    ```
  - You'll also need to log in to VSCode to get stuff, plus you probably want to run `script/install_vscode_extensions` to get all the extensions installed
- `terminal.app` sucks with colors, switch to Ghostty and pin it in the dock
- Make sure `Rectangle.app` starts on login
- Install the 1Password extension in Safari (others should sync automatically)
- If planning on using Docker a lot, can have Colima autostart on login by running the following:

  ```sh
  brew services start colima
  ```

  Otherwise, just run `colima start` manually when needed.
- If gaming, install Battle.net/Steam via brew:

  ```sh
  # May require this first in order to run Battle.net
  # (Steam has a beta that doesn't require Rosetta)
  softwareupdate --install-rosetta --agree-to-license

  brew install --cask battle-net steam
  # For battle.net, will need to manually run setup to install the app
  # open /opt/homebrew/Caskroom/battle-net/VERSION/Battle.net-Setup.app
  ```

### Debian Server / Crostini

- For servers, make sure to set up [email delivery](https://fortes.com/2020/getting-debian-to-send-emails-that-actually-get-delivered/)
- Should also set up unattended upgrades via `sudo dpkg-reconfigure unattended-upgrades`
- You may need to install `avahi-daemon`, `avahi-dnsconfd`, `avahi-utils`, and `libnss-mdns` to get `.local` hostnames to resolve properly
- `mergerfs` if you want to do any pooling of drives
- `cifs-utils` may also be useful to have installed for mounting Windows shares

### Chromebook

- All the steps from `Chrome` section above
- Set up "Night Light" if it didn't automatically sync
- Enable Linux, choose a larger disk size (20GB fine?). Double check which debian version it is via `lsb_release -a` (should be `trixie`)
- Run `setup_machine`
- Share `Downloads` folder with Linux, then symlink via `ln -s /mnt/chromeos/MyFiles/Downloads ~/downloads`
- Change terminal font by going to `chrome-untrusted://terminal/html/nassh_preferences_editor.html`
  - Add `'DejaVu Sans Mono Nerd'` to the beginning of "Text Font Family"
  - Add the following to custom CSS:
    ```css
    @font-face {
      font-family: "DejaVu Sans Mono Nerd";
      src: url(https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/patched-fonts/DejaVuSansMono/Regular/DejaVuSansMNerdFontMono-Regular.ttf);
      font-weight: normal;
      font-style: normal;
    }
    ```

### Docker

Images are built with some frequency, via CI.

### Long-running container

```sh
# Start container in background
docker-compose up -d

# Connect to tmux session
docker-compose exec dotfiles tmux attach -t main

# Stop/restart as needed
docker-compose stop
docker-compose start
```

### One-off ephemeral session

Gets deleted when you exit.

```sh
docker run -it --rm --name dotfiles -v ~/src:/workspaces ghcr.io/fortes/dotfiles:latest
```

### Persistent container

Preserves state, but not always running

```sh
# First time
docker run -it --name dotfiles -v ~/src:/workspaces ghcr.io/fortes/dotfiles:latest

# Later sessions
docker start -ai dotfiles
```

### Building locally

```sh
docker build -t dotfiles .
```

Then follow normal pattern, just use the local image name like so:

```sh
docker run -it --rm --name dotfiles dotfiles
```

## Other Notes

### Finding packages in backports

Since you have to manually install packages from backports, can be tricky to know what is available. To find out, run the following:

```sh
apt-cache policy $(dpkg --list | cut -d' ' -f3)
```

This will list out all the packages installed, then need to search through to manually check which have backports available (pipe to `nvim -`).

## Known Issues

### Mac

- Firefox and VSCode casks get ornery and no longer update via brew, currently install once via script, but updates have to happen manually. Need to investigate further.

## Linux GUI and Windows WSL2 Support

This repository previously supported Linux GUI environments (using sway/i3) and Windows WSL2. These configurations have been removed as they are no longer actively used. If you need these configurations, check the git history for older implementations.

## TODO/Future Improvements

- [ ] Get [folke/sidekick.nvim](https://github.com/folke/sidekick.nvim) working
- [x] Check out [harper](https://writewithharper.com/docs/integrations/neovim) for grammar checking using LSP
- [ ] Install `m4xshen/hardtime.nvim` for improving vim motions
- [x] ~~Debian Trixie upgrade~~ (completed)
  - [x] ~~Need to run `apt modernize-sources` to update source format~~ (completed)
    - [x] ~~Check scripts to make sure we use the new source format as well~~ (completed)
    - [ ] Look at using `extrepo`? [Lots of sources](https://salsa.debian.org/extrepo-team/extrepo-data/-/tree/master/repos/debian) can probably get rid of a bunch of manual addition
  - [ ] Figure out what's wrong with `/etc/sysctl.d` on Docker Mac
- [ ] Set up [network share](https://www.reddit.com/r/Crostini/wiki/howto/addnetworkshares/) in Crostini
- [x] Get `devcontainer` setup for this repo
- [ ] Figure out how to get [M1 CI running](https://github.blog/changelog/2024-01-30-github-actions-introducing-the-new-m1-macos-runner-available-to-open-source/) to check builds
- [ ] Get things working in GitHub codespaces, which seems to use Ubuntu 20.04.06 LTS underneath. Currently fails silently trying to install backports sources. [Troubleshooting instructions](https://docs.github.com/en/codespaces/troubleshooting/troubleshooting-personalization-for-codespaces#troubleshooting-dotfiles) can be helpful
- [ ] Figure out how to [use Hammerspoon](https://github.com/Hammerspoon/Spoons/blob/master/Source/MusicAppMediaFix.spoon/init.lua) to have media keys control cmus, instead of launching iTunes (gross)
- [ ] Move from `docker` to `podman`
- [ ] Look into `glances` and `btop`
- [ ] [Auto-publish Docker images](https://docs.github.com/en/actions/publishing-packages/publishing-docker-images#publishing-images-to-github-packages)
- [ ] [Dotfile managers](https://dotfiles.github.io/utilities/) might have something better than GNU `stow`

## License

This repository is licensed under the BSD 3-Clause License. See the LICENSE file for more information.
