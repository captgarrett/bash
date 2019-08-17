#!/bin/bash

#standard role identification script. 
#prints out full listing
#possible roles = app,appbkp,intercept,esa,ams & pbint.

echo “=====modeling=====”
fab -R ams sudome:'echo $HOSTNAME' | grep out | awk '{print $3}' | sed -r '/^\s*$/d'
echo ”=====esa=====”
fab -R esa sudome:'echo $HOSTNAME' | grep out | awk '{print $3}' | sed -r '/^\s*$/d' 
echo “=====intercept=====”
fab -R intercept sudome:'echo $HOSTNAME' | grep out | awk '{print $3}' | sed -r '/^\s*$/d'
echo “=====application=====”
fab -R app sudome:'echo $HOSTNAME' | grep out | awk '{print $3}' | sed -r '/^\s*$/d'
echo “=====backup app=====”
fab -R appbkp sudome:'echo $HOSTNAME' | grep out | awk '{print $3}' | sed -r '/^\s*$/d'
echo “=====broker=====”
fab -R broker sudome:'echo $HOSTNAME' | grep out | awk '{print $3}' | sed -r '/^\s*$/d'
