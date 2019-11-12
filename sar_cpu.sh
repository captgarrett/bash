daystotal=7
clear

for timecount in {1..143}
do 
	date -u -d"12am+$(($timecount*10))mins" +"%I:%M%p%t">>tempsarP1CPUpart
done

for stuff in $(for i in $(eval echo {$daystotal..0});do date -d "$i days ago" +/var/log/sa/sa%d;done;)
do 
	LC_ALL=en_AU.utf8 sar -f $stuff|awk '$1~/^[0-2][0-9]:[0-5][0-9]:[0-5][0-9]/&&$6~/^[0-9]/{if($4<=1){print substr($1,1,4)"0\t"$3}}'>>tempP1CPU
	for timecount in {1..143}
	do 
		date -u -d"12am+$(($timecount*10))mins" "+%H:%M%tNA"
	done>>tempP1CPU

	sort -k1 tempP1CPU | uniq -w5 | awk '{if($2<=10){printf"\033[0;34m"}else if($2<=20){printf"\033[0;32m"}else if($2<=35){printf"\033[1;33m"}else if($2<=50){printf"\033[0;33m"}else if($2>50){printf"\033[0;31m"}print $2"\033[0;0m"}' > tempP1CPU2
	paste -d'\t' tempsarP1CPUpart tempP1CPU2 > tempsarP1CPUtotal
	rm -f tempsarP1CPUpart tempP1CPU
	mv tempsarP1CPUtotal tempsarP1CPUpart
done

cat tempsarP1CPUpart
rm -f *P1CPU*;
