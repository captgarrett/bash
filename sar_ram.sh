#!/bin/bash

daystotal=7;
tempSarP1CommitPart=$(mktemp CP1_XXXX);
tempP1Commit=$(mktemp CP1_XXXX);
tempP1Commit2=$(mktemp CP1_XXXX);
tempSarP1CommitTotal=$(mktemp CP1_XXXX);
clear;
for timecount in {1..143}; do 
	date -u -d"12am+$(($timecount*10))mins" +"%I:%M%p%t">>"$tempSarP1CommitPart"
done
for stuff in $(for i in $(eval echo {$daystotal..0}); do date -d "$i days ago" +/var/log/sa/sa%d;done;)
do 
	LC_ALL=en_AU.utf8 sar -r -f $stuff|awk '$1~/^[0-2][0-9]:[0-5][0-9]:[0-5][0-9]/&&$8~/^[0-9]/{print substr($1,1,4)"0\t"$8}'>>"$tempP1Commit"
	for timecount in {1..143}
	do
		date -u -d"12am+$(($timecount*10))mins" "+%H:%M%tNA"
	done>>"$tempP1Commit"

	sort -k1 "$tempP1Commit" | uniq -w5 | awk '{if($2<=20){printf"\033[0;34m"}else if($2<=35){printf"\033[0;32m"}else if($2<=50){printf"\033[1;33m"}else if($2<=65){printf"\033[0;33m"}else if($2>90){printf"\033[0;31m"}print $2"\033[0;0m"}'>"$tempP1Commit2"
	paste -d'\t' "$tempSarP1CommitPart" "$tempP1Commit2" >"$tempSarP1CommitTotal"
	rm -f "$tempSarP1CommitPart" "$tempP1Commit"
	mv "$tempSarP1CommitTotal" "$tempSarP1CommitPart"
done
cat "$tempSarP1CommitPart"
rm -f "$tempSarP1CommitPart" "$tempSarP1CommitTotal" "$tempP1Commit2"
