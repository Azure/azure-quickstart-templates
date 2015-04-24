#!/bin/bash

# Disable the need for a tty when running sudo
sed -i '/Defaults[[:space:]]\+!*requiretty/s/^/#/' /etc/sudoers

# Mount and format the attached disks
sh ./prepareDisks.sh
