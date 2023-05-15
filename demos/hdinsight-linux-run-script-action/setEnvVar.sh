#!/bin/bash

myNodeType=$1;
if [ -z "$myNodeType" ]; then
    echo "[ERROR] No node type specified. Exiting!"
    usage
fi
echo "myNodeType=$myNodeType";

echo "MyNodeType=$myNodeType" | sudo tee -a /etc/environment
