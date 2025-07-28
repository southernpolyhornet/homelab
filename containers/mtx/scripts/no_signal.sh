#!/bin/sh

# This script will stream a no signal video with scanlines overlay.

# Usage: ./no_signal.sh <output> Optional:<source_name>

BACKGROUND_IMAGE="/assets/no_signal.png"
SCAN_VIDEO="/assets/scan.mp4"
FONT_FILE="/assets/fonts/VCR_OSD_MONO.ttf"

if [ ! -f "$BACKGROUND_IMAGE" ]; then
    echo "Error: $BACKGROUND_IMAGE not found" >&2
    exit 1
fi
if [ ! -f "$SCAN_VIDEO" ]; then
    echo "Error: $SCAN_VIDEO not found" >&2
    exit 1
fi
if [ ! -f "$FONT_FILE" ]; then
    echo "Error: $FONT_FILE not found" >&2
    exit 1
fi

if [ $# -lt 1 ]; then
    echo "Usage: $0 <output> Optional:<source_name>" >&2
    exit 1
fi

OUTPUT="$1"
SOURCE_NAME=$(echo "$2" | tr '[:lower:]' '[:upper:]')

run() {
    ffmpeg -loglevel error -hide_banner \
        -loop 1 \
        -i "$BACKGROUND_IMAGE" \
        -stream_loop -1 \
        -i "$SCAN_VIDEO" \
        -filter_complex "[1:v]format=rgba,colorchannelmixer=aa=0.2[scanlines];[0:v][scanlines]overlay=0:0:shortest=1, \
        drawtext=fontfile=$FONT_FILE:text='${SOURCE_NAME}':fontcolor=white:fontsize=24:x=20:y=20:shadowcolor=black:shadowx=2:shadowy=2" \
        -c:v libx264 -preset ultrafast -tune zerolatency -vsync 1 "$@"
}

rtsp_output() {
    run -f rtsp rtsp://127.0.0.1:8554/"$1"
}

rawvideo_output() {
    run -f rawvideo -
}

case "$OUTPUT" in
    rtsp)
        rtsp_output "$SOURCE_NAME"
        ;;
    rawvideo)
        rawvideo_output
        ;;
    ffplay)
        rawvideo_output | ffplay -hide_banner -
        ;;
    mpegts)
        run -f mpegts -
        ;;
    *)
        run "$OUTPUT"
        ;;
esac