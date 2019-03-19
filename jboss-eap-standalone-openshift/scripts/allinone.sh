#!/bin/bash

if mkdir ~/allinone.lock; then
  echo "Locking succeeded" >&2
else
  echo "Lock failed - exit" >&2
  exit 1
fi
export MYARGS=$@
IFS=' ' read -r -a array <<< "$MYARGS"
export RESOURCEGROUP=$1
export WILDCARDZONE=$2
export AUSERNAME=$3
export PASSWORD=$4
export THEHOSTNAME=$5
export RHSM_USER=$6
export RHSM_PASSWORD="$7"
export RHSM_POOL=$8
export FULLDOMAIN=${THEHOSTNAME#*.*}
export WILDCARDFQDN=${WILDCARDZONE}.${FULLDOMAIN}
export WILDCARDIP=`dig +short ${WILDCARDFQDN}`
export WILDCARDNIP=${WILDCARDIP}.nip.io
touch /tmp/envVars.out
echo "Show wildcard info" >> /tmp/envVars.out
echo "WILDCARDFQDN " $WILDCARDFQDN >> /tmp/envVars.out
echo "WILDCARDIP " $WILDCARDIP >> /tmp/envVars.out
echo "WILDCARDNIP " $WILDCARDNIP >> /tmp/envVars.out
echo "RHSMMODE " $RHSMMODE >> /tmp/envVars.out
echo "RESOURCEGROUP " $RESOURCEGROUP >> /tmp/envVars.out
echo "WILDCARDZONE " $WILDCARDZONE >> /tmp/envVars.out
echo "AUSERNAME " $AUSERNAME >> /tmp/envVars.out
echo "PASSWORD " $PASSWORD >> /tmp/envVars.out
echo "THEHOSTNAME " $THEHOSTNAME >> /tmp/envVars.out
echo "RHSM_USER " $RHSM_USER >> /tmp/envVars.out
echo "RHSM_PASSWORD " $RHSM_PASSWORD >> /tmp/envVars.out
echo "RHSM_POOL " $RHSM_POOL >> /tmp/envVars.out
echo "FULLDOMAIN " $FULLDOMAIN >> /tmp/envVars.out

domain=$(grep search /etc/resolv.conf | awk '{print $2}')

ps -ef | grep allinone.sh > cmdline.out

swapoff -a
subscription-manager register --username=${RHSM_USER} --password=${RHSM_PASSWORD} || subscription-manager register --org=${RHSM_USER} --activationkey=${RHSM_PASSWORD}
subscription-manager attach --pool=${RHSM_POOL}
subscription-manager repos --disable="*" --enable="rhel-7-server-rpms" --enable="rhel-7-server-extras-rpms" --enable="rhel-7-server-ose-3.9-rpms" --enable="rhel-7-fast-datapath-rpms" --enable="rhel-7-server-ansible-2.4-rpms"
yum install -y wget git net-tools bind-utils yum-utils iptables-services bridge-utils bash-completion kexec-tools sos psacct httpd-tools pyOpenSSL ansible atomic-openshift-utils
mkdir -p /usr/share/ansible
cd /usr/share/ansible/

cat <<EOF > /etc/ansible/hosts
[OSEv3:children]
masters
nodes
etcd

[OSEv3:vars]
debug_level=2
console_port=8443
openshift_node_debug_level="{{ node_debug_level | default(debug_level, true) }}"
openshift_master_debug_level="{{ master_debug_level | default(debug_level, true) }}"
openshift_master_access_token_max_seconds=2419200
openshift_hosted_router_replicas=1
openshift_hosted_registry_replicas=1
openshift_master_api_port=8443
openshift_master_console_port=8443
openshift_override_hostname_check=true
azure_resource_group=${RESOURCEGROUP}
deployment_type=openshift-enterprise
ansible_become=true
openshift_disable_check=memory_availability,disk_availability,docker_storage,package_version,docker_image_availability,package_availability
openshift_master_default_subdomain=${WILDCARDNIP}
osm_default_subdomain=${WILDCARDNIP}

#openshift_public_hostname=${RESOURCEGROUP}.${FULLDOMAIN}
openshift_public_hostname=${WILDCARDZONE}.${FULLDOMAIN}
container_runtime_docker_storage_setup_device=/dev/sdc
#openshift_master_cluster_hostname=${RESOURCEGROUP}.${FULLDOMAIN}
openshift_master_cluster_hostname=${WILDCARDZONE}.${FULLDOMAIN}
#openshift_master_cluster_public_hostname=${RESOURCEGROUP}.${FULLDOMAIN}
openshift_master_cluster_public_hostname=${WILDCARDZONE}.${FULLDOMAIN}
openshift_enable_service_catalog=false
openshift_master_identity_providers=[{'name': 'htpasswd_auth', 'login': 'true', 'challenge': 'true', 'kind': 'HTPasswdPasswordIdentityProvider', 'filename': '/etc/origin/master/htpasswd'}]
openshift_master_manage_htpasswd=false
oreg_url_master=registry.access.redhat.com/openshift3/ose-\${component}:\${version}

oreg_url_node=registry.access.redhat.com/openshift3/ose-\${component}:\${version}

openshift_examples_modify_imagestreams=true

oreg_url=registry.access.redhat.com/openshift3/ose-\${component}:\${version}

# Do not install metrics but post install
openshift_metrics_install_metrics=false

# Do not install logging but post install
openshift_logging_install_logging=false

openshift_logging_use_ops=false

[masters]
${RESOURCEGROUP} openshift_hostname=${RESOURCEGROUP} ansible_connection=local

[etcd]
${RESOURCEGROUP} ansible_connection=local

[nodes]
${RESOURCEGROUP} openshift_hostname=${RESOURCEGROUP} openshift_node_labels="{'role':'master','region':'app','region': 'infra'}" openshift_schedulable=true ansible_connection=local
EOF

ansible-playbook -i /etc/ansible/hosts /usr/share/ansible/openshift-ansible/playbooks/prerequisites.yml
ansible-playbook -i /etc/ansible/hosts /usr/share/ansible/openshift-ansible/playbooks/deploy_cluster.yml
htpasswd -c -b /etc/origin/master/htpasswd ${AUSERNAME} ${PASSWORD}
oc login -u ${AUSERNAME} -p ${PASSWORD} --insecure-skip-tls-verify ${WILDCARDZONE}.${FULLDOMAIN}:8443
oc new-project dukes --display-name="My first webapp called dukes" --description="This is a demo web project to test EAP on OCP"
oc new-app openshift/jboss-eap71-openshift:1.2~https://github.com/MyriamFentanes/dukes.git
oc expose svc/dukes --hostname ""


