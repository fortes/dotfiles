# Copies albums from remote server to local machine

if [ -z $REMOTE_MUSIC_PATH ]; then
  echo "Must have REMOTE_MUSIC_PATH & REMOTE_MUSIC_SERVER variables set"
  exit
fi

if [ -z $LOCAL_MUSIC_DIR ]; then
  echo "Must have LOCAL_MUSIC_DIR, etc variables set"
  exit
fi

if [ -z $1 ]; then
  YEAR=`date +"%Y"`
else
  YEAR=$1
fi

echo "Copying files"
rsync -avzP --force --delete-after --include="*- \[$YEAR] *" --include="*.mp3" \
--include="*.jpg" --exclude="*" $REMOTE_MUSIC_SERVER:$REMOTE_MUSIC_PATH \
$LOCAL_MUSIC_DIR/albums/$YEAR

echo "Generating album list for $YEAR"
# Generate this outside of the command since the variables won't pass through
BEETS_COMMAND="source ~/virtualenvs/default/bin/activate; \
beet -c ~/.config/beets/config.yaml ls -a year:$YEAR -f'%time{\$added, %Y-%U} \
\$month \$albumartist - \$album (\$genre)'"
ssh $REMOTE_MUSIC_SERVER $BEETS_COMMAND | sort -r > $LOCAL_MUSIC_DIR/albums/albums-"$YEAR".txt

# To see output by release month (instead of added), use:
# cut -f3- -d' ' albums-xxxx.txt | sort -r
