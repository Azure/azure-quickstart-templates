# Script to add additional worker nodes or additional master nodes to an existing
# Openshift Cluster

export OCUSER=$1
export OCPASSWD=$2
export SUDOUSER=$3
export NODEMASTER=$4
export NODE=$5
export NODECOUNT=$6
export RHELUSERNAME=$7
export RHELPASSWORD=$8
export RHELPOOLID=$9
export MASTERPUBLICHOSTNAME=${10}

# Verify OpenShift Cluster is installed by attempting a login
oc login -u ${OCUSER} -p ${OCPASSWD} ${MASTERPUBLICHOSTNAME} --insecure-skip-tls-verify=true
if [[ $? -ne 0 ]]; then
    echo "OpenShift Cluster Login Failed"
    exit 1
else
    echo "OpenShift Cluster Login Successful"
fi

# Verify Openshift Ansible Exists, if not download it
if [[ ! -d "/home/$SUDOUSER/openshift-ansible" ]]; then
    echo "Cannot find Openshift Ansible files, attempting to download them"
    runuser -l $SUDOUSER -c "git clone -b release-3.11 https://github.com/openshift/openshift-ansible /home/$SUDOUSER/openshift-ansible"
else
    echo "Openshift-Ansible files found"
fi

# Create Node Grouping
echo $(date) " - Creating Nodes grouping"
if [[ $NODEMASTER == "node" ]]; then
  nodegroup="$NODE-0 openshift_node_group_name='node-config-compute'"
  for (( c=1; c<$NODECOUNT; c++ ))
    do
    nodegroup="$nodegroup\n$NODE-$c openshift_node_group_name='node-config-compute'"
  done
fi

if [[ $NODEMASTER == "infra" ]]; then
  nodegroup="$NODE-0 openshift_node_group_name='node-config-infra'"
  for (( c=1; c<$NODECOUNT; c++ ))
    do
    nodegroup="$nodegroup\n$NODE-$c openshift_node_group_name='node-config-infra'"
  done
fi

if [[ $NODEMASTER == "master" ]]; then
  nodegroup="$NODE-0 openshift_node_group_name='node-config-master'"
  for (( c=1; c<$NODECOUNT; c++ ))
    do
    nodegroup="$nodegroup\n$NODE-$c openshift_node_group_name='node-config-master'"
  done
fi

echo $(date) " - Nodes grouping done. Nodegroup: $nodegroup"

echo $(date) " - Creating temp inventory file to config new nodes"
cat > /tmp/confighosts <<EOF
[nodes]

[OSEv3:children]
nodes

[OSEv3:vars]
ansible_ssh_user=$SUDOUSER
ansible_become=yes
oreg_auth_user=$RHELUSERNAME
oreg_auth_password=$RHELPASSWORD
EOF
sed -i "/^\[nodes\]/a $nodegroup" /tmp/confighosts
echo $(date) " - Creating temp inventory file complete"

# Install Dependencies
echo $(date) " - Registering nodes and installing dependencies"
runuser -l $SUDOUSER -c "(cd /home/$SUDOUSER && curl -O https://devocpartifacts.blob.core.windows.net/ansible-config/config.yml)"
runuser -l $SUDOUSER -c "ansible-playbook -i /tmp/confighosts /home/$SUDOUSER/config.yml --extra-vars \"poolid=$RHELPOOLID\""
echo $(date) " - Registering nodes and installing dependencies COMPLETED"

# Input the NodeGroup into a temp /etc/ansible/hosts file
echo $(date) " - Add nodegroup to /etc/ansible/hosts file"

echo "sed -i \"/^\[new_nodes\]/a $nodegroup\" /etc/ansible/hosts"
sed -i "/^\[new_nodes\]/a $nodegroup" /etc/ansible/hosts

if [[ $NODEMASTER == "master" ]]; then
  echo "sed -i \"/^\[new_masters\]/a $nodegroup\" /etc/ansible/hosts"
  sed -i "/^\[new_masters\]/a $nodegroup" /etc/ansible/hosts
fi
echo $(date) " - Add nodegroup complete"

# ScaleUp Nodes
if [[ $NODEMASTER != "master" ]]; then
  echo "Running openshift-ansible/playbooks/openshift-node/scaleup.yml"
  runuser -l $SUDOUSER -c "ansible-playbook -f 10 /home/$SUDOUSER/openshift-ansible/playbooks/openshift-node/scaleup.yml"
else
  echo "Running openshift-ansible/playbooks/openshift-master/scaleup.yml"
  runuser -l $SUDOUSER -c "ansible-playbook -f 10 /home/$SUDOUSER/openshift-ansible/playbooks/openshift-master/scaleup.yml"
  runuser -l $SUDOUSER -c "ansible new_masters -m command -a \"htpasswd -b /etc/origin/master/htpasswd $OCUSER $OCPASSWD\""
  runuser -l $SUDOUSER -c "ansible new_masters -m command -a \"oc adm policy add-cluster-role-to-user cluster-admin $OCUSER\""
fi

# Copy docker registry
oc login -u ${OCUSER} -p ${OCPASSWD} ${MASTERPUBLICHOSTNAME} --insecure-skip-tls-verify=true

oc new-project zen
registry=$(oc get routes -n default | grep docker-registry | awk '{print $2}')

# Copy docker-registry certificate from master node
cat > /home/$OCUSER/fetch.yml << EOF
---
- hosts: master0
  tasks:
  - name: Copy cert to a user directory
    copy:
      src: "/etc/origin/node/client-ca.crt"
      dest: "/home/{{ user }}/node-client-ca.crt"
      remote_src: yes
    when: user is defined
  - name: Remote fetch docker-registry certificate from master0
    fetch:
      src: "/home/{{ user }}/node-client-ca.crt"
      dest: "/tmp/"
      flat: yes
    when: registry is defined
  - name: delete crt file
    file:
      path: "/home/{{ user }}/node-client-ca.crt"
      state: absent
- hosts: new_nodes
  tasks:
  - name: create directory
    file:
      path: /etc/docker/certs.d/{{ registry }}
      state: directory
  - name: Copy certs from default to custom domain
    copy:
      src: "/etc/docker/certs.d/docker-registry.default.svc:5000/node-client-ca.crt"
      dest: "/etc/docker/certs.d/{{ registry }}/"
      remote_src: yes
EOF

echo "Running fetch playbook"
runuser -l $OCUSER -c "ansible-playbook /home/$OCUSER/fetch.yml --extra-vars \"registry=$registry user=$OCUSER\""
echo "Fetch Playbook complete"

echo "Create docker registry certs folder"
mkdir -p /etc/docker/certs.d/$registry
echo "Create docker registry certs folder complete"

echo "Move cert to /etc/docker/certs.d/$registry/"
mv /tmp/node-client-ca.crt /etc/docker/certs.d/$registry/
echo "Move certs complete"

#Docker login
echo "Docker login to $registry registry"
docker login -u $(oc whoami) -p $(oc whoami -t) $registry
echo "Docker login complete"

# Clean up

# Delete the new nodes from their respective categories
echo "sed -i \"/^$NODE/d\" /etc/ansible/hosts"
sed -i "/^$NODE/d" /etc/ansible/hosts

# Add nodegroup to [nodes] section
echo "sed -i \"/^\[nodes\]/a $nodegroup\" /etc/ansible/hosts"
sed -i "/^\[nodes\]/a $nodegroup" /etc/ansible/hosts

echo "Script End."