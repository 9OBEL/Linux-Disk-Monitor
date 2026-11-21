#!/bin/bash

LOG_FILE="/home/noebl/monitor.log"
ALERT_FILE="/home/noebl/alerts.log"
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
ALERTS=""

if [ "$DISK_USAGE" -ge "$DISK_THRESHOLD" ]; then
    STATUS="WARNING"
    ALERTS="$ALERTS Disk at ${DISK_USAGE}% (limit ${DISK_THRESHOLD}%)."
fi

if [ "$RAM_USAGE" -ge "$RAM_THRESHOLD" ]; then
    STATUS="WARNING"
    ALERTS="$ALERTS RAM at ${RAM_USAGE}% (limit ${RAM_THRESHOLD}%)."
fi

if [ "$CPU_USAGE" -ge "$CPU_THRESHOLD" ]; then
    STATUS="WARNING"
    ALERTS="$ALERTS CPU load at ${CPU_USAGE}% (limit ${CPU_THRESHOLD}%)."
fi

echo "[$TIMESTAMP] $STATUS | Disk: ${DISK_USAGE}% | RAM: ${RAM_USAGE}% | CPU load: ${CPU_USAGE}%" >> "$LOG_FILE"

if [ "$STATUS" = "WARNING" ]; then
    echo "[$TIMESTAMP] ALERT:$ALERTS" >> "$ALERT_FILE"
    logger -p user.warning -t disk-monitor "ALERT:$ALERTS"
fi
