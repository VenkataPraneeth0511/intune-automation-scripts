#!/bin/bash

# Log file
LOGFILE="/var/log/chrome_update_restart.log"

echo "------ $(date) ------" >> $LOGFILE

# Get installed Chrome version
INSTALLED_VERSION=$(/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --version | awk '{print $3}')

# Get running Chrome version (if running)
RUNNING_PID=$(pgrep -x "Google Chrome")

if [ -z "$RUNNING_PID" ]; then
    echo "Chrome not running. No action required." >> $LOGFILE
    exit 0
fi

RUNNING_VERSION=$(ps -o command= -p $RUNNING_PID | awk -F/ '{print $NF}')

echo "Installed version: $INSTALLED_VERSION" >> $LOGFILE
echo "Chrome is running." >> $LOGFILE

# Wait 3 hours (10800 seconds)
echo "Waiting 3 hours before force restart..." >> $LOGFILE
sleep 10800

# Recheck if Chrome still running
RUNNING_PID_AFTER=$(pgrep -x "Google Chrome")

if [ ! -z "$RUNNING_PID_AFTER" ]; then

    # Notify user before restart
    sudo -u $(stat -f %Su /dev/console) osascript -e \
    'display notification "Chrome will restart now to complete update." with title "IT Support"'

    sleep 60

    echo "Force restarting Chrome..." >> $LOGFILE

    pkill -x "Google Chrome"
    sleep 5
    open -a "Google Chrome"

    echo "Chrome restarted." >> $LOGFILE
else
    echo "User already relaunched Chrome. No action needed." >> $LOGFILE
fi

exit 0
