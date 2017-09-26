#!/bin/bash

function log()
{
	message=$1
	echo "$message"
	echo "$message" >> /var/log/sapconfigcreate
}



log "noop"