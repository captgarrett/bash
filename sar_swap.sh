#!/bin/bash

daystotal=7
tempSarP1SwapPart=$(mktemp CP1_XXXX)
tempP1Swap=$(mktemp CP1_XXXX)
tempP1Swap2=$(mktemp CP1_XXXX)
tempSarP1SwapTotal=$(mktemp CP1_XXXX)
clear
for timecount in {1..143}
do 
	date -u -d"12am+$(($timecount*10))mins" +"%I:%M%p%t">>"$tempSarP1SwapPart"
done

for stuff in $(for i in $(eval echo {$daystotal..0});do date -d "$i days ago" +/var/log/sa/sa%d;done;)
do 
	LC_ALL=en_AU.utf8 sar -S -f $stuff|awk '$1~/^[0-2][0-9]:[0-5][0-9]:[0-5][0-9]/&&$4~/^[0-9]/{print substr($1,1,4)"0\t"$4}'>>"$tempP1Swap"
	for timecount in {1..143}
	do 
		date -u -d"12am+$(($timecount*10))mins" "+%H:%M%tNA"
	done>>"$tempP1Swap"
	sort -k1 "$tempP1Swap" | uniq -w5 | awk '{if($2<=20){printf"\033[0;34m"}else if($2<=35){printf"\033[0;32m"}else if($2<=50){printf"\033[1;33m"}else if($2<=65){printf"\033[0;33m"}else if($2>90){printf"\033[0;31m"}print $2"\033[0;0m"}'>"$tempP1Swap2"
	paste -d'\t' "$tempSarP1SwapPart" "$tempP1Swap2" >"$tempSarP1SwapTotal"
	rm -f "$tempSarP1SwapPart" "$tempP1Swap"
	mv "$tempSarP1SwapTotal" "$tempSarP1SwapPart"
done
cat "$tempSarP1SwapPart"
rm -f "$tempSarP1SwapPart" "$tempSarP1SwapTotal" "$tempP1Swap2"
