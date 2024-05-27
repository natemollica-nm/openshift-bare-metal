#!/usr/bin/env bash

SCRIPT_NAME=$(basename "$0")

eval "$(cat /usr/sbin/scripting/logging.sh)"
eval "$(cat /usr/sbin/scripting/formatting.env)"

# Get a list of all connections with their UUIDs and states
all_connections=$(nmcli -t -f UUID,DEVICE connection show)

# Filter out the inactive connections
inactive_connections=$(echo "$all_connections" | awk -F: '$2 == "" {print $1}')

# Check if there are any inactive connections
if [ -z "$inactive_connections" ]; then
  log "$SCRIPT_NAME: No inactive connections found, exiting..."
  exit
fi

# Loop through each inactive connection and delete it by UUID
for uuid in $inactive_connections; do
  log "$SCRIPT_NAME: Deleting inactive connection with UUID: $uuid"
  nmcli connection delete uuid "$uuid" >/dev/null 2>&1 || {
    warn "$SCRIPT_NAME: Failed to delete connection '$uuid'!"
  }
done

log "$SCRIPT_NAME: done!"
