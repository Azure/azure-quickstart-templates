#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# PURPOSE

# This script will setup eris and all of its dependencies. It is primarily meant
# for running on cloud providers as a setup script.

# Specifically the script will install:
#   * nodejs (useful for middleware)
#   * go+git (useful for quick updates of the eris tool)
#   * eris

# The script assumes that it will be ran by a root user or a user with sudo
# privileges on the node. Note that it does not currently check that it has
# elevate privileges on the node.

# Note that the script, by default, will **not** install Docker which is a
# **required** dependency for Eris. If, however, the environment variable
# $INSTALL_DOCKER is not blank, then the script will install docker via the
# easy docker installation. If this makes you paranoid then you should
# manually install docker **before** running this script.

# Note that the script also assumes that the user will be a bash user.

# -----------------------------------------------------------------------------
# LICENSE

# The MIT License (MIT)
# Copyright (c) 2016-Present Eris Industries, Ltd.

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.

# -----------------------------------------------------------------------------
# REQUIREMENTS

# Ubuntu
# Docker (**unless** INSTALL_DOCKER is not blank)

# -----------------------------------------------------------------------------
# USAGE

# setup.sh USER [SERVICESTOSTART] [CHAINSTOSTART]

# -----------------------------------------------------------------------------
# Set defaults

erisUser=$1
services=( $(echo $2 | tr "," "\n") )
chains=( $(echo $3 | tr "," "\n") )
toStart=( "${services[@]}" "${chains[@]}" )

# -----------------------------------------------------------------------------
# Defaults

GOVERSION="1.6"
NODEVERSION="4"

# -----------------------------------------------------------------------------
# Install dependencies

echo "Hello there! I'm the marmot that installs Eris."
echo
echo
echo "Grabbing necessary dependencies"
export DEBIAN_FRONTEND=noninteractive
curl -sSL https://deb.nodesource.com/setup_"$NODEVERSION".x | sudo -E bash - &>/dev/null
sudo apt-get install -y jq gcc git build-essential nodejs &>/dev/null
curl -sSL https://storage.googleapis.com/golang/go"$GOVERSION".linux-amd64.tar.gz | sudo tar -C /usr/local -xzf - &>/dev/null
if [ -n "$INSTALL_DOCKER" ]
then
  curl -sSL https://get.docker.com/ | sudo -E bash - &>/dev/null
fi
sudo usermod -a -G docker $erisUser &>/dev/null
echo "Dependencies Installed."
echo
echo

# -----------------------------------------------------------------------------
# Getting chains

echo "Getting Chain managers"
curl -sSL -o /home/$erisUser/simplechain.sh https://raw.githubusercontent.com/eris-ltd/common/master/cloud/chains/simplechain.sh
chmod +x /home/$erisUser/*.sh
chown $erisUser:$erisUser /home/$erisUser/*.sh
echo "Chain managers acquired."
echo
echo

# -----------------------------------------------------------------------------
# Install eris

sudo -u "$erisUser" -i env START="`printf ",%s" "${toStart[@]}"`" bash <<'EOF'
start=( $(echo $START | tr "," "\n") )
echo "Setting up Go for the user"
mkdir --parents $HOME/go
export GOPATH=$HOME/go
export PATH=$HOME/go/bin:/usr/local/go/bin:$PATH
echo "export GOROOT=/usr/local/go" >> $HOME/.bashrc
echo "export GOPATH=$HOME/go" >> $HOME/.bashrc
echo "export PATH=$HOME/go/bin:/usr/local/go/bin:$PATH" >> $HOME/.bashrc
echo "Finished Setting up Go."
echo
echo
echo "Version Information"
echo
go version
echo
docker version
echo
echo
echo "Building eris."
go get github.com/eris-ltd/eris-cli/cmd/eris
echo
echo
echo "Initializing eris."
export ERIS_PULL_APPROVE="true"
export ERIS_MIGRATE_APPROVE="true"
echo "export ERIS_PULL_APPROVE=\"true\"" >> $HOME/.bashrc
echo "export ERIS_MIGRATE_APPROVE=\"true\"" >> $HOME/.bashrc
eris init --yes 2>/dev/null
echo
echo
echo "Starting Services and Chains: ${start[@]}"
echo
if [ ${#start[@]} -eq 0 ]
then
  echo "No services or chains selected"
else
  for x in "${start[@]}"
  do
    if [ -f "$HOME/$x".sh ]
    then
      echo "Turning on Chain: $x"
      $HOME/$x.sh
    else
      echo "Turning on Service: $x"
      eris services start $x
    fi
  done
fi
EOF

echo
echo "Finished starting services and chains."

# -------------------------------------------------------------------------------
# Cleanup

rm /home/$erisUser/*.sh
echo
echo
echo "Eris Installed!"
