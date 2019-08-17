#!/bin/bash

echo "=================================="
echo "----->  Usage:  Must be run as Pindrop User  <-----"
echo "=================================="
read -p "How many hours back do you want to check  " hours
echo "=================================="
read -p "enter todays date in the following format: 20190701  " date

empty_files=$(find /data/fds/encrypted_audio/$date/* -atime -$hours -size 41c | wc -l)
total_files=$(find /data/fds/encrypted_audio/$date/* -atime -$hours | wc -l)
PERCENT=$(awk "BEGIN {printf \"%.2f\",($empty_files/$total_files)*100}")

echo "=================empty================="
echo "total empty files in the last $hours hours:  $empty_files"
echo "=================total================="
echo "total files in the last $hours hours:  $total_files"
echo "==================%===================="
echo "$PERCENT percent of your files are missing RTP in the last $hours hours on intercept: $HOSTNAME"
