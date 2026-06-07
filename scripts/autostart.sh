#!/bin/bash

DWM_PATH="$(cd "$(dirname "$0")/.." && pwd)"

# Restore keyboard and touchpad settings
if [ -f "$HOME/.config/dwm/dwm-input-config" ]; then
  . "$HOME/.config/dwm/dwm-input-config"
  setxkbmap -layout "$kbd_layout" ${kbd_variant:+-variant "$kbd_variant"}

  TPAD=$(xinput list --name-only 2>/dev/null | while read -r dev; do
    xinput list-props "$dev" 2>/dev/null | grep -q "libinput Tapping Enabled" && echo "$dev" && break
  done)
  if [ -n "$TPAD" ]; then
    [ "$touchpad_tap" = 1 ]     && xinput set-prop "$TPAD" "libinput Tapping Enabled" 1
    [ "$touchpad_natural" = 1 ] && xinput set-prop "$TPAD" "libinput Natural Scrolling Enabled" 1
    [ "$touchpad_dwt" = 1 ]     && xinput set-prop "$TPAD" "libinput Disable While Typing Enabled" 1
  fi
fi

# Set wallpaper
if command -v feh >/dev/null 2>&1; then
  if [[ -f "$DWM_PATH/themes/current/background" ]]; then
    feh --bg-scale "$DWM_PATH/themes/current/background"
  else
    "$DWM_PATH/scripts/dwm-theme-bg-next"
  fi
fi

# Generate lock-blur.png if missing (e.g. after tty install)
if [[ ! -f "$DWM_PATH/themes/current/lock-blur.png" ]] && command -v magick >/dev/null 2>&1 && [[ -f "$DWM_PATH/themes/current/background" ]]; then
    read -r W H <<< "$(xrandr --current | grep '*' | head -1 | awk '{print $1}' | tr 'x' ' ')"
    magick "$DWM_PATH/themes/current/background" \
        -resize "${W}x${H}^" -gravity center -extent "${W}x${H}" -blur 0x8 \
        "$DWM_PATH/themes/current/lock-blur.png" &
fi

# Start notification daemon
if command -v dunst >/dev/null 2>&1; then
  dunst &
fi

# Start clipboard manager
if command -v greenclip >/dev/null 2>&1; then
  greenclip daemon &
fi

# Start idle daemon
if command -v xautolock >/dev/null 2>&1 && command -v "$DWM_PATH/scripts/dwm-lock-screen" >/dev/null 2>&1; then
  xautolock -time 5 -locker "$DWM_PATH/scripts/dwm-lock-screen" -detectsleep &
  PIDFILE=/tmp/xautolock.pid
  echo $! > "$PIDFILE"
  mkdir -p "$HOME/.local/state/dwm/indicators"
  echo "enabled" > "$HOME/.local/state/dwm/indicators/idle"
fi

# Ensure dwm scripts are in PATH for bar click handlers
export PATH="$PATH:$DWM_PATH/scripts:$DWM_PATH/scripts/polybar"

# Launch Polybar per monitor
for m in $(polybar --list-monitors 2>/dev/null | cut -d: -f1); do
	MONITOR=$m polybar main &
done
