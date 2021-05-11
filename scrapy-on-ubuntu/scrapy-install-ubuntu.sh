#!/bin/bash

sudo apt-get -y update
sudo apt-get install -y python3 python-dev python3-dev build-essential libssl-dev libffi-dev libxml2-dev libxslt-dev python3-pip

sudo pip3 install scrapy