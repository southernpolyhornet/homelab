#!/bin/sh

INPUT_RTSP="$1"
OUTPUT_TYPE="$2"
OUTPUT="$3"
SOURCE_NAME="$4"

HLS_DIR=/hls
NO_SIGNAL=/scripts/ffmpeg/no_signal.sh

if [ -z "$INPUT_RTSP" ] || [ -z "$OUTPUT_TYPE" ] || [ -z "$OUTPUT" ] || [ -z "$SOURCE_NAME" ]; then
    echo "Usage: $0 <input_rtsp> <output_type> <output> <source_name>"
    exit 1
fi

test_rtsp_connection() {
    local input_rtsp="$1"
    timeout 5 ffprobe -v quiet -print_format json -show_streams -rtsp_transport tcp "$input_rtsp" >/dev/null 2>&1
}

stream_rtsp_to_rtsp() {
    local input_rtsp="$1"
    local output_rtsp="$2"
    ffmpeg -loglevel error -hide_banner \
        -rtsp_transport tcp \
        -i "$input_rtsp" \
        -c:v libx264 -preset ultrafast -tune zerolatency \
        -f rtsp "$output_rtsp"
}

stream_rtsp_to_hls() {
    local input_rtsp="$1"
    local source_name="$2"

    local output_dir="$HLS_DIR/$source_name"

    mkdir -p "$output_dir"

    ffmpeg -loglevel error -hide_banner \
        -rtsp_transport tcp \
        -i "$input_rtsp" \
        -c:v libx264 -preset ultrafast -tune zerolatency \
        -f hls "$output_dir/playlist.m3u8"
}

no_signal_to_rtsp() {
    local output_rtsp="$2"

    "$NO_SIGNAL" "$SOURCE_NAME" | \
    ffmpeg -loglevel error -hide_banner -i - \
        -c:v libx264 -preset ultrafast -tune zerolatency \
        -f rtsp "$output_rtsp"
}

no_signal_to_hls() {
    local source_name="$1"

    local output_dir="$HLS_DIR/$source_name"

    mkdir -p "$output_dir"

    "$NO_SIGNAL" "$SOURCE_NAME" | \
    ffmpeg -loglevel error -hide_banner -i - \
        -c:v libx264 -preset ultrafast -tune zerolatency \
        -f hls "$output_dir/playlist.m3u8"
}

echo "Starting RTSP failsafe"

# Function to start streaming process
start_stream() {
    local is_live="$1"
    local pid_file="/tmp/rtsp_failsafe_${SOURCE_NAME}.pid"
    
    # Kill existing process if running
    if [ -f "$pid_file" ]; then
        local old_pid=$(cat "$pid_file")
        if kill -0 "$old_pid" 2>/dev/null; then
            echo "Killing existing stream process: $old_pid"
            kill "$old_pid"
            sleep 1
        fi
        rm -f "$pid_file"
    fi
    
    # Start new stream in background
    if [ "$is_live" = "true" ]; then
        echo "RTSP reachable — starting live stream"
        case "$OUTPUT_TYPE" in
            "rtsp")
                stream_rtsp_to_rtsp "$INPUT_RTSP" "$OUTPUT" &
                ;;
            "hls")
                stream_rtsp_to_hls "$INPUT_RTSP" "$SOURCE_NAME" &
                ;;
            *)
                echo "Unknown output type: $OUTPUT_TYPE"
                exit 1
                ;;
        esac
    else
        echo "RTSP not reachable — starting fallback stream"
        case "$OUTPUT_TYPE" in
            "rtsp")
                no_signal_to_rtsp "$SOURCE_NAME" "$OUTPUT" &
                ;;
            "hls")
                no_signal_to_hls "$SOURCE_NAME" &
                ;;
            *)
                echo "Unknown output type: $OUTPUT_TYPE"
                exit 1
                ;;
        esac
    fi
    
    # Save PID and mode
    echo $! > "$pid_file"
    set_current_mode "$is_live"
    echo "Started stream process: $! (PID saved to $pid_file, mode: $is_live)"
}

# Function to check if stream process is still running
is_stream_running() {
    local pid_file="/tmp/rtsp_failsafe_${SOURCE_NAME}.pid"
    if [ -f "$pid_file" ]; then
        local pid=$(cat "$pid_file")
        if kill -0 "$pid" 2>/dev/null; then
            return 0  # Process is running
        else
            echo "Stream process $pid is no longer running"
            rm -f "$pid_file"
        fi
    fi
    return 1  # Process is not running
}

# Function to get current stream mode
get_current_mode() {
    local mode_file="/tmp/rtsp_failsafe_${SOURCE_NAME}.mode"
    if [ -f "$mode_file" ]; then
        cat "$mode_file"
    else
        echo "unknown"
    fi
}

# Function to set current stream mode
set_current_mode() {
    local mode="$1"
    local mode_file="/tmp/rtsp_failsafe_${SOURCE_NAME}.mode"
    echo "$mode" > "$mode_file"
}

while true; do
    echo "Testing RTSP connection..."
    test_rtsp_connection "$INPUT_RTSP"
    rtsp_available=$?

    # Check if we need to start/restart stream
    if ! is_stream_running; then
        if [ $rtsp_available -eq 0 ]; then
            start_stream "true"
        else
            start_stream "false"
        fi
    else
        # Stream is running, check if we need to switch modes
        pid_file="/tmp/rtsp_failsafe_${SOURCE_NAME}.pid"
        current_pid=$(cat "$pid_file")
        current_mode=$(get_current_mode)
        
        # Check if we need to switch from fallback to live or vice versa
        should_switch=false
        new_mode=""
        
        if [ $rtsp_available -eq 0 ]; then
            # RTSP is available - check if we're currently running fallback
            if [ "$current_mode" = "false" ]; then
                echo "RTSP available - switching from fallback to live stream (PID: $current_pid)"
                should_switch=true
                new_mode="true"
            else
                echo "RTSP available and live stream running (PID: $current_pid)"
            fi
        else
            # RTSP is not available - check if we're currently running live
            if [ "$current_mode" = "true" ]; then
                echo "RTSP unavailable - switching from live to fallback stream (PID: $current_pid)"
                should_switch=true
                new_mode="false"
            else
                echo "RTSP unavailable and fallback stream running (PID: $current_pid)"
            fi
        fi
        
        if [ "$should_switch" = "true" ]; then
            echo "Switching stream mode..."
            start_stream "$new_mode"
        fi
    fi

    sleep 5
done