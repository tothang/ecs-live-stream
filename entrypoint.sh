#!/bin/bash
set -e

# Ensure required environment variables are set
if [[ -z "$STREAM_URL" || -z "$TWITCH_KEY" ]]; then
  echo "Error: STREAM_URL or TWITCH_KEY is not set!"
  exit 1
fi

echo "Starting FFmpeg streaming..."
ffmpeg -i "$STREAM_URL" -c:v libx264 -preset veryfast -b:v 3000k -maxrate 3000k -bufsize 6000k -c:a aac -b:a 128k -ar 44100 -f flv "rtmp://live.twitch.tv/app/$TWITCH_KEY"
