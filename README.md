# Dotfiles

This is only public so I can easily share it across machines. There is probably nothing of interest for you here ... or is there?

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

- Install `kindlegen` [from Amazon](https://www.amazon.com/gp/feature.html?ie=UTF8&docId=1000765211)

### Debian / Ubuntu

- Depending on the machine, you may need `pavucontrol` in order to unmute your audio output via GUI.
  \*\* Alternatively, find the name of the desired output via `pacmd list-sinks` then run `pacmd set-default-sink $SINK_NAME` and make sure to unmute via `pacmd set-sink-mute [name] 0`
- If running multiple monitors, need to configure Wacom tablet to only use a specific monitor:
  ```sh
  xsetwacom --list | grep stylus # get id, e.g. "21"
  xrandr --listactivemonitors # get id, e.g. DP-2

  xsetwacom --set "21" MapToOutput DP-2
  ```
- To mount SMB shares on boot, add something like the following to `/etc/fstab`:

  ```
  //machine-name/share /media/share cifs nofail,user=,password=,ro	0	0
  ```

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
- Get WinGet via MS Store via `App Installer`
  - `winget install 1Password`
  - `winget install Google.Chrome.Dev`
  - `winget install Mozilla.Firefox`
  - `winget install Plex.PlexAmp`
  - `winget install ShareX.ShareX`
  - `winget install VideoLAN.VLC`
  - `winget install Zoom.Zoom`
  - `winget install vscode`
    - Install vim, WSL, and SSH extensions
- WSL
  - `wsl --install --distribution Debian` in admin command line
  - If not on `bullseye` (was `stretch` last tried in April 2022), then need to update `/etc/apt/sources.list`:
    ```
deb http://deb.debian.org/debian bullseye main
deb http://deb.debian.org/debian bullseye-updates main
deb http://security.debian.org/debian-security/ bullseye-security main
    ```
  - `sudo apt update && sudo apt dist-upgrade`
  - Run `~/dotfiles/setup_machine`
- Set Windows Terminal as default terminal application
- Set Debian as default terminal

### EC2

- None?

### Docker

- Must manually setup neovim. Launch and run `:PackerSync`

#### TODO

- [ ] Fix initial Neovim setup, since runs on older version (0.4) until app image version installed
- [ ] Use `fnm` everywhere instead of Debian node
  - [ ] Need to figure out `yarn` compat, or just move everything to npm
- [ ] Better colorschemes
- [ ] Setup [textlint](https://github.com/textlint/textlint)
