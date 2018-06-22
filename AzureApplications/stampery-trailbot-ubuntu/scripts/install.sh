#!/bin/bash

set -e

#################################################################
# Update Ubuntu and install prerequisites for running Trailbot  #
#################################################################
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
DEBIAN_FRONTEND=noninteractive apt-get install -y git nodejs rng-tools mailutils build-essential

#################################################################
# Get the watcher code and install its npm dependencies         #
#################################################################
git clone https://github.com/trailbot/watcher
cd watcher
git checkout azure
npm install --production --ignore-scripts

#################################################################
# Fake setup                                                    #
#################################################################
mkdir .localstorage
echo "[\"azure\"]" > .localstorage/mods
echo "vault.trailbot.io:8443" > .localstorage/vault
echo "$1" > .localstorage/user_email
echo -e "-----BEGIN PGP PUBLIC KEY BLOCK-----\n\n" > .localstorage/client_pub_key
echo -e $(echo "$2" | sed 's/  /@/g' | cut -d@ -f2 | cut -d- -f1 | sed 's/ /\\n/g') >> .localstorage/client_pub_key
echo -e "\n-----END PGP PUBLIC KEY BLOCK-----" >> .localstorage/client_pub_key

#################################################################
# Keypar generation                                             #
#################################################################
rngd -r /dev/urandom
gpg --batch --armor --gen-key <<EOF
  Key-Type: RSA
  Key-Length: 4096
  Subkey-Type: RSA
  Subkey-Length: 4096
  Name-Real: "$(hostname)"
  Name-Email: "watcher@$(hostname)"
  Expire-Date: 0
  %no-protection
  %secring .localstorage/watcher_priv_key
  %pubring .localstorage/watcher_pub_key
  %echo Generating keypar...
  %commit
  %echo Keypar generated successfully!
EOF

#################################################################
# Send public key to admin via email                            #
#################################################################
echo "Please find enclosed the public key for the Trailbot Watcher \
installed at $(hostname)" | mail \
  -a ".localstorage/watcher_pub_key" \
  -s "Successful installation of Trailbot Watcher at $(hostname)" \
  $1

#################################################################
# Service creation and start up                                 #
#################################################################
sh scripts/service
exit 0
