#!/bin/bash

ROOT_PASSWORD=$1
GATEWAY_IP=$2
GATEWAY_PUBLIC_IP=$3
GATEWAY_ROOT_PASSWORD=$4
SAFEWALK_IP_1=$5
SAFEWALK_IP_2=$6
CLUSTER_ENABLED=$7
ADMIN_PASSWORD=$8


#sh configure_safewalk_custom_script.sh root 192.168.10.244 192.168.10.244 Safewalk1 192.168.10.201

my_dir=`dirname $0`
safewalk_dir=/home/safewalk/safewalk_server/sources

bash $my_dir/safewalk_make_partitions.sh

sh $my_dir/set_root_password.sh $ROOT_PASSWORD

bash $my_dir/safewalk_renew_secrets.sh

bash $my_dir/setup_snmp.sh

bash $my_dir/safewalk_iptables.sh

bash $my_dir/safewalk_upgrade.sh

if [ "$CLUSTER_ENABLED" = "True" ]; then
    SAFEWALK_HOSTS=$SAFEWALK_IP_1,$SAFEWALK_IP_2
else
    SAFEWALK_HOSTS=$SAFEWALK_IP_1
fi

if [ "$CLUSTER_ENABLED" = "True" ]; then
    bash safewalk_bdr_create.sh $SAFEWALK_IP_1 $SAFEWALK_IP_2
else
    echo "Do nothing"
    #bash safewalk_bdr_create.sh $SAFEWALK_IP_1
fi

echo "IS CLUSTER ENABLED: $CLUSTER_ENABLED - $SAFEWALK_HOSTS"
bash $my_dir/safewalk_create_gateway.sh --gateway-name "My Gateway" --gateway-password $GATEWAY_ROOT_PASSWORD --gateway-public-host $GATEWAY_PUBLIC_IP --gateway-ssh-host $GATEWAY_IP --safewalk-host $SAFEWALK_HOSTS

bash $safewalk_dir/bin/safewalk_set_admin_password.sh $ADMIN_PASSWORD

bash $my_dir/safewalk_organization_identity.sh $SAFEWALK_IP_1