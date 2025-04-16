# Dotfiles

This is only public so I can easily share it across machines. There is probably nothing of interest for you here ... or is there?

My usage is mostly terminal-based, via Crostini on Chromebook, WSL2 on Windows, and (rarely) MacOS terminal. Making heavy use of:

- Bash / Tmux
- FZF / pistol / fd / ripgrep
- Neovim
- cmus

Graphical sections are Linux-only, and use:

- sway / swaync / waybar
- WezTerm
- Firefox

On MacOS, use:

- WezTerm
- Rectangle

## Letting me own your machine

```sh
git clone https://github.com/fortes/dotfiles.git --branch debian-bookworm
./dotfiles/script/setup
```

## Post-Setup

Once you've run setup, you'll still have to do the following universal manual steps (see platform-specific sections for more):

1. Generate this machine's SSH keys:

   ```sh
   ssh-keygen -t ed25519 -C "$(hostname)"
   ```

   Then add the key into GitHub and wherever else

2. Add any additional ssh keys into `~/.ssh`

   Might need to extract out of 1Password, once downloaded will have the password removed. To restore, do

   ```sh
   ssh-keygen -p -f KEY_FILE
   ```

   Alternatively, try using the command line `op` to get the keys:

   ```sh
   op item get SSH_KEY_ITEM_ID --fields "private key" --reveal > ~/.ssh/xxx &&
   op item get SSH_KEY_ITEM_ID --fields "public key" > ~/.ssh/xxx.pub
   # Private key has quotes around it, so need to remove them before this next step
   ssh-keygen -p -f ~/.ssh/xxx
   chmod 400 ~/.ssh/xxx*
   ```

