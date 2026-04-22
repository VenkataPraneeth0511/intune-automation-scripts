#!/bin/bash

echo "==== Admin Users Audit ===="

# Get admin group users
admins=$(dscl . -read /Groups/admin GroupMembership)

echo "Admin Users:"
echo "$admins"

echo "=========================="