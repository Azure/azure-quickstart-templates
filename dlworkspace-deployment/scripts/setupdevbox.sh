#!/bin/bash

sudo apt-get update
sudo apt-get install -y --no-install-recommends \
        apt-utils \
        software-properties-common \
        git \
        curl \
        python-pip \
        wget \
        cpio \
        mkisofs \
        apt-transport-https \
        openssh-client \
        ca-certificates \
        sshpass

# Install docker
which docker
if [ $? -eq 0 ]
then
docker --version
## docker already installed
else
curl -q https://get.docker.com/ | sudo bash
fi

username=$1
shift

sudo usermod -aG docker $username

sudo apt-get install -y --no-install-recommends python-yaml python-jinja2 python-setuptools python-tzlocal python-pycurl

git clone http://github.com/Microsoft/DLWorkspace /home/$username/dlworkspace
cd /home/$username/dlworkspace
git fetch --all
git checkout ARMTemplate

# Create configuration files, config.yaml, and cluster.yaml
cd /home/$username/dlworkspace/src/ClusterBootstrap
../ARM/createconfig.py genconfig --outfile /home/$username/dlworkspace/src/ClusterBootstrap/config.yaml --admin_username $username "$@"
./az_tools.py --default_admin_username $username --noaz genconfig

# Generate SSH keys
./deploy.py -y build

# Copy ssh keys
../ARM/createconfig.py sshkey --admin_username $username "$@"

# change owner to $username
chown -R $username /home/$username/dlworkspace

# run deploy script in docker group, using user $username
sudo -H -u $username sg docker -c "bash /home/$username/dlworkspace/src/ARM/deploycluster.sh $username"

