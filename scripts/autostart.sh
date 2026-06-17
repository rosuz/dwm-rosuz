#!/bin/bash

DWM_PATH="$(cd "$(dirname "$0")/.." && pwd)"

# Reset indicator state on startup (fresh state per boot)
rm -rf "$HOME/.local/state/dwm/indicators"

# Restore keyboard and touchpad settings
if [ -f "$HOME/.config/dwm/dwm-input-config" ]; then
  . "$HOME/.config/dwm/dwm-input-config"
  setxkbmap -layout "$kbd_layout" ${kbd_variant:+-variant "$kbd_variant"}

  TPAD=$(xinput list --name-only 2>/dev/null | while read -r dev; do
    xinput list-props "$dev" 2>/dev/null | grep -q "libinput Tapping Enabled" && echo "$dev" && break
  done)
  if [ -n "$TPAD" ]; then
    xinput set-prop "$TPAD" "libinput Tapping Enabled" "$touchpad_tap"
    xinput set-prop "$TPAD" "libinput Natural Scrolling Enabled" "$touchpad_natural"
    xinput set-prop "$TPAD" "libinput Disable While Typing Enabled" "$touchpad_dwt"
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
if command -v xautolock >/dev/null 2>&1; then
  "$DWM_PATH/scripts/dwm-toggle-idle" --enable --quiet
fi

# Start update check daemon
if command -v checkupdates >/dev/null 2>&1 || command -v yay >/dev/null 2>&1 || command -v flatpak >/dev/null 2>&1; then
  "$DWM_PATH/scripts/dwm-check-update" &
fi

# Start PiP position daemon
"$DWM_PATH/scripts/dwm-pip-position" &

# Start battery monitor daemon
"$DWM_PATH/scripts/dwm-battery-daemon" &

# Ensure dwm scripts are in PATH for bar click handlers
export PATH="$PATH:$DWM_PATH/scripts:$DWM_PATH/scripts/polybar"

# Launch Polybar per monitor
mapfile -t MONITORS < <(polybar --list-monitors 2>/dev/null | cut -d: -f1)
(( ${#MONITORS[@]} > 0 )) || exit 0
for m in "${MONITORS[@]}"; do
  [[ -n "$m" ]] || continue
  MONITOR="$m" polybar main >/dev/null 2>&1 &
done
