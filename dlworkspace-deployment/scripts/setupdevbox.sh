#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y --no-install-recommends \
        apt-utils \
        software-properties-common \
        git \
        curl \
        python-pip \
        wget \
        cpio \
        apt-transport-https \
        openssh-client \
        ca-certificates \
        sshpass

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

apt-get update
apt-get install -y docker-ce

username=$1
shift

sudo usermod -aG docker $username

apt-get install -y --no-install-recommends python-yaml python-jinja2 python-setuptools python-tzlocal python-pycurl

git clone http://github.com/Microsoft/DLWorkspace /home/$username/DLWorkspace
git -C /home/$username/DLWorkspace fetch --all
git -C /home/$username/DLWorkspace checkout ARMTemplate

# Create configuration files, config.yaml, and cluster.yaml
/home/$username/DLWorkspace/src/ARM/createconfig.py genconfig --outfile /home/$username/DLWorkspace/src/ClusterBootstrap/config.yaml --admin_username $username "$@"
/home/$username/DLWorkspace/src/ClusterBootstrap/az_tools.py --default_admin_username $username --noaz genconfig

# Generate SSH keys
/home/$username/DLWorkspace/src/ClusterBootstrap/deploy.py -y build

# Copy ssh keys
/home/$username/DLWorkspace/src/ARM/createconfig.py sshkey --admin_username $username "$@"

# change owner to $username
chown -R $username /home/$username/DLWorkspace

# run deploy script in docker group, using user $username
sudo -H -u $username sg docker -c "bash /home/$username/DLWorkspace/src/ARM/deploycluster.sh $username"

