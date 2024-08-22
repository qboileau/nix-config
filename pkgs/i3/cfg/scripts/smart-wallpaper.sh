#!/bin/bash


NORMAL_WALLPAPERS_DIR="$HOME/Dropbox/wallpapers/1x1" 
WIDE_WALLPAPERS_DIR="$HOME/Dropbox/wallpapers/2x1" 
ULTRA_WIDE_WALLPAPERS_DIR="$HOME/Dropbox/wallpapers/3x1" 

# give "XxY ratio"
MONITORS_RES_RATIO=$(xrandr --listmonitors | awk '{print $3}' | awk -F'[/x+]' '$1{print $1"x"$3"|"$1/$3}')


WALLPAPERS=""
for MONITOR in $MONITORS_RES_RATIO; do

    RES=$(echo $MONITOR | awk -F'|' '{print $1}')
    RATIO=$(echo $MONITOR | awk -F'|' '{print $2}')

    WALLPAPER_DIR="$NORMAL_WALLPAPERS_DIR" #default
    if (( $(echo "$RATIO > 1.0" | bc -l) )); then
        if (( $(echo "$RATIO < 2.0" | bc -l) )); then
            echo "normal ratio $RES $RATIO"
            WALLPAPER_DIR="$NORMAL_WALLPAPERS_DIR"
        else
            if (( $(echo "$RATIO > 2.0" | bc -l) )); then
                if (( $(echo "$RATIO < 3.0" | bc -l) )); then
                    echo "Wide ratio $RES $RATIO"
                    WALLPAPER_DIR="$WIDE_WALLPAPERS_DIR"
                else
                    echo "Ultra wide ratio $RES $RATIO"
                    WALLPAPER_DIR="$ULTRA_WIDE_WALLPAPERS_DIR"
                fi
            fi
        fi
    fi
    
    RANDOM_WALLPAPER=$(find "$WALLPAPER_DIR" -type f | shuf -n 1)
    WALLPAPERS="$WALLPAPERS $RANDOM_WALLPAPER"
done

echo "Selected wallpapers : $WALLPAPERS"

feh --bg-fill $WALLPAPERS

