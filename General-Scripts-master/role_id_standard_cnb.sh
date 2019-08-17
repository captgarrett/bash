#!/bin/bash

echo “=====modeling=====”
fab -R ams sudome:'echo $HOSTNAME' | grep out | awk '{print $3}' | sed -r '/^\s*$/d'
echo ”=====esa=====”
fab -R esa sudome:'echo $HOSTNAME' | grep out | awk '{print $3}' | sed -r '/^\s*$/d'
echo “=====intercept=====”
fab -R pbint sudome:'echo $HOSTNAME' | grep out | awk '{print $3}' | sed -r '/^\s*$/d'
echo “=====application=====”
fab -R app sudome:'echo $HOSTNAME' | grep out | awk '{print $3}' | sed -r '/^\s*$/d':wq
