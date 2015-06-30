set -euo pipefail

CURRENT_YEAR=2014
LOCAL_MUSIC_DIR=~/albums

echo "Copying files"
rsync -avzP --force --delete-after --include="*\[$YEAR]" --include="*.mp3" \
--include="*.jpg" --exclude="*" fedia:/var/media/music/albums/ \
$LOCAL_MUSIC_DIR/albums/$YEAR

echo "Generating album list for $YEAR"
# Generate this outside of the command since the variables won't pass through
BEETS_COMMAND="source ~/virtualenvs/default/bin/activate; \
beet -c ~/.beets/config.yaml ls -a year:$YEAR -f'%time{\$added, %Y-%U} \
\$month \$albumartist - \$album (\$genre)'"
ssh fedia $BEETS_COMMAND | sort -r > $LOCAL_MUSIC_DIR/albums/albums-"$YEAR".txt

# To see output by release month (instead of added), use:
# cut -f3- -d' ' albums-xxxx.txt | sort -r
