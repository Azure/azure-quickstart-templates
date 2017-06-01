#!/bin/bash

nemnet=$1

# setup data disk.
# from docker-neo4j template

# create a partition table for the disk
parted -s /dev/sdc mklabel msdos

# create a single large partition
parted -s /dev/sdc mkpart primary ext4 0\% 100\%

# install the file system
mkfs.ext4 /dev/sdc1

# create the mount point
mkdir /datadisk

# mount the disk
mount /dev/sdc1 /datadisk/

# add mount to /etc/fstab to persist across reboots
echo "/dev/sdc1    /datadisk/    ext4    defaults 0 0" >> /etc/fstab



# save stuff in /datadisk
home=/datadisk


# create directories needed by nem container
mkdir $home/nem/nis -p
mkdir $home/nem/ncc -p

# get supervisord config
cat > $home/supervisord.conf <<EOF
[supervisord]
nodaemon=true
logfile=/var/log/supervisor/supervisord.log
loglevel=debug

[program:nis]
user=nem
autostart=true
directory=/package/nis
command=java -Xms512M -Xmx1G -cp ".:./*:../libs/*" org.nem.deploy.CommonStarter
stderr_logfile=/home/nem/nem/nis/stderr.log
stderr_logfile_maxbytes=5MB
stderr_logfile_backups=10
stdout_logfile=/home/nem/nem/nis/stdout.log
stdout_logfile_maxbytes=5MB
stdout_logfile_backups=10


[program:ncc]
user=nem
autostart=false
directory=/package/ncc
command=java -cp ".:./*:../libs/*" org.nem.deploy.CommonStarter
stderr_logfile=/home/nem/nem/ncc/stderr.log
stderr_logfile_maxbytes=5MB
stderr_logfile_backups=10
stdout_logfile=/home/nem/nem/ncc/stdout.log
stdout_logfile_maxbytes=5MB
stdout_logfile_backups=10

[program:servant]
user=nem
autostart=false
stopsignal=KILL
startretries=0
directory=/servant
command=/bin/bash -c  "grep '<put your NIS boot key here' /servant/config.properties >/dev/null && { echo 'servant config file not updated!';  exit 1; } || exec java -Xms256M -Xmx256M -cp ".:jars/*" org.nem.rewards.servant.NodeRewardsServant"
stderr_logfile=/var/log/servant-stderr.log
stderr_logfile_maxbytes=5MB
stderr_logfile_backups=10
stdout_logfile=/var/log/servant-stdout.log
stdout_logfile_maxbytes=5MB
stdout_logfile_backups=10

[supervisorctl]
serverurl=unix://%(here)s/supervisor.sock

[unix_http_server]
file=%(here)s/supervisor.sock

[rpcinterface:supervisor]
supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface
EOF

key=$(< /dev/urandom tr -dc a-f0-9 | head -c64)
name=nemonazure_$(< /dev/urandom tr -dc a-z | head -c 20)

# generate random name and bootkey
cat > $home/nis.config-user.properties <<EOF
nis.bootName = $name
nis.bootKey = $key
nem.network = $nemnet
EOF

chown 1000 /datadisk/nem -R
