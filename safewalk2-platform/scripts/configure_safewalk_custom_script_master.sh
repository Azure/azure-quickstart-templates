#!/bin/bash

ROOT_PASSWORD=$1
GATEWAY_IP=$2
GATEWAY_PUBLIC_IP=$3
GATEWAY_ROOT_PASSWORD=$4
FIRST_IP=$5
COUNT_IP=$6
SAFEWALK_SUBNET_IP=$7
ADMIN_PASSWORD=$9


#sh configure_safewalk_custom_script.sh root 192.168.10.244 192.168.10.244 Safewalk1 192.168.10.201

my_dir=`dirname $0`
safewalk_dir=/home/safewalk/safewalk_server/sources

bash $my_dir/safewalk_make_partitions.sh

sh $my_dir/set_root_password.sh $ROOT_PASSWORD

bash $my_dir/setup_timezone.sh
install-security-updates

bash $my_dir/safewalk_renew_secrets.sh

bash $my_dir/setup_snmp.sh

bash $my_dir/safewalk_iptables.sh

bash $my_dir/safewalk_upgrade.sh

bash $safewalk_dir/bin/safewalk_set_admin_password.sh $ADMIN_PASSWORD







IFS='.' read -ra ADDR <<< "$SAFEWALK_SUBNET_IP"
PREFIX=${ADDR[0]}.${ADDR[1]}.${ADDR[2]}
SAFEWALK_IP_1=$PREFIX.$FIRST_IP

SAFEWALK_HOSTS=
for (( i = $FIRST_IP; i < $(($FIRST_IP + $COUNT_IP)); i++ ))
do
    if [ $i = $FIRST_IP ]; then
        SAFEWALK_HOSTS="$PREFIX.$i"
    else
        SAFEWALK_HOSTS="$SAFEWALK_HOSTS,$PREFIX.$i"
    fi
done

bash $my_dir/safewalk_create_gateway.sh --gateway-name "My Gateway" --gateway-password $GATEWAY_ROOT_PASSWORD --gateway-public-host $GATEWAY_PUBLIC_IP --gateway-ssh-host $GATEWAY_IP --safewalk-host $SAFEWALK_HOSTS

if [ $COUNT_IP > 1 ]; then
    bash $my_dir/safewalk_bdr_create.sh $SAFEWALK_IP_1 $SAFEWALK_SUBNET_IP
else
    echo "Do nothing"
    #bash safewalk_bdr_create.sh $SAFEWALK_IP_1
fi



