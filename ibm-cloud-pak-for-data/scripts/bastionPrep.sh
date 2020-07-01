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

# Remove RHUI

#rm -f /etc/yum.repos.d/rh-cloud.repo
sleep 20

# Register Host with Cloud Access Subscription
echo $(date) " - Register host with Cloud Access Subscription"

#subscription-manager register --force --username="$USERNAME_ORG" --password="$PASSWORD_ACT_KEY" || subscription-manager register --force --activationkey="$PASSWORD_ACT_KEY" --org="$USERNAME_ORG"
#RETCODE=$?

#if [ $RETCODE -eq 0 ]
#then
#    echo "Subscribed successfully"
#elif [ $RETCODE -eq 64 ]
#then
#    echo "This system is already registered."
#else
#    echo "Incorrect Username / Password or Organization ID / Activation Key specified"
#    exit 3
#fi

#subscription-manager attach --pool=$POOL_ID > attach.log
# if [ $? -eq 0 ]
# then
#     echo "Pool attached successfully"
# else
#     grep attached attach.log
#     if [ $? -eq 0 ]
#     then
#         echo "Pool $POOL_ID was already attached and was not attached again."
#     else
#         echo "Incorrect Pool ID or no entitlements available"
#         exit 4
#     fi
# fi

# # Disable all repositories and enable only the required ones
# echo $(date) " - Disabling all repositories and enabling only the required repos"

# subscription-manager repos --disable="*"

#subscription-manager repos \
#    --enable="rhel-7-server-rpms" \
#    --enable="rhel-7-server-extras-rpms" \
#    --enable="rhel-7-server-ose-3.11-rpms" \
#    --enable="rhel-7-server-ansible-2.6-rpms" \
#    --enable="rhel-7-fast-datapath-rpms" \
#    --enable="rh-gluster-3-client-for-rhel-7-server-rpms" \
#    --enable="rhel-7-server-optional-rpms"

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

yum install atomic-openshift-clients -y

# Install java to support metrics
echo $(date) " - Installing Java"

yum -y install java-1.8.0-openjdk-headless

echo $(date) " - Java installed successfully"

sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum -y install docker-ce
# Install docker
#echo "Install docker"
#yum -y install docker-1.13.1
#systemctl start docker
#systemctl enable docker
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
