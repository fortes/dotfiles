#!/usr/bin/env python
# run this in cmus ":set status_display_program=/path/to/last-cmus.py"
# it will submit the song info to the last.fm

import sys
import urllib
import urllib2
import time
import os
from time import mktime
from datetime import datetime, timedelta
from md5 import md5

# enter your last.fm username/password here
username = os.environ.get("LAST_FM_USERNAME")
password = os.environ.get("LAST_FM_PASSWORD")

if not username or not password:
    print("Must set $LAST_FM_USERNAME and $LAST_FM_PASSWORD")
    sys.exit(1)

# other globals
SESSION_ID = None
POST_URL = None
NOW_URL = None
HARD_FAILS = 0
LAST_HS = None   # Last handshake time
HS_DELAY = 0      # wait this many seconds until next handshake
SUBMIT_CACHE = []
MAX_CACHE = 5      # keep only this many songs in the cache
PROTOCOL_VERSION = '1.2'
__LOGIN = {}     # data required to login


class BackendError(Exception):

    "Raised if the AS backend does something funny"
    pass


class AuthError(Exception):

    "Raised on authencitation errors"
    pass


class PostError(Exception):

    "Raised if something goes wrong when posting data to AS"
    pass


class SessionError(Exception):

    "Raised when problems with the session exist"
    pass


class ProtocolError(Exception):

    "Raised on general Protocol errors"
    pass


def login(user, password, hashpw=False, client=('tst', '1.0')):
    """Authencitate with AS (The Handshake)

    @param user:     The username
    @param password: md5-hash of the user-password
    @param hashpw:   If True, then the md5-hash of the password is performed
                     internally. If set to False (the default), then the module
                     assumes the passed value is already a valid md5-hash of the
                     password.
    @param client:   Client information (see http://www.audioscrobbler.net/development/protocol/ for more info)
    @type  client:   Tuple: (client-id, client-version)"""
    global LAST_HS, SESSION_ID, POST_URL, NOW_URL, HARD_FAILS, HS_DELAY, \
        PROTOCOL_VERSION, __LOGIN

    __LOGIN['u'] = user
    __LOGIN['c'] = client

    if LAST_HS is not None:
        next_allowed_hs = LAST_HS + timedelta(seconds=HS_DELAY)
        if datetime.now() < next_allowed_hs:
            delta = next_allowed_hs - datetime.now()
            raise ProtocolError("""Please wait another %d seconds until next handshake
(login) attempt.""" % delta.seconds)

    LAST_HS = datetime.now()

    tstamp = int(mktime(datetime.now().timetuple()))
    url = "http://post.audioscrobbler.com/"

    if hashpw is True:
        __LOGIN['p'] = md5(password).hexdigest()
    else:
        __LOGIN['p'] = password

    token = md5("%s%d" % (__LOGIN['p'], int(tstamp))).hexdigest()
    values = {
        'hs': 'true',
          'p': PROTOCOL_VERSION,
          'c': client[0],
          'v': client[1],
          'u': user,
          't': tstamp,
          'a': token
    }
    data = urllib.urlencode(values)
    req = urllib2.Request("%s?%s" % (url, data))
    response = urllib2.urlopen(req)
    result = response.read()
    lines = result.split('\n')

    if lines[0] == 'BADAUTH':
        raise AuthError('Bad username/password')

    elif lines[0] == 'BANNED':
        raise Exception('''This client-version was banned by Audioscrobbler. Please
contact the author of this module!''')

    elif lines[0] == 'BADTIME':
        raise ValueError('''Your system time is out of sync with Audioscrobbler.
Consider using an NTP-client to keep you system time in sync.''')

    elif lines[0].startswith('FAILED'):
        handle_hard_error()
        raise BackendError("Authencitation with AS failed. Reason: %s" %
                           lines[0])

    elif lines[0] == 'OK':
        # wooooooohooooooo. We made it!
        SESSION_ID = lines[1]
        NOW_URL = lines[2]
        POST_URL = lines[3]
        HARD_FAILS = 0

    else:
        # some hard error
        handle_hard_error()


