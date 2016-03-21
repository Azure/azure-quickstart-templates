#!/bin/bash

installSecurityGateway="parameters('installSecurityGateway')"
installSecurityGateway="$(echo $installSecurityGateway | tr "TF" "tf")"
installSecurityManagement="parameters('installSecurityManagement')"
installSecurityManagement="$(echo $installSecurityManagement | tr "TF" "tf")"
adminPassword="parameters('adminPassword')"
managementGUIClientNetwork="parameters('managementGUIClientNetwork')"
ManagementGUIClientBase="$(echo $managementGUIClientNetwork | cut -d / -f 1)"
ManagementGUIClientMaskLength="$(echo $managementGUIClientNetwork | cut -d / -f 2)"
sicKey="parameters('sicKey')"
conf="install_security_gw=$installSecurityGateway"
if $installSecurityGateway; then
    conf="${conf}&install_ppak=true"
    conf="${conf}&gateway_cluster_member=false"
fi
conf="${conf}&install_security_managment=$installSecurityManagement"
if $installSecurityManagement; then
    conf="${conf}&install_mgmt_primary=true"
    conf="${conf}&mgmt_admin_name=admin"
    conf="${conf}&mgmt_admin_passwd=$adminPassword"
    conf="${conf}&mgmt_gui_clients_radio=network"
    conf="${conf}&mgmt_gui_clients_ip_field=$ManagementGUIClientBase"
    conf="${conf}&mgmt_gui_clients_subnet_field=$ManagementGUIClientMaskLength"
fi
conf="${conf}&ftw_sic_key=$sicKey"

config_system -s $conf
shutdown -r now
