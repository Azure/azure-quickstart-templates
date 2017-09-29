#!/bin/bash

sed -i "s|^[^#]*rocommunity public|rocommunity $(mcookie)|" /etc/snmp/snmpd.conf

