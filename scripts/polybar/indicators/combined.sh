#!/bin/bash

STATE_DIR="$HOME/.local/state/dwm/indicators"
mkdir -p "$STATE_DIR"

while true; do
  out=""

  count=$(cat "$STATE_DIR/update-count" 2>/dev/null)
  if (( count > 0 )); then
    out+="%{A1:dwm-launch-update:} $count%{A} "
  fi

  sr_state="$(cat "$STATE_DIR/screen-recording" 2>/dev/null || echo "inactive")"
  if [[ "$sr_state" == "active" ]]; then
    out+="%{A1:dwm-cmd-screenrecord start:}%{F#a55555}󰻂%{F-}%{A} "
  fi

  idle_state="$(cat "$STATE_DIR/idle" 2>/dev/null || echo "enabled")"
  if [[ "$idle_state" == "disabled" ]]; then
    out+="%{A1:dwm-toggle-idle:}%{F#a55555}󱫖%{F-}%{A} "
  fi

  dnd_state="$(cat "$STATE_DIR/dnd" 2>/dev/null || echo "enabled")"
  if [[ "$dnd_state" == "disabled" ]]; then
    out+="%{A1:dwm-toggle-notifications:}%{F#a55555}󰂛%{F-}%{A} "
  fi

  echo "$out"
  inotifywait -q -e close_write,attrib,create,delete "$STATE_DIR" >/dev/null 2>&1 || true
done
