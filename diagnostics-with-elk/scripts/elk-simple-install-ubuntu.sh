#!/bin/bash
#
# ========================================================================================
# Microsoft patterns & practices (http://microsoft.com/practices)
# SEMANTIC LOGGING APPLICATION BLOCK
# ========================================================================================
#
# Copyright (c) Microsoft.  All rights reserved.
# Microsoft would like to thank its contributors, a list
# of whom are at http://aka.ms/entlib-contributors
#
# Licensed under the Apache License, Version 2.0 (the "License"); you
# may not use this file except in compliance with the License. You may
# obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied. See the License for the specific language governing permissions
# and limitations under the License.
#

log()
{
	echo $1
	logger "elk-simple-on-ubuntu:" $1
}

#Loop through options passed
while getopts :e:a:k:t:i:sh optname; do
    log "Option $optname set with value ${OPTARG}"
  case $optname in
	e)
	  ENCODED_LOGSTASH_CONFIG=${OPTARG}
	  ;;
	a)
	  STORAGE_ACCOUNT_NAME=${OPTARG}
	  ;;
	k)
	  STORAGE_ACCOUNT_KEY=${OPTARG}
	  ;;
	t)
	  STORAGE_ACCOUNT_TABLES=${OPTARG}
	  ;;
	i)
	  ES_CLUSTER_IP=${OPTARG}
	  ;;
	s)  #skip common install steps
	  SKIP_COMMON_INSTALL="YES"
	  ;;
    h)  #show help
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

#ELK (Simple) Install Script
mkdir /opt/elk-simple/
cd /opt/elk-simple/
wget https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/diagnostics-with-elk/scripts/logstash-install-ubuntu.sh

#Install Logstash
log "Installing Logstash"
bash ./logstash-install-ubuntu.sh -e $ENCODED_LOGSTASH_CONFIG -a $STORAGE_ACCOUNT_NAME -k $STORAGE_ACCOUNT_KEY -t $STORAGE_ACCOUNT_TABLES -i $ES_CLUSTER_IP
log "Installing Logstash Completed"
