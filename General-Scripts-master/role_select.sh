#!/bin/bash

#This script will show you which hosts are of a specific role

PS3='Choose Role: '
options=("ams" "esa" "app" "appbkp" "intercept" "pbint" "broker" "exit")
select opt in "${options[@]}"
do
    case $opt in
        "ams")
            fab -R ams sudome:'echo $HOSTNAME' | grep out | awk '{print $3}' | sed -r '/^\s*$/d'
            ;;
        "esa")
            fab -R esa sudome:'echo $HOSTNAME' | grep out | awk '{print $3}' | sed -r '/^\s*$/d'
            ;;
        "app")
            fab -R app sudome:'echo $HOSTNAME' | grep out | awk '{print $3}' | sed -r '/^\s*$/d'
            ;;
        "appbkp")
            fab -R appbkp sudome:'echo $HOSTNAME' | grep out | awk '{print $3}' | sed -r '/^\s*$/d'
            ;;
        "intercept")
	    fab -R intercept sudome:'echo $HOSTNAME' | grep out | awk '{print $3}' | sed -r '/^\s*$/d'
	    ;;
        "pbint")
            fab -R pbint sudome:'echo $HOSTNAME' | grep out | awk '{print $3}' | sed -r '/^\s*$/d'
            ;;
        "broker")
            fab -R broker sudome:'echo $HOSTNAME' | grep out | awk '{print $3}' | sed -r '/^\s*$/d'
            ;;
        "exit")
            break
            ;;
        *) echo invalid option;;
    esac
done
