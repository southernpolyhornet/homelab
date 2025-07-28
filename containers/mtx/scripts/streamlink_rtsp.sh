#!/bin/sh

streamlink "$1" best --stdout | ffmpeg -nostdin -hide_banner -re -i - -c:v copy -c:a aac -f rtsp "rtsp://127.0.0.1:$2/$3"
