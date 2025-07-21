#!/bin/sh

# This script will stream a no signal video with scanlines overlay.

# Usage: ./no_signal.sh <source_name>

# Check if required arguments are provided
if [ $# -lt 1 ]; then
    echo "Usage: $0 <source_name>" >&2
    exit 1
fi

SOURCE_NAME=$(echo "$1" | tr '[:lower:]' '[:upper:]')
if [ -z "$SOURCE_NAME" ]; then
    SOURCE_NAME="<UNKNOWN>"
fi

# Check if assets exist
if [ ! -f "/assets/no_signal.png" ]; then
    echo "Error: /assets/no_signal.png not found" >&2
    exit 1
fi

if [ ! -f "/assets/scan.mp4" ]; then
    echo "Error: /assets/scan.mp4 not found" >&2
    exit 1
fi

if [ ! -f "/assets/fonts/VCR_OSD_MONO.ttf" ]; then
    echo "Error: /assets/fonts/VCR_OSD_MONO.ttf not found" >&2
    exit 1
fi

# Stream the no signal video with scanlines overlay
ffmpeg \
    -loglevel error \
    -hide_banner \
    -loop 1 \
    -i /assets/no_signal.png \
    -stream_loop -1 \
    -i /assets/scan.mp4 \
    -filter_complex "\
        [1:v]format=rgba,colorchannelmixer=aa=0.2[scanlines];\
        [0:v][scanlines]overlay=0:0:shortest=1,\
        drawtext=fontfile=/assets/fonts/VCR_OSD_MONO.ttf:text='${SOURCE_NAME}':\
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
