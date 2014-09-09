INCONSOLATA_DZ_URL='https://github.com/Lokaltog/powerline-fonts/raw/master/InconsolataDz/Inconsolata-dz%20for%20Powerline.otf'
FONT_DIRECTORY=~/.fonts
FONT_INSTALLED=0

if [ `uname` == 'Linux' ]; then
  echo 'Installing font via Linux method'
  mkdir -p $FONT_DIRECTORY
  if [ ! -f $FONT_DIRECTORY/Inconsolata-dz-for-powerline.otf ]; then
    echo 'Installing Inconsolata-Dz'
    wget $INCONSOLATA_DZ_URL -O $FONT_DIRECTORY/Inconsolata-dz-for-powerline.otf 
    FONT_INSTALLED=1
  fi

  if [ $FONT_INSTALLED ]; then
    echo 'Purging font cache, will need to restart some programs'
    sudo fc-cache -f -v
  fi
fi
