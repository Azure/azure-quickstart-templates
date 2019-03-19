#!/bin/bash
## Do initial preperation of the non-ansible boxes. This should be restricted to preparing for ansible to 
## reach onto the box by installing its prerequest (should already be present on redhat), installing nfs to
## mount the ansible controller share, and copying the public key there into the authorized keys.
#
set -x
set -v

if [ -z "$1" ]; then
	PRIMARY_USER="sas"
else
	PRIMARY_USER="$1"
fi
azure_storage_account="$2"
azure_storage_files_share="$3"
azure_storage_files_password="$4"
csv_group_list="$5"

CIFS_MOUNT_POINT="/mnt/${azure_storage_files_share}"
CIFS_SEMAPHORE_DIR="${CIFS_MOUNT_POINT}/setup/readiness_flags"
CIFS_ANSIBLE_KEYS="${CIFS_MOUNT_POINT}/setup/ansible_key"
CIFS_ANSIBLE_INVENTORIES_DIR="${CIFS_MOUNT_POINT}/setup/ansible/inventory"
CIFS_ANSIBLE_GROUPS_DIR="${CIFS_MOUNT_POINT}/setup/ansible/groups"
cifs_server_fqdn="${azure_storage_account}.file.core.windows.net"

# to workaround the strange issues azure has had with certs in yum, run yum update twice.
yum update -y rhui-azure-rhel7
#yum update -y --exclude=WALinuxAgent


# remove the requiretty from the sudoers file. Per bug https://bugzilla.redhat.com/show_bug.cgi?id=1020147 this is unnecessary and has been removed on future releases of redhat, 
# so is just a slowdown that denies pipelining and makes the non-tty session from azure extentions break on sudo without faking one (my prefered method is ssh back into the same user, but seriously..)
sed -i -e '/Defaults    requiretty/{ s/.*/# Defaults    requiretty/ }' /etc/sudoers

yum install -y cifs-utils

if [ ! -d "/etc/smbcredentials" ]; then
    sudo mkdir /etc/smbcredentials
fi
chmod 700 /etc/smbcredentials
if [ ! -f "/etc/smbcredentials/${azure_storage_account}.cred" ]; then
    echo "username=${azure_storage_account}" >> /etc/smbcredentials/${azure_storage_account}.cred
    echo "password=${azure_storage_files_password}" >> /etc/smbcredentials/${azure_storage_account}.cred
fi
chmod 600 "/etc/smbcredentials/${azure_storage_account}.cred"

mkdir -p "${CIFS_MOUNT_POINT}"
echo "//${cifs_server_fqdn}/${azure_storage_files_share} ${CIFS_MOUNT_POINT}  cifs defaults,vers=3.0,credentials=/etc/smbcredentials/${azure_storage_account}.cred,dir_mode=0777,file_mode=0777,sec=ntlmssp 0 0" >> /etc/fstab
#mount -a

mount "${CIFS_MOUNT_POINT}"
RET=$?
while [ "$RET" -gt "0" ]; do
	echo "Waiting 5 seconds for mount to be possible"
	sleep 5
	mount "${CIFS_MOUNT_POINT}"
	RET=$?
done
echo "Mounting Successful"
mkdir -p "${CIFS_MOUNT_POINT}/backup"
ln -s "${CIFS_MOUNT_POINT}/backup" /backups

wait_count=0
stop_waiting_count=600
ANSIBLE_AUTHORIZED_KEY_FILE="${CIFS_ANSIBLE_KEYS}/id_rsa.pub"
while [ ! -e "$ANSIBLE_AUTHORIZED_KEY_FILE" ]; do
	echo "waiting 5 seconds for key to come around"
	sleep 1
	if [ "$((wait_count++))" -gt "$stop_waiting_count" ]; then
		exit 1
	fi
done
su - ${PRIMARY_USER} <<END
mkdir -p $HOME/.ssh
cat "$ANSIBLE_AUTHORIZED_KEY_FILE" >> "/home/${PRIMARY_USER}/.ssh/authorized_keys"
chmod 600 "/home/${PRIMARY_USER}/.ssh/authorized_keys"
END

HOSTNAME="$(hostname | cut -f1 -d'.')"
HOSTNAME_FQDN="$(hostname -f)"
#ansible_become=true
INVENTORY_LINE="${HOSTNAME} ansible_host=${HOSTNAME_FQDN} ansible_user='${PRIMARY_USER}' ansible_ssh_extra_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null' ansible_connection='ssh' ansible_ssh_pipelining=true"  

ansible_temp_filename="/tmp/tmp.inv.ansible"

rm -f "$ansible_temp_filename"
OLD_IFS="$IFS"
IFS=","
for v in $csv_group_list; do
echo "[${v}]" >> "$ansible_temp_filename"
echo "${HOSTNAME}" >> "$ansible_temp_filename"
done
IFS="$OLD_IFS"
su - ${PRIMARY_USER} <<END
touch "${CIFS_SEMAPHORE_DIR}/$(hostname)_ready"
echo "$INVENTORY_LINE" > "${CIFS_ANSIBLE_INVENTORIES_DIR}/$(hostname)_inventory_line"
cat "$ansible_temp_filename" > "${CIFS_ANSIBLE_GROUPS_DIR}/$(hostname)_inventory_groups"
END