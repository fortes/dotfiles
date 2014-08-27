#!/bin/bash
# Cribbed from https://gist.github.com/natewalck/6128023
### BEGIN INIT INFO
# Provides:          plexconnect
# Required-Start:    plexmediaserver networking
# Required-Stop:     plexmediaserver networking
# Default-Start:     3 4 5
# Default-Stop:      0 1 6
# Short-Description: This is the Plex Connect daemon
# Description:       This script starts the Plex Connect
#                    Python scripts in a detached screen.
### END INIT INFO

# Using the lsb functions to perform the operations.
. /lib/lsb/init-functions

# Process name ( For display )
NAME=PlexConnect

# Daemon name, where is the actual executable
DAEMON="/usr/bin/screen"
DAEMON_OPTS="-S PlexConnect -d -m /usr/local/plexconnect/PlexConnect.py"
DAEMON_USER="plexconnect"

# pid file for the daemon
PIDFILE=/var/run/PlexConnect.pid

# If the daemon is not there, then exit.
test -x "$DAEMON" || exit 5

case $1 in
 start)
  # Checked the PID file exists and check the actual status of process
  if [ -e $PIDFILE ]; then
   status_of_proc -p $PIDFILE "$DAEMON $DAEMON_OPTS" "$NAME process" && status="0" || status="$?"
   # If the status is SUCCESS then don't need to start again.
   if [ $? = "0" ]; then
    log_success_msg "Starting the process $NAME"
    exit # Exit
   fi
  fi
  # Start the daemon.
  # Start the daemon with the help of start-stop-daemon
  # Log the message appropriately
  if start-stop-daemon --start --quiet --oknodo --pidfile $PIDFILE --startas $DAEMON -p $PIDFILE -- ${DAEMON_OPTS}; then
   while read line ; do [[ $line =~ ([0-9]*).PlexConnect ]] && echo ${BASH_REMATCH[1]} ; done < <(screen -ls) > $PIDFILE
   log_success_msg "Starting the process $NAME"
  else
   log_failure_msg "Starting the process $NAME"
  fi
  ;;
 stop)

  # Stop the daemon.
  if [ -e $PIDFILE ]; then
   status_of_proc -p $PIDFILE "$DAEMON DAEMON_OPTS" "Stoppping the $NAME process" && status="0" || status="$?"
   if [ "$?" = 0 ]; then
    start-stop-daemon --stop --quiet --oknodo --pidfile $PIDFILE
    /bin/rm -rf $PIDFILE
    log_success_msg ""Stopping the $NAME process""
   fi
  else
   log_failure_msg "$NAME process is not running"
  fi
  ;;
 restart)
  # Restart the daemon.
  $0 stop && sleep 2 && $0 start
  ;;
 status)
  # Check the status of the process.
  if [ -e $PIDFILE ]; then
   status_of_proc -p $PIDFILE "$DAEMON $DAEMON_OPTS" "$NAME process" && exit 0 || exit $?
   log_success_msg "$NAME process is running"
  else
   log_failure_msg "$NAME process is not running"
  fi
  ;;
 reload)
  $0 restart
  ;;
 *)
  # For invalid arguments, print the usage message.
  echo "Usage: $0 {start|stop|restart|reload|status}"
  exit 2
  ;;
esac
