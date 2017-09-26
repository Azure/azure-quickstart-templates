#!/bin/sh
## Argument 1 will be password for Ansible Tower UI Admin  ##
## Argument 2 will be password for Database Admin  ##
## Argument 3 will be username for Client VMs  ##
## Argument 4 will be password for Client Vms  ##
## Argument 5 will be IP address of client VM 1 ##
## Argument 6 will be IP address of client VM 2 ##

## To execute this script run sudo su -c'sh installAnsibleTowerScript.sh Ansibleadminpassword Databaseadminpassword ClientVMsUsername ClientVMsPassword ClientVm01IP ClientVm02IP'  ##

yum clean all
### Installing Required Dependencies ###
########################################

yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum install -y python-setuptools
yum install -y python-daemon
yum install -y pystache
yum install -y python-ecdsa
yum install -y python-paramiko
yum install -y python-keyczar
yum install -y python-crypto
yum install -y python-httplib
yum install git -y
yum install wget -y
yum install sshpass -y

#Disable SSH Copy prompt#
echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config

## The following code generates SSH Keys and copies it to other hosts ##  
ssh-keygen -f $HOME/.ssh/id_rsa -t rsa -b 4096 -N ''
sshpass -p "$4" ssh-copy-id "$3"@"$5"
sshpass -p "$4" ssh-copy-id "$3"@"$6"

#### Install Ansible ########
yum install ansible -y
#############################


wget http://releases.ansible.com/ansible-tower/setup/ansible-tower-setup-latest.tar.gz
tar xvzf ansible-tower-setup*
cd ansible-tower-setup*



# Relax the min var requirements
sed -i -e "s/10000000000/100000000/" roles/preflight/defaults/main.yml
# Allow sudo with out tty
sed -i -e "s/Defaults    requiretty/Defaults    \!requiretty/" /etc/sudoers

cat <<EOF > inventory

[tower]

localhost ansible_connection=local

[database]
[all:vars]

admin_password="$1"


pg_host=''
pg_port=''

pg_database='awx'
pg_username='awx'
pg_password="$2"

rabbitmq_port=5672
rabbitmq_vhost=tower
rabbitmq_username=tower
rabbitmq_password="$2"
rabbitmq_cookie=rabbitmqcookie

# Needs to be true for fqdns and ip addresses
rabbitmq_use_long_name=false


EOF

# Changing hostname of Ansible Tower VM #
hostnamectl set-hostname tower

ANSIBLE_BECOME_METHOD=’sudo’ 
ANSIBLE_BECOME=True

### Install Ansible Tower ###
sudo bash setup.sh

### Disable SELinux ###
setenforce 0
sed -i 's/enforcing/disabled/g' /etc/selinux/config /etc/selinux/config

exit 0

exit 0
