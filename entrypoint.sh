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
  echo "Checking if Twitch is receiving the stream..."

  if ! ffprobe -i "rtmp://live.twitch.tv/app/$TWITCH_KEY" -show_streams -loglevel error > /dev/null 2>&1; then
    echo "Twitch stream is down. Restarting FFmpeg..."

    pkill -9 ffmpeg || true  # Kill any existing ffmpeg process

    ffmpeg -re -i "$STREAM_URL" \
      -c:v libx264 -preset veryfast -b:v 3000k -maxrate 3000k -bufsize 6000k \
      -c:a aac -b:a 128k -ar 44100 \
      -f flv "rtmp://live.twitch.tv/app/$TWITCH_KEY" \
      -rtmp_live persist \
      -loglevel error &

    pid=$!
    echo "FFmpeg started with PID: $pid"
    wait $pid
  else
    echo "Twitch is live. Checking again in 30 seconds..."
  fi

  sleep 30
done
