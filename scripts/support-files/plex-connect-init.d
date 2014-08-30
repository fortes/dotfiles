#!/bin/bash
### BEGIN INIT INFO
# Provides:          plexconnect
# Required-Start:    plexmediaserver networking
# Required-Stop:     plexmediaserver networking
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: The Plex Connect daemon
# Description:       This script starts the Plex Connect
#                    Python scripts in daemon form.
### END INIT INFO

# Cribbed from https://gist.github.com/natewalck/6128023

# Using the lsb functions to perform the operations.
. /lib/lsb/init-functions

# Process name ( For display )
NAME=PlexConnect

# Daemon name, where is the actual executable
DAEMON="/usr/local/plexconnect/PlexConnect.py"
DAEMON_NAME="PlexConnect"
DAEMON_USER="plexconnect"

# pid file for the daemon
PIDFILE=/var/run/plexconnect/pid

# If the daemon is not there, then exit.
test -x "$DAEMON" || exit 5

case $1 in
 start)
  log_daemon_msg "Starting system $DAEMON_NAME daemon"
  start-stop-daemon --start --background --pidfile $PIDFILE --make-pidfile \
    --user $DAEMON_USER --chuid $DAEMON_USER --start-as=$DAEMON
  log_end_msg $?
  ;;

 stop)
  log_daemon_msg "Stopping system $DAEMON_NAME daemon"
  start-stop-daemon --stop --pidfile $PIDFILE --retry 10
  log_end_msg $?
  ;;

 restart)
  # Restart the daemon.
  $0 stop
  $0 start
  ;;

 status)
  # Check the status of the process.
  if [ -e $PIDFILE ]; then
   status_of_proc "$DAEMON_NAME" "$DAEMON" && exit 0 || exit $?
   log_success_msg "$DAEMON_NAME process is running"
  else
   log_failure_msg "$DAEMON_NAME process is not running"
  fi
  ;;

 reload)
  $0 restart
  ;;

 *)

  # For invalid arguments, print the usage message.
  echo "Usage: $0 {start|stop|restart|reload|status}"
  exit 1
  ;;
esac
