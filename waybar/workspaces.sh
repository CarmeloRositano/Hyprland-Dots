#!/bin/bash

# ---- HANDLE SCROLL ----
if [ "$1" = "up" ]; then
    hyprctl dispatch workspace e+1 >/dev/null 2>&1
    exit 0
elif [ "$1" = "down" ]; then
    hyprctl dispatch workspace e-1 >/dev/null 2>&1
    exit 0
fi

# ---- GET ACTIVE WORKSPACE ----
ACTIVE=$(hyprctl activeworkspace -j 2>/dev/null | jq -r '.id')

[ -z "$ACTIVE" ] && exit 0

# ---- GET ALL WORKSPACES ----
WORKSPACES=$(hyprctl workspaces -j 2>/dev/null |
    jq -r '.[].id' |
    sort -n)

[ -z "$WORKSPACES" ] && exit 0

# ---- FORMAT WORKSPACES ----
TEXT=""

while read -r WS; do
    if [ "$WS" = "$ACTIVE" ]; then
        TEXT+="[${WS}]"
    else
        TEXT+=" ${WS} "
    fi
done <<< "$WORKSPACES"

# Remove trailing space
TEXT="${TEXT% }"

echo "{\"text\":\"$TEXT\",\"tooltip\":\"Active Workspace: $ACTIVE\"}"