3. Authorize your public keys on the new machine:

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

   # Copilot Vim extension by doing `:Copilot setup`
   # Make sure `ENABLE_GITHUB_COPILOT` variable is set in `~/.profile.local`
   ```

7. Log into Spotify via `ncspot` and `psst`

8. Add keys for `llm` via `llm keys set xxx` (or copy over from another machine from `~/.config/io.datasette.llm`)

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

### Debian

- Run browser setup above
- Can install some optional apps via scripts:
  - `dotfiles/script/setup_kvm`
  - `dotfiles/script/setup_signal`
  - `dotfiles/script/setup_zerotier`
  - `dotfiles/script/setup_zoom`
- Depending on the machine, you may need `pavucontrol` in order to unmute your audio output via GUI.
  \*\* Alternatively, find the name of the desired output via `pacmd list-sinks` then run `pacmd set-default-sink $SINK_NAME` and make sure to unmute via `pacmd set-sink-mute [name] 0`
- If running multiple monitors, need to configure Wacom tablet to only use a specific monitor:
  ```
  input "type:tablet_tool" {
    map_to_output DP-1
  }
  ```
- For High DPI displays, create a `~/.Xresources.local` file with the proper `Xft.dpi` (see `.Xresources` for example)
- To mount SMB shares on boot, add something like the following to `/etc/fstab`:

  ```
  //machine-name/share /media/share cifs nofail,user=,password=,ro	0	0
  ```

### Chromebook

- Do setup via phone, should copy over everything
- Set local device password and PIN for quicker local login
- Extensions, settings, and play store apps should automatically sync
  - Night light might need to be manually set up?
- Chrome Extension Setup
  - 1Password: Login to account
  - uBlock Origin Lite: Set default config
- Enable Linux, choose a larger disk size (20GB fine?). Double check which debian version it is via `lsb_release -a` (should be `bookworm`)
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

### Windows

- Run all Windows Updates
- Install machine-specific drivers, update BIOS, etc
- Uninstall Teams, and other pre-installed unwanted things
- Enable BitLocker
- Adjust taskbar settings
- Adjust settings for Snipping tool, make sure to save to `Downloads` folder
- Disable browser tabs from being in Alt-Tab list (Settings -> System -> Multitasking)
- Disable "When I snap a window, suggest what I can snap next to it" in System -> Multitasking
- Remove OneDrive and Microsoft Edge from startup items
- Turn on clipboard history by hitting Windows-V
- Set Windows Terminal as default terminal application
  - Download [JetBrains Mono](https://www.jetbrains.com/lp/mono/) and set it as the default font in Windows Terminal
  - Choose reasonable default colors for Windows Terminal
- Enable Hyper-V (required for WSL, useful for VMs)
  - Search for `hyper-v` in start menu, will show up in obscure UI for settings
- Enable [Windows Sandbox](https://learn.microsoft.com/en-us/windows/security/threat-protection/windows-sandbox/windows-sandbox-overview)
- Accept MS Store terms for `winget`, running `winget list` should prompt
- Get WinGet via MS Store via `App Installer`
  - `winget install AgileBits.1Password`
  - `winget install Mozilla.Firefox`
  - `winget install OpenWhisperSystems.Signal`
- Depending on machine setup, the following might be of use as well
  - `winget install Google.Chrome.Dev`
  - `winget install Microsoft.MouseandKeyboardCenter`
  - `winget install Microsoft.PowerToys`
  - `winget install Microsoft.VisualStudioCode`
  - `winget install Plex.PlexAmp`
  - `winget install VideoLAN.VLC`
  - `winget install Zoom.Zoom`
- If gaming, also install:
  - `winget install Blizzard.BattleNet`
  - `winget install Valve.Steam`
- WSL
  - [Optional] Allocate more memory for WSL VM by creating/adding to `%UserProfile%\.wslconfig`:
    ```
    [wsl2]
    memory=16G
    ```
  - [Optional] Enable `systemd` for VM by creating/adding to `/etc/wsl.conf`:
    ```
    [boot]
    systemd=true
    ```
  - Install `Windows Subsystem for Linux` via running `wsl --install Debian` (in an admin terminal)
  - Enter the WSL2 container and run `sudo apt update && sudo apt dist-upgrade`
  - Clone this repo and run `~/dotfiles/setup_machine`
  - [Optional] Set Debian as the default terminal
  - To auto-mount network shares, do something like this in `/etc/fstab` (`drvfs` special for WSL):
    ```
    \\machine-name\share	/mnt/machine-share	drvfs	defaults,ro,noatime,uid=1000,gid=1000,umask=022	0	0
    ```
- 1Password
  - Sign into account
  - Disable global keyboard shortcuts
- Firefox
  - Sign into account
- VS Code
  - Sign in via GitHub to sync
  - (optional) Sign into GitHub Co-pilot
  - Install extensions (in case sync doesn't work)
    - Copilot
    - SSH
    - WSL
    - vim
- Steam & Battle.net
  - Sign in and install games locally

### Mac

Still a work in progress, but kinda works

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
- `terminal.app` sucks with colors, switch to WezTerm and pin it in the dock
- Make sure `Rectangle.app` starts on login
- Install the 1Password extension in Safari (others should sync automatically)

### Docker

Need to first build the thing

```sh
docker build -t dotfiles .
```

Then run it like so to do work via your home directory

```sh
docker run -it --rm --name dotfiles dotfiles
```

To share files, use `-v /path/to/host:/path/to/container`, for example if sharing the `~/src` folder:

```sh
docker run -it --rm --name dotfiles -v ~/src:/home/fortes/src dotfiles
```

Also need to manually start neovim to install plugins

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

### Linux

- Media keys on Microsoft Ergonomic Keyboard sometimes aren't detected, disconnect/reconnect USB may be enough to fix?
- Mouse wheel speed also sometimes goes to a better default after disconnect/reconnect
- 1Password can't manage to save authentication, dies trying to talk to keychain via dbus (for some reason, looking for `org.kde.kwalletd5` and ignores gnome keyring)
- `1password` GUI not installing correctly, something wrong w/ bash logic

## TODO/Future Improvements

- [ ] Set up [network share](https://www.reddit.com/r/Crostini/wiki/howto/addnetworkshares/) in Crostini
- [ ] Look into publishing a docker container via GitHub actions
- [ ] `exa` is now unmaintained, need to either go to [eza](https://github.com/eza-community/eza) or `lsd`
- [ ] Move from `docker` to `podman`
- [ ] Get `devcontainer` setup for this repo
- [ ] Get remote VSCode settings synced up as well, currently in `~/.vscode-server/data/Machine`
- [ ] Figure out how to get [M1 CI running](https://github.blog/changelog/2024-01-30-github-actions-introducing-the-new-m1-macos-runner-available-to-open-source/) to check builds
- [ ] Figure out what [Windows 11 tweaks & usability improvements](https://kittenlabs.de/blog/2024/08/20/windows-11-tweaks-usability-improvements/) to copy
- [ ] Get things working in GitHub codespaces, which seems to use Ubuntu 20.04.06 LTS underneath. Currently fails silently trying to install backports sources. [Troubleshooting instructions](https://docs.github.com/en/codespaces/troubleshooting/troubleshooting-personalization-for-codespaces#troubleshooting-dotfiles) can be helpful
- [ ] Figure out how to [use Hammerspoon](https://github.com/Hammerspoon/Spoons/blob/master/Source/MusicAppMediaFix.spoon/init.lua) to have media keys control cmus, instead of launching iTunes (gross)
- Try switching from docker to podman
- [ ] Look into `glances` and `btop`
- [ ] `wshowkeys` or similar for showing keypresses for screencasts, etc
- [ ] Figure out Lutris / Wine / Proton for Linux gaming
- [ ] [Auto-publish Docker images](https://docs.github.com/en/actions/publishing-packages/publishing-docker-images#publishing-images-to-github-packages)
- [ ] Better colorschemes, coordinated everywhere
  - Check [themer](https://github.com/themerdev/themer) for generation
  - [ ] Easier swapping into light mode
  - [ ] `dircolors` can be better and used elsewhere: https://github.com/seebi/dircolors-solarized
  - [ ] [RootLoops](https://rootloops.sh/) for generation
- [ ] Figure out how to get USB-C DP Alt devices to work, might need [displaylink-debian](https://github.com/AdnanHodzic/displaylink-debian) or at the very least `evdi-dkms`
- [ ] Get [Nvidia Drivers](https://wiki.debian.org/NvidiaGraphicsDrivers) drivers with a reasonable resolution for linux console
  - Install `nvidia-detect` and run to check support
  - Install `nvidia-driver`
  - Get better resolution when booted into console by adding `GRUB_GFXMODE=auto` in `/etc/default/grub`, then run `sudo update-grub`
- [ ] Learn from [Wayland Apps in Wireguard Docker Containers](https://www.procustodibus.com/blog/2024/10/wayland-wireguard-containers/) and see if anything worth copying
- [ ] [Dotfile managers](https://dotfiles.github.io/utilities/) might have something better than GNU `stow`
