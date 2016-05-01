#!/bin/bash

subscriptionId="subscription().subscriptionId"
resourceGroup="resourceGroup().name"
userName="parameters('roleUserName')"
password="parameters('rolePassword')"
virtualNetwork="variables('vnetName')"
clusterName="parameters('clusterName')"
lbName="variables('lbName')"

cat <<EOF >"$FWDIR/conf/azure-ha.json"
{
  "debug": false,
  "subscriptionId": "$subscriptionId",
  "resourceGroup": "$resourceGroup",
  "userName": "$userName",
  "password": "$password",
  "virtualNetwork": "$virtualNetwork",
  "clusterName": "$clusterName",
  "lbName": "$lbName"
}
EOF

adminPassword="parameters('adminPassword')"
sicKey="parameters('sicKey')"
conf="install_security_gw=true"
conf="${conf}&install_ppak=true"
conf="${conf}&gateway_cluster_member=true"
conf="${conf}&install_security_managment=false"
conf="${conf}&ftw_sic_key=$sicKey"

config_system -s "$conf"
shutdown -r now
