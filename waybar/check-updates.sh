#!/bin/sh

n=$(checkupdates 2>/dev/null | wc -l)

if [ "$n" -gt 0 ]; then
    printf '{"text":"●","class":"updates"}\n'
else
    printf '{"text":"","class":"no-updates"}\n'
fi
