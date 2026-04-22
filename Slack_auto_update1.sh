#!/bin/bash
LOG="/var/log/slack_auto_update.log"
PKG_TMP="/tmp/slack_latest.pkg"

echo "------- Slack Auto Update Check: $(date) -------" >> "$LOG"

# Confirm Slack exists
if [ ! -d "/Applications/Slack.app" ]; then
    echo "[INFO] Slack not installed, skipping update." >> "$LOG"
    exit 0
fi

# Kill Slack if running
pkill -9 -f "Slack" 2>/dev/null
sleep 2

# Download latest Slack PKG (hosted internally or Slack CDN if allowed)
LATEST_URL="https://downloads.slack-edge.com/releases/macos/Slack-latest.pkg"

curl -L --fail --retry 3 --retry-delay 2 -o "$PKG_TMP" "$LATEST_URL"

if [ ! -s "$PKG_TMP" ]; then
  echo "[ERROR] Slack PKG download failed." >> "$LOG"
  exit 1
fi

# Install silently
installer -pkg "$PKG_TMP" -target / >> "$LOG" 2>&1

if [ $? -eq 0 ]; then
    echo "[INFO] Slack updated successfully." >> "$LOG"
else
    echo "[ERROR] Slack update failed." >> "$LOG"
fi

rm -f "$PKG_TMP"
exit 0