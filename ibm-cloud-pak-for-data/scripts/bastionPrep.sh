#!/bin/bash
echo $(date) " - Starting Bastion Prep Script"

export USERNAME_ORG=$1
export PASSWORD_ACT_KEY="$2"
export POOL_ID=$3
export SUDOUSER=$4

# Generate private keys for use by Ansible
echo $(date) " - Generating Private keys for use by Ansible for OpenShift Installation"

runuser -l $SUDOUSER -c "echo \"$PRIVATEKEY\" > /home/$SUDOUSER/.ssh/id_rsa"
runuser -l $SUDOUSER -c "chmod 600 /home/$SUDOUSER/.ssh/id_rsa*"


# Update system to latest packages
echo $(date) " - Update system to latest packages"
yum -y update --exclude=WALinuxAgent
echo $(date) " - System update complete"

# Install base packages and update system to latest packages
echo $(date) " - Install base packages"
yum -y install wget git net-tools bind-utils iptables-services bridge-utils bash-completion httpd-tools kexec-tools sos psacct ansible
yum -y update glusterfs-fuse
echo $(date) " - Base package installation complete"

# Install Ansible and pyOpenSSL on Master-0 Node
# python-passlib needed for metrics
echo $(date) " - Installing Ansible, pyOpenSSL and python-passlib"
yum -y install pyOpenSSL python-passlib
yum -y install python-pip vim pyOpenSSL
curl --retry 10 --max-time 60 --fail --silent --show-error "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
python get-pip.py
pip install ansible==2.6.11
echo $(date) " - Installation Complete"

# Installing Azure CLI
# From https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-yum
echo $(date) " - Installing Azure CLI"
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[azure-cli]\nname=Azure CLI\nbaseurl=https://packages.microsoft.com/yumrepos/azure-cli\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/azure-cli.repo'
sudo yum install -y azure-cli
echo $(date) " - Azure CLI installation complete"

# Install ImageMagick to resize image for Custom Header
sudo yum install -y ImageMagick

#yum install atomic-openshift-clients -y
sudo wget https://github.com/openshift/origin/releases/download/v3.11.0/openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz
sudo tar -zxf openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz
sudo mv openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit/oc /usr/bin/

# Install java to support metrics
echo $(date) " - Installing Java"

yum -y install java-1.8.0-openjdk-headless

echo $(date) " - Java installed successfully"

echo "Install docker"
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum -y install docker-ce

echo "Docker install complete"


# Grow Root File System
yum -y install cloud-utils-growpart.noarch
echo $(date) " - Grow Root FS"

rootdev=`findmnt --target / -o SOURCE -n`
rootdrivename=`lsblk -no pkname $rootdev`
rootdrive="/dev/"$rootdrivename
name=`lsblk  $rootdev -o NAME | tail -1`
part_number=${name#*${rootdrivename}}

growpart $rootdrive $part_number -u on
xfs_growfs $rootdev

if [ $? -eq 0 ]
then
    echo $(date) " - Root File System successfully extended"
else
    echo $(date) " - Root File System failed to be grown"
	exit 20
fi

echo $(date) " - Script Complete"
