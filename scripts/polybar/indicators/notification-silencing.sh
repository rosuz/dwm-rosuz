#!/bin/bash

# Polybar indicator: notification silencing / DND state
STATE_DIR="$HOME/.local/state/dwm/indicators"
STATE_FILE="$STATE_DIR/notification-silencing"

mkdir -p "$STATE_DIR"
[[ -f $STATE_FILE ]] || echo "inactive" > "$STATE_FILE"

(cat "$STATE_FILE" 2>/dev/null; tail -F "$STATE_FILE" 2>/dev/null) | while read -r line; do
  if [[ $line == "active" ]]; then
    echo "%{F#a55555}󰂛%{F-}"
  else
    echo ""
  fi
done
