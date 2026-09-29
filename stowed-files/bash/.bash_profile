# vim: ft=sh
# Login shells (SSH, etc) skip ~/.bashrc. Interactive ones load it, which in
# turn loads ~/.profile; non-interactive ones only need ~/.profile for PATH
# and env, since ~/.bashrc returns early for them
case $- in
  *i*) . "$HOME/.bashrc" ;;
  *) . "$HOME/.profile" ;;
esac
