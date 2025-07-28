#!/bin/sh

# Usage: ./serve_reolink.sh <input_rtsp> <mtx_path> <rtsp_port>

INPUT_RTSP="$1"
MTX_PATH="$2"
RTSP_PORT="$3"
LOG_FILE="/var/log/supervisor/reolink_${MTX_PATH}.log"

# Create log directory if it doesn't exist
mkdir -p /var/log/supervisor

# Log function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

if [ -z "$INPUT_RTSP" ] || [ -z "$MTX_PATH" ] || [ -z "$RTSP_PORT" ]; then
    log "ERROR: Missing required parameters"
    log "Usage: $0 <input_rtsp> <mtx_path> <rtsp_port>"
    log "Received: INPUT_RTSP='$INPUT_RTSP', MTX_PATH='$MTX_PATH', RTSP_PORT='$RTSP_PORT'"
    exit 1
fi

log "Starting serve_reolink.sh for $MTX_PATH"
log "Input RTSP: $INPUT_RTSP"
log "Output RTSP: rtsp://127.0.0.1:$RTSP_PORT/$MTX_PATH"
log "Log file: $LOG_FILE"

# Test RTSP connection first
log "Testing RTSP connection to $INPUT_RTSP"
if timeout 10 ffprobe -v quiet -print_format json -show_streams -rtsp_transport tcp "$INPUT_RTSP" >/dev/null 2>&1; then
    log "RTSP connection successful"
else
    log "ERROR: RTSP connection failed - starting no_signal fallback"
    /scripts/no_signal.sh rtsp "$MTX_PATH"
    exit 1
fi

# Try to run the ffmpeg command with detailed logging
log "Starting ffmpeg stream"
if ! ffmpeg -loglevel info -hide_banner \
    -rtsp_transport tcp \
    -i "$INPUT_RTSP" \
    -c copy \
    -f rtsp rtsp://127.0.0.1:$RTSP_PORT/"$MTX_PATH" 2>&1 | tee -a "$LOG_FILE"; then
    log "ERROR: ffmpeg failed - starting no_signal fallback"
    /scripts/no_signal.sh rtsp "$MTX_PATH"
else
    log "ffmpeg stream ended normally"
fi
