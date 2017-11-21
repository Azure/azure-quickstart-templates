#!/bin/bash

echo "Etc/UCT" > /etc/timezone    
dpkg-reconfigure -f noninteractive tzdata
service apache2 restart