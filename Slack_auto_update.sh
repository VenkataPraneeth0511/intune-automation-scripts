#!/bin/bash
LOG="/var/log/slack_update.log"
SLACK_APP="/Applications/Slack.app"
PKG_TMP="/tmp/slack_update.pkg"
LATEST_URL="https://downloads.slack-edge.com/desktop-releases/mac/universal/latest/download"
echo "----- Slack Update Check: $(date) -----" >> "$LOG"
# Check if Slack exists
if [ ! -d "$SLACK_APP" ]; then
    echo "[INFO] Slack not installed. Skipping." >> "$LOG"
    exit 0
fi
# Kill Slack if running
pkill -f "Slack.app" 2>/dev/null
sleep 2

# Get installed version
INSTALLED_VER=$(/usr/bin/defaults read "$SLACK_APP/Contents/Info" CFBundleShortVersionString)
echo "[INFO] Downloading latest Slack..." >> "$LOG"
curl -L --fail --retry 3 --retry-delay 5 -o "$PKG_TMP" "$LATEST_URL"
if [ ! -f "$PKG_TMP" ] || [ ! -s "$PKG_TMP" ]; then
    echo "[ERROR] PKG download failed or file empty." >> "$LOG"
    exit 1
fi
# Install update silently
echo "[INFO] Installing Slack update..." >> "$LOG"
installer -pkg "$PKG_TMP" -target /
if [ $? -eq 0 ]; then
    echo "[INFO] Slack updated successfully." >> "$LOG"
else
    echo "[ERROR] Slack update failed." >> "$LOG"
fi
rm -f "$PKG_TMP"
exit 0