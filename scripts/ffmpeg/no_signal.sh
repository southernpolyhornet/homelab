#!/bin/bash

# This script will stream a no signal video with scanlines overlay.

# Usage: ./no_signal.sh <source_name>

SOURCE_NAME=$(echo "$1" | tr '[:lower:]' '[:upper:]')
if [ -z "$SOURCE_NAME" ]; then
    SOURCE_NAME="<UNKNOWN>"
fi

ffmpeg \
    -loglevel quiet \
    -hide_banner \
    -loop 1 \
    -i /assets/no_signal.png \
    -stream_loop -1 \
    -i /assets/scan.mp4 \
    -filter_complex "\
        [1:v]format=rgba,colorchannelmixer=aa=0.2[scanlines],\
        [0:v][scanlines]overlay=0:0:shortest=1,\
        drawtext=text='${SOURCE_NAME}':\
        fontcolor=white:\
        fontsize=24:\
        x=20:\
        y=20:\
        shadowcolor=black:\
        shadowx=2:\
        shadowy=2" \
    -c:v libx264 \
    -preset ultrafast \
    -tune zerolatency \
    -vsync 1 \
    -f mpegts -
