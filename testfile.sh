#!/bin/zsh

set -u

REPORT="$HOME/Desktop/macos_last_update_investigation_$(date +%Y%m%d_%H%M%S).txt"
LOOKBACK_HOURS=168
TMPFILE="/tmp/macos_update_logs_$$.txt"

exec > >(tee -a "$REPORT") 2>&1

echo "============================================================"
echo "macOS Software Update Investigation Report"
echo "Generated: $(date)"
echo "Hostname : $(scutil --get ComputerName 2>/dev/null || hostname)"
echo "User     : $(whoami)"
echo "Lookback : Last ${LOOKBACK_HOURS} hours"
echo "============================================================"
echo

echo "## 1. macOS Version"
sw_vers
echo

echo "## 2. Last Installed Software Updates"
softwareupdate --history 2>/dev/null | tail -50
echo

echo "## 3. Recent reboot history"
last reboot | head -10
echo

echo "## 4. pmset restart-related entries"
sudo pmset -g log 2>/dev/null | grep -iE "restart|reboot|shutdown cause|previous shutdown cause" | tail -50
echo

echo "## 5. Collect unified logs"
sudo log show --last "${LOOKBACK_HOURS}h" --style syslog \
  --predicate '(process == "softwareupdated") OR (process == "SoftwareUpdateNotificationManager") OR (process == "MobileSoftwareUpdateUpdateBrainService") OR (process == "mdmclient") OR (process == "SecurityAgent") OR (process == "authorizationhost")' \
  > "$TMPFILE" 2>/dev/null

echo "Log extract saved to: $TMPFILE"
echo

echo "## 6. Key software update lines"
grep -iE 'installAuth=|standard-user|system.install.apple-software|SUUpdateServiceClient|restartingForDoItLaterUpdate|requestedPMV|Chose on-console client|currentOSType' "$TMPFILE" | tail -200
echo

echo "## 7. MDM-related lines"
grep -iE 'mdm|com.apple.mdm|managed|scheduleOSUpdate|InstallASAP|defer|deadline' "$TMPFILE" | tail -200
echo

echo "## 8. User authentication lines"
grep -iE 'SecurityAgent|authorizationhost|Authentication succeeded|LocalAuthentication|Prelogin user|granted authorization' "$TMPFILE" | tail -200
echo

echo "## 9. Restart countdown lines"
grep -iE 'RestartCountdown|SoftwareUpdateNotificationManager|DoItLater|restart required|restarting' "$TMPFILE" | tail -200
echo

CLASSIFICATION="Inconclusive"
REASON="No clear indicators found."

if grep -qiE 'mdmclient|scheduleOSUpdate|InstallASAP|managed|com.apple.mdm' "$TMPFILE"; then
  CLASSIFICATION="Likely MDM-initiated"
  REASON="Found mdmclient or managed update indicators."
elif grep -qiE 'installAuth=YES.*system\.install\.apple-software\.standard-user' "$TMPFILE" && \
     ! grep -qiE 'SecurityAgent.*Authentication succeeded|authorizationhost.*granted authorization' "$TMPFILE"; then
  CLASSIFICATION="Likely automatic or MDM-initiated"
  REASON="Install rights were granted without clear manual authentication evidence."
elif grep -qiE 'SecurityAgent|authorizationhost|LocalAuthentication' "$TMPFILE" && \
     grep -qiE 'system\.install\.apple-software' "$TMPFILE"; then
  CLASSIFICATION="Possibly user-initiated"
  REASON="Authentication activity exists near software update processing."
elif grep -qiE 'SoftwareUpdateNotificationManager|RestartCountdown' "$TMPFILE"; then
  CLASSIFICATION="Likely policy-driven restart"
  REASON="Restart countdown behavior was observed."
fi

echo "## 10. Classification"
echo "Classification : $CLASSIFICATION"
echo "Reason         : $REASON"
echo
echo "Report saved to: $REPORT"