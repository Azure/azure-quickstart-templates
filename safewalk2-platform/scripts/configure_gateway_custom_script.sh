#!/bin/bash

ROOT_PASSWORD=$1
SAFEWALK_SUBNET_IP=$2

my_dir=`dirname $0`

sh $my_dir/set_root_password.sh $ROOT_PASSWORD

bash $my_dir/setup_timezone.sh

turnkey-install-security-updates

bash $my_dir/gateway_upgrade.sh

sh $my_dir/gateway_whitelist_safewalk_server.sh $SAFEWALK_SUBNET_IP

bash $my_dir/setup_snmp.sh