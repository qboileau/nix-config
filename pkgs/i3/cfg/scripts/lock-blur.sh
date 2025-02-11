#!/usr/bin/env bash

rm -f /tmp/screenshot.png /tmp/screenshotblur.png
scrot /tmp/screenshot.png
magick convert /tmp/screenshot.png -blur 0x5 /tmp/screenshotblur.png
i3lock -i /tmp/screenshotblur.png
