#!/bin/bash

clear

echo "PENTAGON // UPDATE"
echo
echo "→ Initializing system update..."
echo "→ Syncing package repositories..."
echo

sudo pacman -Syu

echo
echo "→ Update process complete."
echo
read -rp "Press Enter to close..."
