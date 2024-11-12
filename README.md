# Dotfiles

This is only public so I can easily share it across machines. There is probably nothing of interest for you here ... or is there?

My usage is mostly terminal-based, via Crostini on Chromebook, WSL2 on Windows, and (rarely) MacOS terminal. Making heavy use of:

* Bash / Tmux
* FZF / pistol / fd / ripgrep
* Neovim
* cmus

Graphical sections are Linux-only, and use:

* sway / swaync / waybar
* WezTerm
* Firefox

On MacOS, use:

* WezTerm
* Rectangle

## Letting me own your machine

```sh
git clone https://github.com/fortes/dotfiles.git --branch debian-bookworm
./dotfiles/scripts/setup_machine
```

## Setup

Once you've run setup, you'll still have to do the following manual steps:

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

## Ignoring changes to a file

```sh
git update-index --skip-worktree ./symlinks/npmrc
```

To make changes in the future:

```sh
git update-index --no-skip-worktree ./symlinks/npmrc
```

## Additional Settings

TODO: Automate these steps.

- (Optional) Enable GitHub copilot via `~/.profile.local`, then run `:Copilot setup` in NeoVim to authenticate
- Install `kindlegen` [from Amazon](https://www.amazon.com/gp/feature.html?ie=UTF8&docId=1000765211) (TODO: See if possible to script this)

### Firefox / Chrome

- Log into sync accounts, extensions should automatically install
- Configure uBlock
  - Enable in private mode
  - Enable cloud storage mode. Should do the following, but doesn't always work:
    - Enable annoyances filters
    - Add [Bypass paywalls clean filter](https://gitflic.ru/project/magnolia1234/bypass-paywalls-clean-filters)

### Debian

- Run browser setup above
- Can install some optional apps via scripts:
  - `dotfiles/scripts/setup_kvm`
  - `dotfiles/scripts/setup_signal`
  - `dotfiles/scripts/setup_zerotier`
  - `dotfiles/scripts/setup_zoom`
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

#### Docker

- Must start Neovim in order to install plugin manager

#### Bookworm Upgrade

The Bullseye to Bookworm upgrade requires a few manual steps that I'm too lazy to automate:

- Must call `apt-key delete` on keys for `et`, `signal`, etc repos that were added via the now deprecated `apt-key`. Find the key id by taking the last eight digits of the hex displayed (no space). E.g. `apt-key del 57F6FB06` for Signal. Need to then delete the relevant fiels in `/etc/apt/sources.list.d` as well
- `pip` user packages no longer work, everything got moved to `pipx`/`venv` and there may be some strays left in `~/.local/bin` that need to be manually removed
  - `pip freeze --user | xargs pip uninstall` should work here
- Remove `/etc/apt/sources.list.d/bullseye-backports.list` and let the script add the new one

### Chromebook

- Do setup via phone, should copy over everything
- Set local device password and PIN for quicker local login
- Extensions, settings, and play store apps should automatically sync
  - Night light might need to be manually set up?
- Chrome Extension Setup
  - 1Password: Login to account
  - uBlock Origin: Need to enable cloud sync and copy over settings
- Enable Linux, choose a larger disk size (20GB fine?). Double check which debian version it is via `lsb_release -a` (should be `bookworm`)
- Run `setup_machine`
- Share `Downloads` folder with Linux, then symlink via `ln -s /mnt/chromeos/MyFiles/Downloads ~/downloads`

### Windows

- Run all Windows Updates
- Install drivers, update BIOS, etc
- Uninstall Teams, and other pre-installed unwanted things
- Enable BitLocker
- Adjust taskbar settings
- Disable browser tabs from being in Alt-Tab list (Settings -> System -> Multitasking)
- Turn on clipboard history by hitting Windows-V
- Set Windows Terminal as default terminal application
- Enable Hyper-V (required for WSL)
  - Search for `hyper-v` in start menu, will show up in obscure UI for settings
- Enable [Windows Sandbox](https://learn.microsoft.com/en-us/windows/security/threat-protection/windows-sandbox/windows-sandbox-overview)
- Install `Windows Subsystem for Linux` via MS Store (doesn't seem to work in `winget`)
- Accept MS Store terms for `winget`, running `winget list` should prompt
- Get WinGet via MS Store via `App Installer`
  - `winget install AgileBits.1Password`
  - `winget install Google.Chrome.Dev`
  - `winget install Microsoft.MouseandKeyboardCenter`
  - `winget install Microsoft.PowerShell`
  - `winget install Microsoft.PowerToys`
  - `winget install Microsoft.VisualStudioCode`
  - `winget install Mozilla.Firefox`
  - `winget install Neovim.Neovim`
  - `winget install Plex.PlexAmp`
  - `winget install ShareX.ShareX`
  - `winget install SourceFoundry.HackFonts`
  - `winget install Valve.Steam` (if gaming)
  - `winget install VideoLAN.VLC`
  - `winget install Zoom.Zoom`
- Install Battle.net (Optional, if gaming)
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
  - `winget install Debian.Debian`
  - `sudo apt update && sudo apt dist-upgrade`
  - Run `~/dotfiles/setup_machine`
  - Set Debian as default terminal
  - To mount network shares, do something like this in `/etc/fstab` (`drvfs` special for WSL):
    ```
    \\machine-name\share	/mnt/machine-share	drvfs	defaults,ro,noatime,uid=1000,gid=1000,umask=022	0	0
    ```
- 1Password
  - Sign into account
- VS Code
  - Sign in via GitHub to sync
  - (optional) Sign into GitHub Co-pilot
  - Install extensions (in case sync doesn't work)
    - Copilot
    - SSH
    - WSL
    - vim
- ShareX
  - Configure output location to be `Downloads`
- Steam & Battle.net
  - Sign in and install games locally

### Mac

Still a work in progress, but kinda works

- May want to install command line tools manually in order to get `git`: `xcode-select --install`
- Set `terminal.app` profile, send option as meta key
- `terminal.app` sucks with colors, so once installs happen, switch to Alacritty and pin it in the dock
- Make sure Rectangle.app starts on login

#### TODO

- [ ] Figure out how to get [M1 CI running](https://github.blog/changelog/2024-01-30-github-actions-introducing-the-new-m1-macos-runner-available-to-open-source/) to check builds
- [ ] Automate cleaning up old symlinked files via stow, for now can hack via
   ```sh
   find -L ~/.config -type l [-delete]
   ```

## Known Issues

- Debian bookworm does a `debian.sources` file instead of `sources.list`, need to adjust `setup_machine`
- Media keys on Microsoft Ergonomic Keyboard sometimes aren't detected, disconnect/reconnect USB may be enough to fix?
- Mouse wheel speed also sometimes goes to a better default after disconnect/reconnect
- 1Password can't manage to save authentication, dies trying to talk to keychain via dbus (for some reason, looking for `org.kde.kwalletd5` and ignores gnome keyring)
- `exa` is now unmaintained, need to either go to [eza](https://github.com/eza-community/eza) or `lsd`
- `1password` GUI not installing correctly, something wrong w/ bash logic

## Sway Migration

Work in progress. The [Sway Wiki](https://github.com/swaywm/sway/wiki/i3-Migration-Guide) has some good links for migration, and there are [useful tools](https://github.com/swaywm/sway/wiki/Useful-add-ons-for-sway) as well

- Chromium: Need to either use command-line flags `--ozone-platform-hint=auto` or go to `chrome://flags` and set `Preferred Ozone platform`
- Read through [this guide](https://anarc.at/software/desktop/wayland/) a bit more, lots of good detail and using debian and systemd to drive a bunch of stuff
- Notifications
  - [x] `sway-notification-center` over dunst, much better
  - [ ] No need to start automatically, dbus does that
  - [ ] Figure out volume, etc controls in there. Can substitute for some of the waybar stuff
      - Looks like this is on newer version than what's in Debian repos, so need to either go to sid early, or just wait
      - Can also do arbitrary buttons?
  - [ ] Figure out how to show icons for screenshot, etc
  - [ ] Make styling a bit more consistent with rest of UX
- Bar
  - Figure out bar content, using some combination of `waybar` and the [helpers](https://github.com/swaywm/sway/wiki/Useful-add-ons-for-sway#bar-content-generators)
  - [ ] Music control
  - [ ] Better volume display
  - [ ] Screen recording indicator could be nice
- [ ] Figure out clipboard, likely `wl-clipboard` (`wayclip` not in repos)
- [ ] Need to hook up pipewire in tmux as well?
- [ ] Input / keyboard setup, mostly native in sway?
- [ ] `swhkd` to consider as hotkey handler, get `sway` out of the business?
- [ ] Update instructions for setup
  - get `sway/config.local` out of source control, etc
- [ ] Figure out how to make wacom tablet work (and update instructions)
  - [OpenTabletDriver](https://github.com/OpenTabletDriver/OpenTabletDriver) looks promising, but need to test
- [x] Figure out how to get things using Wayland where necessary
  - Firefox, Chrome need flags
  - Signal as well, watch out for needing floating at start
    - `signal-desktop --enable-features=UseOzonePlatform --ozone-platform=wayland`
- [x] Need to update screenshot scripts, will likely be `grim` / `slurp` / `grimshot`
  - Screen recording via `wf-recorder`?
- [x] Volume keyboard controls not working
- [x] Need a `rofi` replacement for app launching, window switching, and shutdown, etc commands.
  - Might consider just using a terminal with `fzf`, but need to figure out the data sources
  - `wofi` kinda working, need to get terminal apps running (e.g. `htop`)
  - Window switcher kinda works, need icons
- [x] `gammastep` seems to work on Wayland, need to figure out all the launching, etc
  - `gammastep-indicator` broken due to not including `/usr/lib/python3/dist-packages` in `PYTHONPATH`, works if done manually, not sure if something wrong with sway config or what
  - Need to double-check at night, but should be good?
- [x] `dunst` seems to support wayland, but need to get launching, etc.
  - Hm, dbus does this for us, probably fine
  - `mako-notifier` an option, need to configure in order to get icons
  - [x] Tray doesn't seem to work? Should have gammastep there?
      - Tray does work, just nothing in it right now
- [x] Need to port background drawing handling over, likely using `swaybg` or just native sway

## Future Improvements

- Try switching from docker to podman
- [ ] Look into `glances` and `btop`
- [ ] (caniuse-cli)[https://github.com/sgentle/caniuse-cmd]
- [ ] Look into `stevearc/conform.nvim`
- [ ] Add [Firefox Nightly](https://blog.nightly.mozilla.org/2023/10/30/introducing-mozillas-firefox-nightly-deb-packages-for-debian-based-linux-distributions/)
- [ ] Use [native OSC52 support in Neovim](https://github.com/neovim/neovim/issues/3344) instead of plugin
- [ ] sixel support in tmux 3.4, but gotta wait until it (hopefully) hits Debian backports
  - Once sixels are supported, can make a bunch of improvements to scripts here
  - May want to consider `zellij` which supports sixel? Currently slightly janky though
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
