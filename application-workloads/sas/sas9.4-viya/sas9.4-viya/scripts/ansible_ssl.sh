#!/bin/bash
set -x
echo "*** Phase 2 -  Ansible SAS 94 SSL Certs Copy `date +'%Y-%m-%d_%H-%M-%S'` ***"

# Function for error handling
fail_if_error() {
  [ $1 != 0 ] && {
    echo $2
    exit 10
  }
}

# Variables
meta_host_name=`facter app_name``facter meta_name`
mid_host_name=`facter app_name``facter mid_name`
compute_host_name=`facter app_name``facter compute_name`

# SSL Certificates & encryption keys copy
scp -o StrictHostKeyChecking=no /opt/ssl/*.key ${meta_host_name}:/home/sasinst/
scp -o StrictHostKeyChecking=no /opt/ssl/*.crt ${meta_host_name}:/home/sasinst/
scp -o StrictHostKeyChecking=no /opt/ssl/*.crt ${meta_host_name}:/home/sasinst/
scp -o StrictHostKeyChecking=no ${meta_host_name}:/root/enc* .
fail_if_error $? "Error: Passwordless SSH for Meta Failed"

scp -o StrictHostKeyChecking=no /opt/ssl/*.key ${compute_host_name}:/home/sasinst/
scp -o StrictHostKeyChecking=no /opt/ssl/*.crt ${compute_host_name}:/home/sasinst/
scp -o StrictHostKeyChecking=no enc* ${compute_host_name}:/root/
fail_if_error $? "Error: Passwordless SSH for Compute Failed"

scp -o StrictHostKeyChecking=no /opt/ssl/*.crt ${mid_host_name}:/home/sasinst/
scp -o StrictHostKeyChecking=no /opt/ssl/*.key ${mid_host_name}:/home/sasinst/
scp -o StrictHostKeyChecking=no enc* ${mid_host_name}:/root/
fail_if_error $? "Error: Passwordless SSH for Mid Failed"

# Deleting Unwanted resources
rm -rf /opt/ssl/*.key
rm -rf /opt/ssl/*.crt
rm -rf /root/enc*

echo "*** Completed Phase 2 -  Ansible SAS 94 SSL Certs Copy `date +'%Y-%m-%d_%H-%M-%S'` ***"