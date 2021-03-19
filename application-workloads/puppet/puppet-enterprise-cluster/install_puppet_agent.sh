#! /bin/sh

curl -k https://$1:8140/packages/current/install.bash | sudo bash
