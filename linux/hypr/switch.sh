#!/usr/bin/env bash

if grep open /proc/acpi/button/lid/LID0/state; then
  hyprctl keyword monitor "eDP-1,2880x1800,240x1080,auto"
else
  # if laptop not connected to a external monitor, no need to disable internal display
  if [[ `hyprctl monitors | grep "Monitor" | wc -l` != 1 ]]; then
    hyprctl keyword monitor "eDP-1, disable"
  fi
fi

