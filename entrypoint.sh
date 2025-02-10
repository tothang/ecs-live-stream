#!/bin/bash
set -e

echo "Checking environment variables..."
env | grep -E 'STREAM_URL|TWITCH_KEY'

if [[ -z "$STREAM_URL" || -z "$TWITCH_KEY" ]]; then
  echo "Error: STREAM_URL or TWITCH_KEY is not set!"
  exit 1
fi

echo "Starting FFmpeg streaming..."

while true; do
  echo "Killing any previous FFmpeg instances..."
  pkill -9 ffmpeg || true  # Kill any existing ffmpeg process

  echo "Starting FFmpeg..."
  ffmpeg -re -i "$STREAM_URL" \
    -c:v libx264 -preset veryfast -b:v 3000k -maxrate 3000k -bufsize 6000k \
    -c:a aac -b:a 128k -ar 44100 \
    -f flv "rtmp://live.twitch.tv/app/$TWITCH_KEY" \
    -rtmp_live persist \
    -loglevel error &

  pid=$!
  echo "FFmpeg started with PID: $pid"

  wait $pid
  echo "FFmpeg stopped. Restarting in 15 seconds..."
  sleep 15
done