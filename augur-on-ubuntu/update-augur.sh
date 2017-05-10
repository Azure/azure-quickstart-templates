#!/bin/bash

set -x

echo "starting augur_ui update"

sudo stop augur_ui

HOMEDIR="/home/$USER"

cd $HOMEDIR

#####################
# Install latest augur ui
#####################
rm -rf ui
git clone https://github.com/AugurProject/augur.git
mkdir ui
cp -r augur/azure/* ui
cp $HOMEDIR/env.json ui/
rm -rf augur

sudo start augur_ui

echo "completed augur_ui install $$"