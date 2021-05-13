#!/bin/bash

sudo apt-get update
sudo dpkg --configure -a
sudo apt-get install -y build-essential libssl-dev libffi-dev software-properties-common python3-pip

pip3 install --upgrade proxy.py

python3 -m proxy > /dev/null 2>&1 &