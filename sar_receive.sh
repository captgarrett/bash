#!/bin/bash

pushd /tmp >/dev/null
echo "generating network device heatmap for packets received"
for time in {1..143}
do
	date -u -d"12am+$((${time}*10))mins" +"%I:%M%p%t" >> network-iface-1-packets-received.time_column1
done
for sa_file in {10..0}
do
	sar -n DEV -f $(date -d "${sa_file} days ago" +/var/log/sa/sa%d) | grep lan0 | awk '$1 ~ /^[0-2][0-9]:/ && $6 ~ /^[0-9]/ {print $5}' | awk '{if($1 <= 50) {printf"\033[1;34m"} else if($1 <= 100) {printf"\033[1;32m"} else if($1 <= 250) {printf"\033[1;31m"} else if($1 <= 550) {printf"\033[0;31m"} else if($1 > 750) {printf"\033[1;35m"} print $1"\033[0;0m"}' > network-iface-1-packets-received.sa_date_"${sa_file}"
done

paste network-iface-1-packets-received.time_column1 network-iface-1-packets-received.sa_date_{10..0} | column -t
rm -f network-iface-1-packets-received.*
popd >/dev/null
