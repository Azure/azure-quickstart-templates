#!/bin/bash
## Do initial preperation of the non-ansible boxes. This should be restricted to preparing for ansible to 
## reach onto the box by installing its prerequest (should already be present on redhat), installing nfs to
## mount the ansible controller share, and copying the public key there into the authorized keys.
#
set -x
set -v
set -e

if [ -z "$1" ]; then
	INSTALL_USER="sas"
else
	INSTALL_USER="$1"
fi
azure_storage_account="$2"
azure_storage_files_share="$3"
azure_storage_files_password="$4"
csv_group_list="$5"

CIFS_MOUNT_POINT="/mnt/${azure_storage_files_share}"
CIFS_SEMAPHORE_DIR="${CIFS_MOUNT_POINT}/setup/readiness_flags"
CIFS_ANSIBLE_KEYS="${CIFS_MOUNT_POINT}/setup/ansible_key"
#CIFS_ANSIBLE_INVENTORIES_DIR="${CIFS_MOUNT_POINT}/setup/ansible/inventory"
#CIFS_ANSIBLE_GROUPS_DIR="${CIFS_MOUNT_POINT}/setup/ansible/groups"
cifs_server_fqdn="${azure_storage_account}.file.core.windows.net"


# on 4/17, we started having intermittent issues with this repository being present for updates, so configuring to skip
yum-config-manager --save --setopt=rhui-microsoft-azure-rhel7-eus.skip_if_unavailable=true


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
su - ${INSTALL_USER} <<END
mkdir -p /home/${INSTALL_USER}/.ssh
cat "$ANSIBLE_AUTHORIZED_KEY_FILE" >> "/home/${INSTALL_USER}/.ssh/authorized_keys"
chmod 600 "/home/${INSTALL_USER}/.ssh/authorized_keys"
END


ansible_temp_filename="/tmp/tmp.inv.ansible"

rm -f "$ansible_temp_filename"


#
# Create and simlink the remote directories for cascache/saswork
#

mkdir -p /mnt/resource/sastmp/cascache
mkdir -p /mnt/resource/sastmp/saswork
chown -R ${INSTALL_USER} /mnt/resource/sastmp
chmod 777 /mnt/resource/sastmp/cascache
chmod 777 /mnt/resource/sastmp/saswork
ln -s /mnt/resource/sastmp /sastmp



#
# semaphore that we are ready
#
LOCALIP=$(ip -o -f inet addr | grep eth0 | sed -r 's/.*\b(([0-9]{1,3}\.){3}[0-9]{1,3})\/.*/\1/g')
su - ${INSTALL_USER} <<END
echo $LOCALIP > "${CIFS_SEMAPHORE_DIR}/$(hostname)"
END

