#!/bin/bash

PIPE="/tmp/dwm-tags-pipe"
[ -p "$PIPE" ] || mkfifo "$PIPE"

fuser -k "$PIPE" 2>/dev/null

xprop -root -spy _NET_CURRENT_DESKTOP > "$PIPE" 2>/dev/null &
xprop -root -spy _DWM_LAYOUT > "$PIPE" 2>/dev/null &
xprop -root -spy _DWM_OCCUPIED_TAGS > "$PIPE" 2>/dev/null &

LAYOUT="[]="
CURRENT=0
OCCUPIED=0

while read -r line; do
  case "$line" in
    *"_NET_CURRENT_DESKTOP"*)
      CURRENT="${line##* }"
      ;;
    *"_DWM_LAYOUT"*)
      raw="${line#*= }"
      LAYOUT="${raw%\"}"
      LAYOUT="${LAYOUT#\"}"
      ;;
    *"_DWM_OCCUPIED_TAGS"*)
      OCCUPIED="${line##* }"
      ;;
  esac

  first=true
  for i in 0 1 2 3 4 5 6 7 8; do
    (( i >= 5 && i != CURRENT && !(OCCUPIED & (1 << i)) )) && continue
    t=$((i + 1))
    ! $first && echo -n " "
    first=false
    click="%{A1:xdotool key super+${t}:}"
    close="%{A}"
    if (( OCCUPIED & (1 << i) )); then
      fg=""
    else
      fg="%{F#999}"
    fi
    if (( CURRENT == i )); then
      echo -n "${click}${fg}%{F-}${close}"
    else
      echo -n "${click}${fg}${t}%{F-}${close}"
    fi
  done
  echo " ${LAYOUT}"
done < "$PIPE"
