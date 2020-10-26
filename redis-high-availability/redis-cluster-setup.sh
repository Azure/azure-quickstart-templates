#!/bin/bash

# The MIT License (MIT)
#
# Copyright (c) 2015 Microsoft Azure
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# Script parameters and their defaults
INSTANCE_COUNT=1
SLAVE_COUNT=0
IP_PREFIX="10.0.0."
REDIS_PORT=6379
LOGGING_KEY="[account-key]"

########################################################
# This script will configures a Redis cluster
########################################################
help()
{
	echo "This script configures a Redis cluster on the Ubuntu virtual machine image"
	echo "Available parameters:"
	echo "-c Instance Count"
	echo "-s Slave Count"
	echo "-p Redis Node IP Prefix"
}

log()
{
	# If you want to enable this logging add a un-comment the line below and add your account key
	#curl -X POST -H "content-type:text/plain" --data-binary "$(date) | ${HOSTNAME} | $1" https://logs-01.loggly.com/inputs/${LOGGING_KEY}/tag/redis-extension,${HOSTNAME}
	echo "$1"
}

# Expand a list of successive IP range defined by a starting address prefix (e.g. 10.0.0.1) and the number of machines in the range
# 10.0.0.1-3 would be converted to "10.0.0.10 10.0.0.11 10.0.0.12"
expand_ip_range() {
    IFS='-' read -a HOST_IPS <<< "$1"

    declare -a EXPAND_STATICIP_RANGE_RESULTS=()

    for (( n=0 ; n<("${HOST_IPS[1]}"+0) ; n++))
    do
        HOST="${HOST_IPS[0]}${n}:${REDIS_PORT}"
		EXPAND_STATICIP_RANGE_RESULTS+=($HOST)
    done

    echo "${EXPAND_STATICIP_RANGE_RESULTS[@]}"
}

log "Begin execution of Redis cluster configuration script extension on ${HOSTNAME}"

if [ "${UID}" -ne 0 ];
then
    log "Script executed without root permissions"
    echo "You must be root to run this program." >&2
    exit 3
fi

# Parse script parameters
while getopts :c:s:p:h optname; do
  log "Option $optname set with value ${OPTARG}"

  case $optname in
	c) # Number of instances
		INSTANCE_COUNT=${OPTARG}
		;;
	s) # Number of slave nodes
		SLAVE_COUNT=${OPTARG}
		;;
	p) # Private IP address prefix
		IP_PREFIX=${OPTARG}
		;;
    h)  # Helpful hints
		help
		exit 2
		;;
    \?) #unrecognized option - show help
		echo -e \\n"Option -${BOLD}$OPTARG${NORM} not allowed."
		help
		exit 2
		;;
  esac
done

log "Configuring Redis cluster on ${INSTANCE_COUNT} nodes with ${SLAVE_COUNT} slave(s) for every master node"

# Install the Ruby runtime that the cluster configuration script uses
apt-get -y install ruby-full

# Install the Redis client gem (a pre-requisite for redis-trib.rb)
gem install redis

# Create a cluster based upon the specified host list and replica count
echo "yes" | /usr/local/bin/redis-trib.rb create --replicas ${SLAVE_COUNT} $(expand_ip_range "${IP_PREFIX}-${INSTANCE_COUNT}")

log "Redis cluster was configured successfully"
