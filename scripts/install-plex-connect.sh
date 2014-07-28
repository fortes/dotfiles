PLEX_CONNECT_DIR=$HOME/PlexConnect
ASSETS_DIR=$PLEX_CONNECT_DIR/assets/certificates

git clone https://github.com/iBaa/PlexConnect.git $PLEX_CONNECT_DIR
pushd $PLEX_CONNECT_DIR
openssl req -new -nodes -newkey rsa:2048 \
            -out $ASSETS_DIR/trailers.pem \
            -keyout $ASSETS_DIR/trailers.key -x509 -days 7300 \
            -subj "/C=US/CN=trailers.apple.com"
openssl x509 -in $ASSETS_DIR/trailers.pem -outform der \
             -out $ASSETS_DIR/trailers.cer && \
             cat $ASSETS_DIR/trailers.key >> $ASSETS_DIR/trailers.pem
popd
