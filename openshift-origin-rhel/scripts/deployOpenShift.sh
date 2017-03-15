#!/bin/bash

set -e

SUDOUSER=$1
PASSWORD="$2"
PRIVATEKEY=$3
MASTER=$4
MASTERPUBLICIPHOSTNAME=$5
MASTERPUBLICIPADDRESS=$6
NODE=$7
NODECOUNT=$8
ROUTING=$9

NODELOOP=$((NODECOUNT - 1))

DOMAIN=$( awk 'NR==2' /etc/resolv.conf | awk '{ print $2 }' )

# Generate public / private keys for use by Ansible

echo "Generating keys"

runuser -l $SUDOUSER -c "echo \"$PRIVATEKEY\" > ~/.ssh/id_rsa"
runuser -l $SUDOUSER -c "chmod 600 ~/.ssh/id_rsa*"

echo "Configuring SSH ControlPath to use shorter path name"

sed -i -e "s/^# control_path = %(directory)s\/%%h-%%r/control_path = %(directory)s\/%%h-%%r/" /etc/ansible/ansible.cfg
sed -i -e "s/^#host_key_checking = False/host_key_checking = False/" /etc/ansible/ansible.cfg
sed -i -e "s/^#pty=False/pty=False/" /etc/ansible/ansible.cfg

# Create Ansible Hosts File

echo "Generating Ansible hosts file"

cat > /etc/ansible/hosts <<EOF
# Create an OSEv3 group that contains the masters and nodes groups
[OSEv3:children]
masters
nodes

# Set variables common for all OSEv3 hosts
[OSEv3:vars]
ansible_ssh_user=$SUDOUSER
ansible_become=yes
openshift_install_examples=true
deployment_type=origin
openshift_release=v1.4
openshift_image_tag=v1.4.0
docker_udev_workaround=True
openshift_use_dnsmasq=false
openshift_override_hostname_check=true
openshift_master_default_subdomain=$ROUTING

openshift_master_cluster_public_hostname=$MASTERPUBLICIPHOSTNAME
openshift_master_cluster_public_vip=$MASTERPUBLICIPADDRESS

# Enable htpasswd auth for username / password authentication
openshift_master_identity_providers=[{'name': 'htpasswd_auth', 'login': 'true', 'challenge': 'true', 'kind': 'HTPasswdPasswordIdentityProvider', 'filename': '/etc/origin/master/htpasswd'}]

# host group for masters
[masters]
$MASTER.$DOMAIN

# host group for nodes
[nodes]
$MASTER.$DOMAIN openshift_node_labels="{'region': 'master', 'zone': 'default'}"
$NODE-[0:${NODELOOP}].$DOMAIN openshift_node_labels="{'region': 'infra', 'zone': 'default'}"
EOF

runuser -l $SUDOUSER -c "git clone https://github.com/openshift/openshift-ansible /home/$SUDOUSER/openshift-ansible"

echo "Executing Ansible playbook"

runuser -l $SUDOUSER -c "ansible-playbook openshift-ansible/playbooks/byo/config.yml"

echo "Modifying sudoers"

sed -i -e "s/Defaults    requiretty/# Defaults    requiretty/" /etc/sudoers
sed -i -e '/Defaults    env_keep += "LC_TIME LC_ALL LANGUAGE LINGUAS _XKB_CHARSET XAUTHORITY"/aDefaults    env_keep += "PATH"' /etc/sudoers

# Deploy Registry and Router

echo "Deploying Registry"

# runuser -l $SUDOUSER -c "sudo oadm registry"

echo "Deploying Router"

# runuser -l $SUDOUSER -c "sudo oadm router osrouter --replicas=$NODECOUNT --selector=region=infra"

echo "Re-enabling requiretty"

sed -i -e "s/# Defaults    requiretty/Defaults    requiretty/" /etc/sudoers

# Create OpenShift User

echo "Creating OpenShift User"

mkdir -p /etc/origin/master
htpasswd -cb /etc/origin/master/htpasswd ${SUDOUSER} ${PASSWORD}

echo "Script complete"