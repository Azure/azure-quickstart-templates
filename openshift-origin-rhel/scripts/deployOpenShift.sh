#!/bin/bash

set -e

SUDOUSER=$1
PUBLICKEY=$2
PRIVATEKEY=$3
MASTER=$4
MASTERPUBLICIPHOSTNAME=$5
MASTERPUBLICIPADDRESS=$6
NODEPREFIX=$7
NODECOUNT=$8
AZUREADAPPNAME=$9
AZUREADCLIENTID=${10}
AZUREADCLIENTSECRET=${11}
AZUREADTENANTID=${12}
AZUREADLOGOUTREDIRECTURI=${13}
DOMAIN=$( awk 'NR==2' /etc/resolv.conf | awk '{ print $2 }' )

echo "Generating keys"

runuser -l $SUDOUSER -c "echo \"$PUBLICKEY\" > ~/.ssh/id_rsa.pub"
runuser -l $SUDOUSER -c "echo \"$PRIVATEKEY\" > ~/.ssh/id_rsa"
runuser -l $SUDOUSER -c "chmod 600 ~/.ssh/id_rsa*"

echo "Configuring SSH ControlPath to use shorter path name"

sed -i -e "s/^# control_path = %(directory)s\/%%h-%%r/control_path = %(directory)s\/%%h-%%r/" /etc/ansible/ansible.cfg
sed -i -e "s/^#host_key_checking = False/host_key_checking = False/" /etc/ansible/ansible.cfg
sed -i -e "s/^#pty=False/pty=False/" /etc/ansible/ansible.cfg

echo "Generating Ansible hosts file"

cat > /etc/ansible/hosts <<EOF
# Create an OSEv3 group that contains the masters and nodes groups
[OSEv3:children]
masters
nodes

# Set variables common for all OSEv3 hosts
[OSEv3:vars]
ansible_ssh_user=$SUDOUSER
ansible_sudo=true
deployment_type=origin
docker_udev_workaround=True
# containerized=true
openshift_use_dnsmasq=no

openshift_master_cluster_public_hostname=$MASTERPUBLICIPHOSTNAME
openshift_master_cluster_public_vip=$MASTERPUBLICIPADDRESS

# Enable Azure AD auth
openshift_master_identity_providers=[{'name': '$AZUREADAPPNAME', 'login': 'true', 'challenge': 'false', 'kind': 'OpenIDIdentityProvider', 'client_id': '$AZUREADCLIENTID', 'client_secret': '$AZUREADCLIENTSECRET', 'extra_scopes': [], 'extra_authorize_parameters': {}, 'claims': { 'id': ['sub'], 'preferredUsername': ['unique_name'], 'name': ['unique_name'], 'email': ['unique_name']}, 'urls': {'authorize': 'https://login.microsoftonline.com/$AZUREADTENANTID/oauth2/authorize', 'token': 'https://login.microsoftonline.com/$AZUREADTENANTID/oauth2/token'}}]
openshift_master_logout_url='https://login.microsoftonline.com/$AZUREADTENANTID/oauth2/logout?post_logout_redirect_uri=$AZUREADLOGOUTREDIRECTURI'

# host group for masters
[masters]
$MASTER.$DOMAIN

# host group for nodes
[nodes]
$MASTER.$DOMAIN
EOF

for (( c=0; c<$NODECOUNT; c++ ))
do
  echo "$NODEPREFIX-$c.$DOMAIN" >> /etc/ansible/hosts
done


# Reverting to April 22, 2016 commit

echo "Cloning openshift-ansible repository and reseting to April 22, 2016 commit"

runuser -l $SUDOUSER -c "git clone https://github.com/openshift/openshift-ansible /home/$SUDOUSER/openshift-ansible"
runuser -l $SUDOUSER -c "git --git-dir="/home/$SUDOUSER/openshift-ansible/.git" --work-tree="/home/$SUDOUSER/openshift-ansible/" reset --hard 04b5245"

echo "Executing Ansible playbook"

runuser -l $SUDOUSER -c "ansible-playbook openshift-ansible/playbooks/byo/config.yml"

echo "Modifying sudoers"

sed -i -e "s/Defaults    requiretty/# Defaults    requiretty/" /etc/sudoers
sed -i -e '/Defaults    env_keep += "LC_TIME LC_ALL LANGUAGE LINGUAS _XKB_CHARSET XAUTHORITY"/aDefaults    env_keep += "PATH"' /etc/sudoers

echo "Deploying Registry"

runuser -l $SUDOUSER -c "sudo oadm registry --config=/etc/origin/master/admin.kubeconfig --credentials=/etc/origin/master/openshift-registry.kubeconfig"

echo "Deploying Router"

runuser -l $SUDOUSER -c "sudo oadm router osrouter --replicas=$NODECOUNT --credentials=/etc/origin/master/openshift-router.kubeconfig --service-account=router"

echo "Re-enabling requiretty"

sed -i -e "s/# Defaults    requiretty/Defaults    requiretty/" /etc/sudoers