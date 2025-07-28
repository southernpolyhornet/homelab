#!/bin/sh

# Usage: ./streamlink_rtsp.sh <url> <rtsp_port> <mtx_path>

URL="$1"
RTSP_PORT="$2"
MTX_PATH="$3"
LOG_FILE="/var/log/supervisor/streamlink_${MTX_PATH}.log"

# Create log directory if it doesn't exist
mkdir -p /var/log/supervisor

# Log function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

if [ -z "$URL" ] || [ -z "$RTSP_PORT" ] || [ -z "$MTX_PATH" ]; then
    log "ERROR: Missing required parameters"
    log "Usage: $0 <url> <rtsp_port> <mtx_path>"
    log "Received: URL='$URL', RTSP_PORT='$RTSP_PORT', MTX_PATH='$MTX_PATH'"
    exit 1
fi

log "Starting streamlink_rtsp.sh for $MTX_PATH"
log "Source URL: $URL"
log "Output RTSP: rtsp://127.0.0.1:$RTSP_PORT/$MTX_PATH"
log "Log file: $LOG_FILE"

# Test if streamlink is available
if ! command -v streamlink >/dev/null 2>&1; then
    log "ERROR: streamlink not found"
    exit 1
fi

# Test if ffmpeg is available
if ! command -v ffmpeg >/dev/null 2>&1; then
    log "ERROR: ffmpeg not found"
    exit 1
fi

log "Starting streamlink -> ffmpeg pipeline"
streamlink "$URL" best --stdout 2>> "$LOG_FILE" | \
ffmpeg -nostdin -loglevel info -hide_banner -re -i - -c:v copy -c:a aac -f rtsp "rtsp://127.0.0.1:$RTSP_PORT/$MTX_PATH" >> "$LOG_FILE" 2>&1

log "Stream ended"
