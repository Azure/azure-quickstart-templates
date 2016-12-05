#!/bin/bash
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#
# See the License for the specific language governing permissions and
# limitations under the License.

#
# This script will walk you through setting up BIND on the host and making the changes needed in
# Azure portal.
#

#
# WARNING
#
# - This script only creates one zone file which supports <= 255 hosts. It has not been tested
#   with > 255 hosts trying to use the same zone file. It "might just work", or it may require
#   manually configuring additional zone files in `/etc/named/named.conf.local` and
#   `/etc/named/zones/`.
# - It is assumed that the Azure nameserver IP address will always be `168.63.129.16`. See more
#   info: https://blogs.msdn.microsoft.com/mast/2015/05/18/what-is-the-ip-address-168-63-129-16/.
#

INTERNAL_FQDN_SUFFIX=$1
HOST_IP=$2
LOG_FILE=$3

log() {
  echo "$(date): $*" >> "${LOG_FILE}"
}

#
# Default (Virtual) IP for Azure DNS, used for all regions
#
nameserver_ip="168.63.129.16"

log "This script will turn a fresh host into a BIND server and walk you through changing Azure DNS "
log "settings. If you have previously run this script on this host, or another host within the same "
log "virtual network: stop running this script and run the reset script before continuing."

# make the directories that bind will use
sudo mkdir /etc/named/zones
# make the files that bind will use
sudo touch /etc/named/named.conf.local
sudo touch /etc/named/zones/db.internal
sudo touch /etc/named/zones/db.reverse

#
# Set all of the variables
#

hostname=$(hostname -s)

internal_ip=${HOST_IP}

subnet=$(ipcalc -np "$(ip -o -f inet addr show | awk '/scope global/ {print $4}')" | awk '{getline x;print x;}1' | awk -F= '{print $2}' | awk 'NR%2{printf "%s/",$0;next;}1')

ptr_record_prefix=$(echo "${internal_ip}" | awk -F. '{print $3"." $2"."$1}')

hostnumber=$(echo "${internal_ip}" | cut -d . -f 4)

hostmaster="hostmaster"

log "[DEBUG: Variables used]"
log "subnet: $subnet"
log "internal_ip: $internal_ip"
log "internal_fqdn_suffix: $INTERNAL_FQDN_SUFFIX"
log "ptr_record_prefix: $ptr_record_prefix"
log "hostname: $hostname"
log "hostmaster: $hostmaster"
log "hostnumber: $hostnumber"
log "[END DEBUG: Variables used]"


#
# Create the BIND files
#

sudo cat > /etc/named.conf <<EOF
acl trusted {
    ${subnet};
};
options {
    listen-on port 53 { 127.0.0.1; ${internal_ip}; };
    listen-on-v6 port 53 { ::1; };
    directory "/var/named";
    dump-file "/var/named/data/cache_dump.db";
    statistics-file "/var/named/data/named_stats.txt";
    memstatistics-file "/var/named/data/named_mem_stats.txt";
    allow-query { localhost; trusted; };
    recursion yes;
    forwarders { ${nameserver_ip}; };
    dnssec-enable yes;
    dnssec-validation yes;
    dnssec-lookaside auto;
    /* Path to ISC DLV key */
    bindkeys-file "/etc/named.iscdlv.key";
    managed-keys-directory "/var/named/dynamic";
};
logging {
    channel default_debug {
        file "data/named.run";
        severity dynamic;
    };
};
zone "." IN {
    type hint;
    file "named.ca";
};
include "/etc/named.rfc1912.zones";
include "/etc/named.root.key";
include "/etc/named/named.conf.local";
EOF

sudo cat > /etc/named/named.conf.local <<EOF
zone "${INTERNAL_FQDN_SUFFIX}" IN {
    type master;
    file "/etc/named/zones/db.internal";
    allow-update { ${subnet}; };
};
zone "${ptr_record_prefix}.in-addr.arpa" IN {
    type master;
    file "/etc/named/zones/db.reverse";
    allow-update { ${subnet}; };
 };
EOF

