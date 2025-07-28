#!/bin/sh

# Usage: ./serve_reolink.sh <input_rtsp> <mtx_path> <rtsp_port>

INPUT_RTSP="$1"
MTX_PATH="$2"
RTSP_PORT="$3"

if [ -z "$INPUT_RTSP" ] || [ -z "$MTX_PATH" ] || [ -z "$RTSP_PORT" ]; then
    echo "Usage: $0 <input_rtsp> <mtx_path> <rtsp_port>"
    exit 1
fi

# Try to run the following command, if it fails, start the no_signal.sh script
if ! ffmpeg -loglevel error -hide_banner \
    -rtsp_transport tcp \
    -i "$INPUT_RTSP" \
    -c copy \
    -f rtsp rtsp://127.0.0.1:$RTSP_PORT/"$MTX_PATH"; then
    /scripts/no_signal.sh rtsp "$MTX_PATH"
fi
