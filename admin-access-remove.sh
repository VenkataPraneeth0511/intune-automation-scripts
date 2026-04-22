#!/bin/bash

echo "==== Admin Auto-Remediation Script Started ===="

# ✅ Define approved admin users (EDIT THIS)
APPROVED_ADMINS=("Admin")

# Get current admin users
CURRENT_ADMINS=$(dscl . -read /Groups/admin GroupMembership | cut -d ":" -f2)

echo "Current Admins: $CURRENT_ADMINS"

# Loop through each admin user
for user in $CURRENT_ADMINS; do

    # Trim whitespace
    user=$(echo "$user" | xargs)

    # Skip empty values
    if [[ -z "$user" ]]; then
        continue
    fi

    # Check if user is in approved list
    if [[ " ${APPROVED_ADMINS[@]} " =~ " ${user} " ]]; then
        echo "✅ Approved admin: $user (no action)"
    else
        echo "⚠️ Removing admin rights from: $user"

        # Remove user from admin group
        dseditgroup -o edit -d "$user" -t user admin

        if [[ $? -eq 0 ]]; then
            echo "✔ Successfully removed admin rights from $user"
        else
            echo "❌ Failed to remove admin rights from $user"
        fi
    fi

done

echo "==== Script Completed ===="
