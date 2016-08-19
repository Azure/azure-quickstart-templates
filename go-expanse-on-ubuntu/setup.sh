#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# PURPOSE

# This script will setup expanse and all of its dependencies. It is primarily meant
# for running on cloud providers as a setup script.

# Specifically the script will install:
#   * go+git (useful for quick updates of the expanse tool)
#   * expanse

# The script assumes that it will be ran by a root user or a user with sudo
# privileges on the node. Note that it does not currently check that it has
# elevate privileges on the node.

# Note that the script also assumes that the user will be a bash user.

# -----------------------------------------------------------------------------
# LICENSE

# The MIT License (MIT)
# Copyright (c) 2016-Present Expanse Official.

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

# -----------------------------------------------------------------------------
# USAGE

# setup.sh USER [SERVICESTOSTART] [CHAINSTOSTART]

# -----------------------------------------------------------------------------
# Set defaults

expanseUser=$1
# -----------------------------------------------------------------------------
# Defaults

GOVERSION="1.5"
NODEVERSION="4"

# -----------------------------------------------------------------------------
# Install dependencies

echo "Hello there! I'm the marmot that installs expanse."
echo
echo
echo "Grabbing necessary dependencies"
export DEBIAN_FRONTEND=noninteractive
curl -sSL https://deb.nodesource.com/setup_"$NODEVERSION".x | sudo -E bash - &>/dev/null
sudo apt-get install -y git mercurial binutils bison gcc make libgmp3-dev build-essential &>/dev/null
curl -sSL https://storage.googleapis.com/golang/go"$GOVERSION".linux-amd64.tar.gz | sudo tar -C /usr/local -xzf - &>/dev/null
echo "Dependencies Installed."
echo
echo

####################
# Install sol compiler
####################
time sudo add-apt-repository ppa:ethereum/ethereum -y
time sudo apt-get update
time sudo apt-get install solc -y
# -----------------------------------------------------------------------------
# Install expanse

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
echo
echo "Building expanse."
git clone https://github.com/expanse-project/go-expanse.git
cd go-expanse
make gexp
cp build/bin/gexp /usr/bin/gexp

# -------------------------------------------------------------------------------
# Finish

echo
echo "expanse Installed!"