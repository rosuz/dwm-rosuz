#!/bin/bash

DWM="$(cd "$(dirname "$0")/../../.." && pwd)"
TOGGLE="$DWM/scripts/polybar/toggle-tray.sh"
STATE_FILE="/tmp/dwm-tray-state"

print_state() {
    local s=$(cat "$STATE_FILE" 2>/dev/null)
    if [ "$s" = "visible" ]; then
        echo "%{A1:$TOGGLE:}%{A}"
    else
        echo "%{A1:$TOGGLE:}%{A}"
    fi
}

mkdir -p /tmp
[ -f "$STATE_FILE" ] || echo "hidden" > "$STATE_FILE"
print_state
tail -F "$STATE_FILE" 2>/dev/null | while read -r; do print_state; done
