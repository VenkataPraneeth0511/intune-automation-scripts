#!/bin/bash

# Path to downloaded JNLP file or directory
TARGET="/Users/*/Downloads"

# Remove quarantine attribute from all JNLP files
find $TARGET -name "*.jnlp" -exec xattr -d com.apple.quarantine {} \; 2>/dev/null

# Optional: Trust OpenWebStart or Java (if installed)
JAVA_PATH="/Applications/OpenWebStart.app"
if [ -d "$JAVA_PATH" ]; then
    xattr -dr com.apple.quarantine "$JAVA_PATH"
fi

echo "SAP ESR/ID whitelist applied successfully"