sudo cat > /etc/named/zones/db.internal <<EOF
\$ORIGIN .
\$TTL 600  ; 10 minutes
${INTERNAL_FQDN_SUFFIX}  IN SOA  ${hostname}.${INTERNAL_FQDN_SUFFIX}. ${hostmaster}.${INTERNAL_FQDN_SUFFIX}. (
        10         ; serial
        600        ; refresh (10 minutes)
        60         ; retry (1 minute)
        604800     ; expire (1 week)
        600        ; minimum (10 minutes)
        )
        NS  ${hostname}.${INTERNAL_FQDN_SUFFIX}.
\$ORIGIN ${INTERNAL_FQDN_SUFFIX}.
${hostname}    A  ${internal_ip}
EOF

sudo cat > /etc/named/zones/db.reverse <<EOF
\$ORIGIN .
\$TTL 600  ; 10 minutes
${ptr_record_prefix}.in-addr.arpa  IN SOA  ${hostname}.${INTERNAL_FQDN_SUFFIX}. ${hostmaster}.${INTERNAL_FQDN_SUFFIX}. (
        10         ; serial
        600        ; refresh (10 minutes)
        60         ; retry (1 minute)
        604800     ; expire (1 week)
        600        ; minimum (10 minutes)
        )
        NS  ${hostname}.${INTERNAL_FQDN_SUFFIX}.
\$ORIGIN ${ptr_record_prefix}.in-addr.arpa.
${hostnumber}      PTR  ${hostname}.${INTERNAL_FQDN_SUFFIX}.
EOF


#
# Final touches on BIND related items
#
sudo chown -R named:named /etc/named*
sudo named-checkconf /etc/named.conf
if [ $? -ne 0 ] # if named-checkconf fails
then
    exit 1
fi
sudo named-checkzone "${INTERNAL_FQDN_SUFFIX}" /etc/named/zones/db.internal
if [ $? -ne 0 ] # if named-checkzone fails
then
    exit 1
fi
sudo named-checkzone "${ptr_record_prefix}.in-addr.arpa" /etc/named/zones/db.reverse
if [ $? -ne 0 ] # if named-checkzone fails
then
    exit 1
fi

sudo service named start
sudo chkconfig named on
#
# This host is now running BIND
#


#
# Add dhclient-exit-hooks to update the DNS search server
#

# Taken from https://github.com/cloudera/director-scripts/blob/master/azure-dns-scripts/bootstrap_dns.sh
# cat a here-doc representation of the hooks to the appropriate file
sudo cat > /etc/dhcp/dhclient-exit-hooks <<"EOF"
#!/bin/bash
printf "\ndhclient-exit-hooks running...\n\treason:%s\n\tinterface:%s\n" "${reason:?}" "${interface:?}"
# only execute on the primary nic
if [ "$interface" != "eth0" ]
then
    exit 0;
fi
# when we have a new IP, update the search domain
if [ "$reason" = BOUND ] || [ "$reason" = RENEW ] ||
   [ "$reason" = REBIND ] || [ "$reason" = REBOOT ]
then
EOF
# this is a separate here-doc because there's two sets of variable substitution going on, this set
# needs to be evaluated when written to the file, the two others (with "EOF" surrounded by quotes)
# should not have variable substitution occur when creating the file.
sudo cat >> /etc/dhcp/dhclient-exit-hooks <<EOF
    domain=${INTERNAL_FQDN_SUFFIX}
EOF
sudo cat >> /etc/dhcp/dhclient-exit-hooks <<"EOF"
    resolvconfupdate=$(mktemp -t resolvconfupdate.XXXXXXXXXX)
    echo updating resolv.conf
    grep -iv "search" /etc/resolv.conf > "$resolvconfupdate"
    echo "search $domain" >> "$resolvconfupdate"
    cat "$resolvconfupdate" > /etc/resolv.conf
fi
#done
exit 0;
EOF
sudo chmod 755 /etc/dhcp/dhclient-exit-hooks

#
# Now it's time to update Azure DNS settings in portal
#

log "Go to -- portal.azure.com -- confirm Azure DNS points to the private IP of this host: ${internal_ip}"

exit 0
