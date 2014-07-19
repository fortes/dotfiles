pushd /var/music/tmp
echo 'Fixing any MP3 errors'
mp3val -f -nb */*.mp3
echo 'Beginning silent import'
beet import -q .
echo 'Beginning full import'
beet import .