def handle_hard_error():
    "Handles hard errors."
    global SESSION_ID, HARD_FAILS, HS_DELAY

    if HS_DELAY == 0:
        HS_DELAY = 60
    elif HS_DELAY < 120 * 60:
        HS_DELAY *= 2
    if HS_DELAY > 120 * 60:
        HS_DELAY = 120 * 60

    HARD_FAILS += 1
    if HARD_FAILS == 3:
        SESSION_ID = None


def now_playing(artist, track, album="", length="", trackno="", mbid=""):
    """Tells audioscrobbler what is currently running in your player. This won't
    affect the user-profile on last.fm. To do submissions, use the "submit"
    method

    @param artist:  The artist name
    @param track:   The track name
    @param album:   The album name
    @param length:  The song length in seconds
    @param trackno: The track number
    @param mbid:    The MusicBrainz Track ID
    @return: True on success, False on failure"""

    global SESSION_ID, NOW_URL

    if SESSION_ID is None:
        raise AuthError("Please 'login()' first. (No session available)")

    if POST_URL is None:
        raise PostError("Unable to post data. Post URL was empty!")

    if length != "" and type(length) != type(1):
        raise TypeError("length should be of type int")

    if trackno != "" and type(trackno) != type(1):
        raise TypeError("trackno should be of type int")

    values = {'s': SESSION_ID,
              'a': unicode(artist).encode('utf-8'),
              't': unicode(track).encode('utf-8'),
              'b': unicode(album).encode('utf-8'),
              'l': length,
              'n': trackno,
              'm': mbid}

    data = urllib.urlencode(values)
    req = urllib2.Request(NOW_URL, data)
    response = urllib2.urlopen(req)
    result = response.read()

    if result.strip() == "OK":
        return True
    elif result.strip() == "BADSESSION":
        raise SessionError('Invalid session')
    else:
        return False


def submit(artist, track, time, source='P', rating="", length="", album="",
           trackno="", mbid="", autoflush=False):
    """Append a song to the submission cache. Use 'flush()' to send the cache to
    AS. You can also set "autoflush" to True.

    From the Audioscrobbler protocol docs:
    ---------------------------------------------------------------------------

    The client should monitor the user's interaction with the music playing
    service to whatever extent the service allows. In order to qualify for
    submission all of the following criteria must be met:

    1. The track must be submitted once it has finished playing. Whether it has
       finished playing naturally or has been manually stopped by the user is
       irrelevant.
    2. The track must have been played for a duration of at least 240 seconds or
       half the track's total length, whichever comes first. Skipping or pausing
       the track is irrelevant as long as the appropriate amount has been played.
    3. The total playback time for the track must be more than 30 seconds. Do
       not submit tracks shorter than this.
    4. Unless the client has been specially configured, it should not attempt to
       interpret filename information to obtain metadata instead of tags (ID3,
       etc).

    @param artist: Artist name
    @param track:  Track name
    @param time:   Time the track *started* playing in the UTC timezone (see
                   datetime.utcnow()).

                   Example: int(time.mktime(datetime.utcnow()))
    @param source: Source of the track. One of:
                   'P': Chosen by the user
                   'R': Non-personalised broadcast (e.g. Shoutcast, BBC Radio 1)
                   'E': Personalised recommendation except Last.fm (e.g.
                        Pandora, Launchcast)
                   'L': Last.fm (any mode). In this case, the 5-digit Last.fm
                        recommendation key must be appended to this source ID to
                        prove the validity of the submission (for example,
                        "L1b48a").
                   'U': Source unknown
    @param rating: The rating of the song. One of:
                   'L': Love (on any mode if the user has manually loved the
                        track)
                   'B': Ban (only if source=L)
                   'S': Skip (only if source=L)
                   '':  Not applicable
    @param length: The song length in seconds
    @param album:  The album name
    @param trackno:The track number
    @param mbid:   MusicBrainz Track ID
    @param autoflush: Automatically flush the cache to AS?
    @return:       True on success, False if something went wrong
    """

    global SUBMIT_CACHE, MAX_CACHE

    source = source.upper()
    rating = rating.upper()

    if source == 'L' and (rating == 'B' or rating == 'S'):
        raise ProtocolError("""You can only use rating 'B' or 'S' on source 'L'.
See the docs!""")

    if source == 'P' and length == '':
        raise ProtocolError("""Song length must be specified when using 'P' as
source!""")

    if type(time) != type(1):
        raise ValueError("""The time parameter must be of type int (unix
timestamp). Instead it was %s""" % time)

    SUBMIT_CACHE.append(
        {'a': unicode(artist).encode('utf-8'),
            't': unicode(track).encode('utf-8'),
            'i': time,
            'o': source,
            'r': rating,
            'l': length,
            'b': unicode(album).encode('utf-8'),
            'n': trackno,
            'm': mbid
         }
    )

    if autoflush or len(SUBMIT_CACHE) >= MAX_CACHE:
        return flush()
    else:
        return True


