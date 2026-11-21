#!/bin/bash

LOG_FILE="/home/noebl/monitor.log"
DISK_THRESHOLD=80
RAM_THRESHOLD=80
CPU_THRESHOLD=80

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Disk: percentage used on /
DISK_USAGE=$(df -h | grep " /$" | awk '{print $5}' | sed 's/%//g')

# RAM: percentage used, based on the "available" column of free -m
RAM_USAGE=$(free -m | awk '/Mem:/ {printf "%d", ($2-$7)/$2*100}')

# CPU: 1-minute load average as a percentage of the number of cores
LOAD=$(uptime | awk -F'load average:' '{print $2}' | cut -d, -f1 | xargs)
CORES=$(nproc)
CPU_USAGE=$(awk -v l="$LOAD" -v c="$CORES" 'BEGIN {printf "%d", l/c*100}')

STATUS="OK"
if [ "$DISK_USAGE" -ge "$DISK_THRESHOLD" ] || [ "$RAM_USAGE" -ge "$RAM_THRESHOLD" ] || [ "$CPU_USAGE" -ge "$CPU_THRESHOLD" ]; then
    STATUS="WARNING"
fi

echo "[$TIMESTAMP] $STATUS | Disk: ${DISK_USAGE}% | RAM: ${RAM_USAGE}% | CPU load: ${CPU_USAGE}%" >> "$LOG_FILE"
