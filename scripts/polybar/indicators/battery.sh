#!/bin/bash

DWM="$(cd "$(dirname "$0")/../../.." && pwd)"

BAT="/sys/class/power_supply/BAT0"
AC="/sys/class/power_supply/ADP0/online"

cap=$(cat "$BAT/capacity")
status=$(cat "$BAT/status")
ac=$(cat "$AC")

CLICK='%{A1:notify-send "Battery" "$(cat /sys/class/power_supply/BAT0/capacity)%":}%{A3:dwm-battery-status:}'
CLICK_END='%{A}%{A}'

POLY_RED=$(awk -F'= ' '/^red/ {print $2}' "$DWM/themes/current/polybar.ini")

if [ "$cap" -le 15 ] && [ "$ac" -eq 0 ]; then
    echo "${CLICK}%{F${POLY_RED}}󱃍%{F-}${CLICK_END}"
    exit
fi

if [ "$ac" -eq 1 ] && [ "$status" != "Charging" ]; then
    echo "${CLICK}${CLICK_END}"
    exit
fi

if [ "$status" = "Charging" ]; then
    f="/tmp/battery-charge-frame"
    n=0; [ -f "$f" ] && n=$(cat "$f")
    n=$(( (n+1) % 5 )); echo "$n" > "$f"
    case $n in
        0) i="󰢜" ;; 1) i="󰂇" ;; 2) i="󰢝" ;; 3) i="󰢞" ;; 4) i="󰂅" ;;
    esac
    echo "${CLICK}${i}${CLICK_END}"
    exit
fi

if [ "$cap" -le 20 ]; then
    i="󰁻"
elif [ "$cap" -le 40 ]; then
    i="󰁽"
elif [ "$cap" -le 60 ]; then
    i="󰁿"
elif [ "$cap" -le 80 ]; then
    i="󰂁"
else
    i="󰁹"
fi

echo "${CLICK}${i}${CLICK_END}"
