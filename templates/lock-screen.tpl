#!/bin/bash

DWM_PATH="$(cd "$(dirname "$0")/../.." && pwd)"
LOCK_IMG="$DWM_PATH/themes/current/lock-blur.png"

if [[ -f "$LOCK_IMG" ]]; then
	i3lock -i "$LOCK_IMG" \
		--inside-color=00000000 \
		--ring-color={{ accent }} \
		--insidever-color=00000000 \
		--ringver-color={{ accent }} \
		--insidewrong-color=00000000 \
		--ringwrong-color={{ color1 }} \
		--line-color=00000000 \
		--keyhl-color=ffffff \
		--bshl-color={{ color1 }} \
		--separator-color=00000000 \
		--verif-color=ffffff \
		--wrong-color={{ color1 }} \
		--time-color=ffffff \
		--date-color=ffffff \
		--layout-color=ffffff
else
	i3lock --color={{ background }} \
		--inside-color=00000000 \
		--ring-color={{ accent }} \
		--insidever-color=00000000 \
		--ringver-color={{ accent }} \
		--insidewrong-color=00000000 \
		--ringwrong-color={{ color1 }} \
		--line-color=00000000 \
		--keyhl-color=ffffff \
		--bshl-color={{ color1 }} \
		--separator-color=00000000 \
		--verif-color=ffffff \
		--wrong-color={{ color1 }} \
		--time-color=ffffff \
		--date-color=ffffff \
		--layout-color=ffffff
fi
