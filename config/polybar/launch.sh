#!/usr/bin/env bash

# Kill existing bar instances
killall -q polybar

# Launch Polybar on primary monitor
polybar bar -r &

# Wait for the bars to load
sleep 1
