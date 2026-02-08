#!/bin/bash

# Change to script directory to ensure relative paths work
cd "$(dirname "$0")"

# Get unread email count
count=$(./inbox_unread_count.sh)

# Prepare waybar JSON output
if [ "$count" -gt 0 ]; then
    echo "{\"text\": \"$count\", \"tooltip\": \"$count unread emails\", \"class\": \"unread\"}"
else
    echo "{\"text\": \"0\", \"tooltip\": \"No unread emails\", \"class\": \"read\"}"
fi