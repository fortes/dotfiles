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
   ssh-keygen -t rsa -b 4096 -C "$(hostname)"
   ```

Then add the key into GitHub and wherever else

2. Add any additional ssh keys into `~/.ssh`

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

### EC2

- None?

### Chromebook

- Extensions should automatically sync and install
- Setup Smart Lock & PIN unlock
- Enable Linux
- Enable cloud storage for uBlock

### Windows

- Make sure WSL2 is setup
- Get WinGet
- Install Windows Terminal

#### TODO

- [ ] Better colorschemes
- [ ] Setup [textlint](https://github.com/textlint/textlint)
