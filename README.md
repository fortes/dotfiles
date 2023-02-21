# Dotfiles

This is only public so I can easily share it across machines. There is probably nothing of interest for you here ... or is there?

My usage is mostly terminal-based, via Crostini on Chromebook, WSL2 on Windows, and (rarely) MacOS terminal. Making heavy use of:

* Bash / Tmux
* FZF
* Neovim
* cmus

Graphical sections are Linux-only, and use:

* i3wm & picom & dunst & rofi
* Kitty
* Firefox

## Letting me own your machine

```sh
git clone https://github.com/fortes/dotfiles.git --branch debian-bullseye
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
   op item get SSH_KEY_ITEM_ID --fields "private key" > ~/.ssh/xxx &&
   op item get SSH_KEY_ITEM_ID --fields "public key" > ~/.ssh/xxx.pub
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

### Debian

- Log in to Firefox / Chrome for syncing
- Can install some optional apps via scripts:
  - `dotfiles/scripts/setup_kvm`
  - `dotfiles/scripts/setup_signal`
  - `dotfiles/scripts/setup_zerotier`
  - `dotfiles/scripts/setup_zoom`
- Depending on the machine, you may need `pavucontrol` in order to unmute your audio output via GUI.
  \*\* Alternatively, find the name of the desired output via `pacmd list-sinks` then run `pacmd set-default-sink $SINK_NAME` and make sure to unmute via `pacmd set-sink-mute [name] 0`
- If running multiple monitors, need to configure Wacom tablet to only use a specific monitor:
  ```sh
  xsetwacom --list | grep stylus # get id, e.g. "21"
  xrandr --listactivemonitors # get id, e.g. DP-2

  xsetwacom --set "21" MapToOutput DP-2
  ```
- For High DPI displays, create a `~/.Xresources.local` file with the proper `Xft.dpi` (see `.Xresources` for example)
- To mount SMB shares on boot, add something like the following to `/etc/fstab`:

  ```
  //machine-name/share /media/share cifs nofail,user=,password=,ro	0	0
  ```

#### Docker

- Must manually setup neovim. Launch and run `:PackerSync`

### Chromebook

- Extensions should automatically sync and install
- Setup Phone Smart Lock & PIN unlock
- Enable Linux, run `setup_machine`
- Share `Downloads` folder with Linux

### Windows

- Run all Windows Updates
- Install drivers, update BIOS, etc
- Uninstall Teams, and other pre-installed unwanted things
- Enable BitLocker
- Adjust taskbar settings
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
  - `winget install Valve.Steam` (if gaming)
  - `winget install VideoLAN.VLC`
  - `winget install Zoom.Zoom`
- Install Battle.net (Optional, if gaming)
- WSL
  - `winget install Debian.Debian`
  - `sudo apt update && sudo apt dist-upgrade`
  - Run `~/dotfiles/setup_machine`
  - Set Debian as default terminal
  - To mount network shares, do something like this in `/etc/fstab`:
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

- Not fully functional, see `mac-setup` branch for current status

## Known Issues

- Media keys on Microsoft Ergonomic Keyboard sometimes aren't detected, disconnect/reconnect USB may be enough to fix?
- Mouse wheel speed also sometimes goes to a better default after disconnect/reconnect
- 1Password can't manage to save authentication, dies trying to talk to keychain via dbus (for some reason, looking for `org.kde.kwalletd5` and ignores gnome keyring)
- Gammastep tray indicator displays bogus information, likely [this issue](https://gitlab.com/chinstrap/gammastep/-/issues/21) (Debian has an outdated package)

### Improvements

- [ ] Setup [textlint](https://github.com/textlint/textlint)
- [ ] Better colorschemes, coordinated everywhere
  - [ ] Easier swapping into light mode
- [ ] Setup `xautolock` or similar to automatically lock screen on idle
- [ ] Figure out rofi / dmenu whatever else would make sense to do more in i3
- [ ] Migrate off of X11 to Wayland: Either use nouveau or wait until Sway has Nvidia support (or get an AMD card)
- [ ] Consider `alacritty` once it moves from `sid` into mainline
  - [ ] `foot` on Wayland seems to be quite good
- [ ] Figure out how to get USB-C DP Alt devices to work, might need [displaylink-debian](https://github.com/AdnanHodzic/displaylink-debian) or at the very least `evdi-dkms`
- [ ] Get [Nvidia Drivers](https://wiki.debian.org/NvidiaGraphicsDrivers) drivers with a reasonable resolution for linux console
  - Install `nvidia-detect` and run to check support
  - Install `nvidia-driver`
  - Get better resolution when booted into console by adding `GRUB_GFXMODE=auto` in `/etc/default/grub`, then run `sudo update-grub`
