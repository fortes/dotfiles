set -euo pipefail

DESTINATION_DRIVE=/Volumes/backup/

echo "Cleaning directory before sync"
dot_clean /var/photo
rsync -avzhm --progress --size-only --force --delete-after /var/photo/ $DESTINATION_DRIVE/photo
