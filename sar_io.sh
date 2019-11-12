#!/bin/bash
daystotal=7
clear

for timecount in {1..143}
do 
	date -u -d"12am+$(($timecount*10))mins" +"%I:%M%p%t">>tempsarIOWpart
done

for stuff in $(for i in $(eval echo {$daystotal..0});do date -d "$i days ago" +/var/log/sa/sa%d;done;)
do 
	LC_ALL=en_AU.utf8 sar -f $stuff|awk '$1~/^[0-2][0-9]:[0-5][0-9]:[0-5][0-9]/&&$6~/^[0-9]/{if($7<=1){print substr($1,1,4)"0\t"$6}}'>>tempIOW
	for timecount in {1..143}
	do 
		date -u -d"12am+$(($timecount*10))mins" "+%H:%M%tNA"
	done>>tempIOW

	sort -k1 tempIOW | uniq -w5 | awk '{if($2<=1){printf"\033[0;34m"}else if($2 <= 2){printf"\033[0;32m"}else if($2<=5){printf"\033[1;33m"}else if($2<=10){printf"\033[0;33m"}else if($2>10){printf"\033[0;31m"}print $2"\033[0;0m"}' > tempIOW2
	paste -d'\t' tempsarIOWpart tempIOW2 > tempsarIOWtotal
	rm -f tempsarIOWpart tempIOW
	mv tempsarIOWtotal tempsarIOWpart
done

cat tempsarIOWpart
rm -f *IOW*
