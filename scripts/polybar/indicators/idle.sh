#!/bin/bash
# Polybar indicator: idle auto-lock state
#
# Reads state from $STATE_FILE (written by dwm-toggle-idle/autostart.sh).
# Shows a red 󱫖 icon when disabled, nothing when enabled.
# Uses tail -F to react to live state changes.

STATE_DIR="$HOME/.local/state/dwm/indicators"
STATE_FILE="$STATE_DIR/idle"

mkdir -p "$STATE_DIR"
if [[ ! -f $STATE_FILE ]]; then
	if [[ -f /tmp/xautolock.pid ]] && kill -0 "$(cat /tmp/xautolock.pid 2>/dev/null)" 2>/dev/null; then
		echo "enabled" > "$STATE_FILE"
	else
		echo "disabled" > "$STATE_FILE"
	fi
fi

(cat "$STATE_FILE" 2>/dev/null; tail -F "$STATE_FILE" 2>/dev/null) | while read -r line; do
	if [[ $line == "disabled" ]]; then
		echo "%{F#a55555}󱫖%{F-}"
	else
		echo ""
	fi
done
