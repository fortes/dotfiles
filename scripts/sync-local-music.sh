set -euo pipefail

CURRENT_YEAR=2014
LOCAL_MUSIC_DIR=~/albums

# Copy only current year albums
echo "Cleaning directory before copy..."
dot_clean /var/music
rsync -avzhm --progress --size-only --force --include="*\[$CURRENT_YEAR]" --include='*.mp3' --include='*.jpg' --exclude='*' --delete-after /var/music/albums/ $LOCAL_MUSIC_DIR
echo "Generating album list..."
beet ls -a added:"$CURRENT_YEAR" year:"$CURRENT_YEAR" -f'%time{$added, %U} $albumartist - $album ($genre)' | sort -r > $LOCAL_MUSIC_DIR/albums-"$CURRENT_YEAR".txt
