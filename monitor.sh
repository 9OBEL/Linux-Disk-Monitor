#!/bin/bash

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
	#capturing the disk usage into the variable 
DISK_USAGE=$(df -h | grep " /$" | awk '{print $5}' |sed 's/%//g')

if  [ $DISK_USAGE -ge 80 ]; then
	echo "[$TIMESTAMP] WARNING: Disk Usage is full at $DISK_USAGE%". >> monitor.log
else
	echo "[$TIMESTAMP] OK : Disk usage is healthy at $DISK_USAGE%". >> monitor.log
fi
