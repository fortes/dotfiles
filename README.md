# Dotfiles

This is only public so I can easily share it across machines. There is probably nothing of interest for you here ... or is there?

## Letting me own your machine

```
bash <(curl -fsSL https://raw.github.com/fortes/dotfiles/master/setup.sh)
```

Then you'll still have to do the following manual steps:

1. Add your ssh keys into `~/.ssh`
2. Setup `~/.ssh/config` with at least:
  ```
  Host github.com
    Hostname github.com
    User git
    IdentityFile ~/.ssh/id_rsa
  ```
3. If you're me (which you're not), set the remote url for this repo in order to push:

  ```
  git remote set-url origin git@github.com:fortes/dotfiles.git
  ```
4. Setup `.gitconfig.local`:

  ````
  [user]
    name = Your Name
    email = xyz@abc.com
  ```
