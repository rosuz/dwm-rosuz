#!/bin/bash

# Polybar indicator: update availability
if command -v checkupdates >/dev/null 2>&1; then
  count=$(checkupdates 2>/dev/null | wc -l)
  if (( count > 0 )); then
    echo " $count"
  else
    echo ""
  fi
else
  echo ""
fi
