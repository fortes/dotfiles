# Dotfiles

This is only public so I can easily share it across machines. There is probably nothing of interest for you here ... or is there?

## Letting me own your machine

```
bash <(curl -fsSL https://raw.github.com/fortes/dotfiles/master/bootstrap.sh)
```

If for some reason, you don't have `curl` installed (why?):

```
bash <(wget -qO- https://raw.github.com/fortes/dotfiles/master/bootstrap.sh)
```

If the machine doesn't have a GUI (i.e. EC2), do the following:

```
HEADLESS=1 bash <(curl -fsSL https://raw.github.com/fortes/dotfiles/master/bootstrap.sh)
```

Then you'll still have to do the following manual steps:

1. Add your ssh keys into `~/.ssh`

2. If you're me (which you're not), set the remote url for this repo in order to push:

  ```
  cd $HOME/dotfiles && git remote set-url origin git@github.com:fortes/dotfiles.git
  ```

3. Setup `.gitconfig.local`:

  ````
  [user]
    name = Your Name
    email = xyz@abc.com
  ```

## Additional Settings

TODO: Automate these steps.

### Mac

* Map Caps Lock to Control
* Install ssh keys to `.ssh/authorized_keys`

### Ubuntu

* Map Caps Lock to Control
* Install ssh keys to `.ssh/authorized_keys`

#### TODO

* Mac settings & preferences
* Better colorschemes
