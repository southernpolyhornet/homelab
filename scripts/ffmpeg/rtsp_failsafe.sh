#!/bin/sh

INPUT_RTSP="$1"
OUTPUT="$2"

if [ -z "$INPUT_RTSP" ] || [ -z "$OUTPUT" ]; then
    echo "Usage: $0 <input_rtsp> <output>"
    exit 1
fi

SOURCE_NAME=$(echo "$OUTPUT" | sed -E 's|^rtsp://[^/]+||' | sed 's|/| |g' | sed 's/^ //' | tr '[:lower:]' '[:upper:]')
[ -z "$SOURCE_NAME" ] && SOURCE_NAME="UNKNOWN"

SCRIPT_DIR="$(dirname "$0")"

echo "Starting RTSP failsafe for: $INPUT_RTSP -> $OUTPUT"

while true; do
    echo "Testing RTSP connection to $INPUT_RTSP"
    timeout 5 ffprobe -v quiet -print_format json -show_streams -rtsp_transport tcp "$INPUT_RTSP" >/dev/null 2>&1

    if [ $? -eq 0 ]; then
        echo "RTSP reachable — streaming live"
        ffmpeg -loglevel error -hide_banner \
            -rtsp_transport tcp \
            -i "$INPUT_RTSP" \
            -c:v libx264 -preset ultrafast -tune zerolatency \
            -f rtsp "$OUTPUT"
        echo "Live stream ended or errored, retrying in 5s..."
    else
        echo "RTSP not reachable — starting fallback"
        "$SCRIPT_DIR/no_signal.sh" "$SOURCE_NAME" | \
        ffmpeg -loglevel error -hide_banner \
            -i - \
            -c:v libx264 -preset ultrafast -tune zerolatency \
            -f rtsp "$OUTPUT"
        echo "Fallback ended or errored, retrying in 5s..."
    fi

    sleep 5
done