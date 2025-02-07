#!/bin/bash
set -e

# Ensure required environment variables are set
if [[ -z "$STREAM_URL" || -z "$TWITCH_KEY" ]]; then
  echo "Error: STREAM_URL or TWITCH_KEY is not set!"
  exit 1
fi

echo "Starting FFmpeg streaming..."

ffmpeg -re -i "$STREAM_URL" \
  -c:v libx264 -preset fast -b:v 8000k -maxrate 8000k -bufsize 16000k \
  -c:a aac -b:a 320k -ar 48000 \
  -pix_fmt yuv420p -g 60 -keyint_min 30 -sc_threshold 0 \
  -x264opts "nal-hrd=cbr:force-cfr=1" \
  -vsync 1 -video_track_timescale 90000 \
  -f flv "rtmp://live.twitch.tv/app/$TWITCH_KEY"
