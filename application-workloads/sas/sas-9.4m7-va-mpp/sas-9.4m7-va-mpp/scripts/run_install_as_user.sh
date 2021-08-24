#!/bin/bash

sudo su - $1 -c "/sasshare/depot/setup.sh -quiet -loglevel 2 -responsefile $2"
