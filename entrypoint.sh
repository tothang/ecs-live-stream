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
    echo "Twitch stream is down. Stopping any existing FFmpeg processes and restarting stream..."

    # Kill any existing ffmpeg processes
    pkill -9 ffmpeg || true

    # Wait a few seconds to ensure ffmpeg has fully terminated
    sleep 5

    # Start the new FFmpeg stream with the logo overlay
    ffmpeg -re -i "$STREAM_URL" \
      -i https://1361694720.rsc.cdn77.org/logo/logo-talknow.png \
      -filter_complex "[1:v]scale=iw*0.1:ih*0.1[logo];[0:v][logo]overlay=10:10" \
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
