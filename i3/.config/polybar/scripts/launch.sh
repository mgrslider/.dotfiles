#!/bin/bash
LOG="/tmp/polybar.log"
killall -q polybar
sleep 1
echo "--- $(date '+%F %T') start ---" >> "$LOG"
polybar main >> "$LOG" 2>&1 &
