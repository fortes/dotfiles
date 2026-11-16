# Moving a machine to private local files

Temporary: delete this file once every machine is moved. Do this once on each
machine with an old checkout.

Do this before pulling. `.profile.local` and friends are symlinks into the repo
today, holding your real values in skip-worktree files that the pull deletes.
Back the machine up first if you can.

First turn each link into a real, private file in `~`. This touches nothing in
the repo, stops at the first failure, and only prints the last line once none of
them is a link anymore:

```sh
bash -euo pipefail <<'EOF'
cd ~/dotfiles
for f in .profile.local .gitconfig.local .mpd/mpd.conf.local .mpdscribble/mpdscribble.conf; do
  [[ -L ~/"$f" ]] || continue
  (umask 077; cp ~/"$f" ~/"$f.new")
  mv -f ~/"$f.new" ~/"$f"
done
for f in .profile.local .gitconfig.local .mpd/mpd.conf.local .mpdscribble/mpdscribble.conf; do
  [[ ! -L ~/"$f" ]]
done
echo "Your local settings are real files in ~ now"
EOF
```

Only after that line prints, put the four tracked files back to their
templates, so the pull can delete them, and relink. Other edits in the checkout
are left alone:

```sh
bash -euo pipefail <<'EOF'
cd ~/dotfiles
tracked=(stowed-files/bash/.profile.local stowed-files/git/.gitconfig.local
  stowed-files/mpd/.mpd/mpd.conf.local stowed-files/mpd/.mpdscribble/mpdscribble.conf)
git update-index --no-skip-worktree "${tracked[@]}"
git checkout -- "${tracked[@]}"
git pull
if [[ "$(uname -s)" != Darwin ]]; then
  # Linux no longer stows the Mac-only packages. Only known files go, and the
  # directories only if empty, so a real ~/Music stays
  script/stow -D ghostty mpd rmpc
  rm -f ~/.mpd/mpd.conf.local ~/.mpdscribble/mpdscribble.conf ~/Music/.mpdignore
  rmdir ~/.mpd/playlists ~/.mpd ~/.mpdscribble ~/Music ~/.config/ghostty \
    ~/.config/rmpc/themes ~/.config/rmpc 2>/dev/null || true
fi
# Relink one file at a time; this unfolds the old directory links
script/stow -R
# Programs wrote some files into the repo through those old links (Neovim's
# plugin lockfile and spell files, ~/.ssh's known_hosts, keys and agent socket
# link), and stow just linked them back. Move each into place in ~
git ls-files --others -z stowed-files | while IFS= read -r -d '' f; do
  rel="${f#stowed-files/*/}"
  [[ -L ~/"$rel" ]] || continue
  rm ~/"$rel"
  mv "$f" ~/"$rel"
done
# Links left dangling by removed packages and scripts (epy, prettier, ...)
find ~ -maxdepth 5 -lname '*dotfiles/stowed-files*' ! -exec test -e {} \; -exec rm -v {} + 2>/dev/null || true
# And folders that deleted packages left in the repo once their files moved out
find stowed-files -type d -empty -delete
EOF
```

Check that a new login shell still has your settings, for example
`bash -lc 'echo $DEFAULT_USERNAME'`.
