#!/bin/bash

STATE_FILE="/tmp/dwm-tray-state"
TRAY_WIN=$(xdotool search --classname polybar-tray 2>/dev/null | head -1)
[ -z "$TRAY_WIN" ] && TRAY_WIN=$(xdotool search --class polybar-tray 2>/dev/null | head -1)
[ -z "$TRAY_WIN" ] && exit

xdotool getwindowstate "$TRAY_WIN" 2>/dev/null | grep -q "1" && {
    xdotool windowunmap "$TRAY_WIN"
    echo "hidden" > "$STATE_FILE"
} || {
    xdotool windowmap "$TRAY_WIN"
    echo "visible" > "$STATE_FILE"
}
