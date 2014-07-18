set -euo pipefail

for f in *.MTS;
  do ffmpeg -i "$f" -qscale 0 `basename "$f" .MTS`.mp4;
done;
