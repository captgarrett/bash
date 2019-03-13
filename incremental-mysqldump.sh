#!/bin/bash

#usage scenario:  You need to dump a database table (or entire database with some editing) in bite size chunks.  This was originally designed when trying to recover data from a corrupt database, what would not allow standard mysqlcheck table repairs.  Also standard whole table dumps were not optional as we were in recovery mode 4.  

#Data is compressed with xz compression utility.  To uncompress, use unxz filenamehere.sql.xz.
#This script also ships the data off to a desired directory on another server.  This shipping mechanism can be easily stripped out.  

#recommend pulling the max key value to get the optimial "max key value" variable below.  Exe.  select max(id) from databasetable; 

#used --no-create-db --no-create-info to prevent table creation per file.
#be mindful of batch size when running this on a very large database.


read -p "Max key value: " number
read -p "Table to dump: " table
read -p "table name: " tablename
read -p "batch size: " ivalue
read -p "key id: " key #this is primary key identifier, such as tid or id, but could be anything you've designated as primary key identifier

i=0
j=$(( i + $ivalue ))
while [ $j -lt $number ] ;
do

echo "i=${i} ; j=${j}"

mysqldump -uroot -ppassword --lock-tables --max-allowed-packet=1073741824 --single-transaction --routines --triggers --skip-extended-insert --skip-add-drop-table --no-create-db --no-create-info --where "${key} >= ${i} AND ${key} < ${j}" database $table | xz | ssh -i /home/fdsadmin/.ssh/id_rsa -o StrictHostkeyChecking=no fdsadmin@E1OX1PD1IT006 "cat - > /data/recovery/corrupt3/table_${tablename}_${i}.sql.xz"


i=${j}
j=$(( j + $ivalue ))
sleep 0.6

done