def flush(inner_call=False):
    """Sends the cached songs to AS.

    @param inner_call: Internally used variable. Don't touch!"""
    global SUBMIT_CACHE, __LOGIN

    if POST_URL is None:
        raise ProtocolError('''Cannot submit without having a valid post-URL. Did
you login?''')

    values = {}

    for i, item in enumerate(SUBMIT_CACHE):
        for key in item:
            values[key + "[%d]" % i] = item[key]

    values['s'] = SESSION_ID

    data = urllib.urlencode(values)
    req = urllib2.Request(POST_URL, data)
    response = urllib2.urlopen(req)
    result = response.read()
    lines = result.split('\n')

    if lines[0] == "OK":
        SUBMIT_CACHE = []
        return True
    elif lines[0] == "BADSESSION":
        if inner_call is False:
            login(__LOGIN['u'], __LOGIN['p'], client=__LOGIN['c'])
            flush(inner_call=True)
        else:
            raise Warning("Infinite loop prevented")
    elif lines[0].startswith('FAILED'):
        handle_hard_error()
        raise BackendError("Submission to AS failed. Reason: %s" %
                           lines[0])
    else:
        # some hard error
        handle_hard_error()
        return False


class LastCmus(object):

    def __init__(self):
        # dict with unicode values, contains songs info
        self.data = {}
        # path to status file, default to /tmp/.user-cmus_status.
        self.status = None
        # content of the status
        self.status_content = None

        # get status path if none specifided
        if not self.status:
            self.status = "/tmp/.%s-cmus_status" % (os.environ["USER"], )

    def update_status(self):
        # get song info
        self.get_song_info()

        # read status
        self.read_file()

        # run LIVE if the current song isnt in the status
        if self.status_content != self.combine():
            self.run()
        else:
            print "Skipped scrobbing because still on same song: %s" % self.status_content

        # write status
        self.write_file()

    def write_file(self):
        fo = open(self.status, "w")
        fo.write("%s:%s" %
                 (self.data["artist"], self.data["title"].encode('utf-8')))
        fo.close()

    def read_file(self):
        if os.path.exists(self.status):
            fo = open(self.status, "r")
            self.status_content = fo.read()
            fo.close()

    def combine(self):
        if self.data.has_key("artist") and self.data.has_key("title"):
            return self.data["artist"] + ":" + self.data["title"]
        return None

    # get song information from command-line arguments
    def get_song_info(self):
        for pos in xrange(1, len(sys.argv), 2):
            self.data[sys.argv[pos]] = sys.argv[pos + 1].decode('utf-8')

    def run(self):
        if self.data.has_key("artist") and self.data.has_key("title") and self.data.has_key("album") and self.data.has_key("musicbrainz_trackid"):
            # track = self.data["artist"] + " - " + self.data["title"]
            # Start the last.fm session
            now = int(time.mktime(datetime.now().timetuple()))
            login(username, password, hashpw=True)
            submit(self.data["artist"], self.data["title"], now, source="P", length=3 *
                   60 + 32, album=self.data["album"], mbid=self.data["musicbrainz_trackid"])
            if flush():
                print "Scrobbled: %s - %s" % (self.data["artist"], self.data["title"])
            else:
                print "Could not scrobble: %s - %s" % (self.data["artist"], self.data["title"])
                sys.exit(1)
        else:
            print "Did not submit due to missing data:"
            print self.data
            sys.exit(1)

    def run_test(self):
        if self.data.has_key("artist") and self.data.has_key("title"):
            fo = open("~/debug.txt", "a")
            fo.write("%s - %s\n" %
                     (self.data["artist"], self.data["title"].encode('utf-8')))
            fo.close()

if __name__ == "__main__":
    lc = LastCmus()
    lc.update_status()
