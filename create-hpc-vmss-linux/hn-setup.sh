#!/bin/bash

scriptUri=$1
githubUser=$(echo "$scriptUri" | cut -d'/' -f4)
githubRepo=$(echo "$scriptUri" | cut -d'/' -f5)
githubBranch=$(echo "$scriptUri" | cut -d'/' -f6)

IP=`ifconfig eth0 | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'`
localip=`echo $IP | cut --delimiter='.' -f -3`

mkdir -p /mnt/resource/scratch
chmod a+rwx /mnt/resource/scratch

yum --enablerepo=extras install -y -q epel-release
yum install -y -q nfs-utils nmap pdsh screen git
# need to update for git work
yum update -y nss curl libcurl

# Host NFS
cat << EOF >> /etc/exports
/home $localip.*(rw,sync,no_root_squash,no_all_squash)
/mnt/resource/scratch $localip.*(rw,sync,no_root_squash,no_all_squash)
EOF

systemctl enable rpcbind
systemctl enable nfs-server
systemctl enable nfs-lock
systemctl enable nfs-idmap
systemctl start rpcbind
systemctl start nfs-server
systemctl start nfs-lock
systemctl start nfs-idmap
systemctl restart nfs-server

USER=$2
cat << EOF >> /home/$USER/.bashrc
export WCOLL=/home/$USER/scripts/hostfile
EOF
chown $USER:$USER /home/$USER/.bashrc

touch /home/$USER/scripts/hostfile
chown $USER:$USER /home/$USER/scripts/hostfile

# Setup passwordless ssh to compute nodes
ssh-keygen -f /home/$USER/.ssh/id_rsa -t rsa -N ''
cat << EOF > /home/$USER/.ssh/config
Host *
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
    PasswordAuthentication no
    LogLevel QUIET
EOF
cat /home/$USER/.ssh/id_rsa.pub >> /home/$USER/.ssh/authorized_keys
chmod 644 /home/$USER/.ssh/config
chown $USER:$USER /home/$USER/.ssh/*

# Don't require password for HPC user sudo
echo "$USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Add script for generating hostfile
cd /tmp
echo "git clone -b $githubBranch https://github.com/$githubUser/$githubRepo.git"
git clone -b $githubBranch https://github.com/$githubUser/$githubRepo.git
cd azure-quickstart-templates/create-hpc-vmss-linux/scripts/
mkdir -p /home/$USER/scripts
cp -r * /home/$USER/scripts/
chmod +x /home/$USER/scripts/*
chown $USER:$USER /home/$USER/scripts
cd /tmp && rm -rf /tmp/*
