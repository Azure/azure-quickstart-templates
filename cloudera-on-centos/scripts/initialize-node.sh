#!/bin/bash
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#   http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# 
# See the License for the specific language governing permissions and
# limitations under the License.

ADMINUSER=$1

# Disable the need for a tty when running sudo and allow passwordless sudo for the admin user
sed -i '/Defaults[[:space:]]\+!*requiretty/s/^/#/' /etc/sudoers
echo "$ADMINUSER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Mount and format the attached disks
sh ./prepareDisks.sh

# Create Impala scratch directory
numDataDirs=$(ls -la / | grep data | wc -l)
let endLoopIter=(numDataDirs - 1)
for x in $(seq 0 $endLoopIter)
do 
  mkdir -p /data${x}/impala/scratch
  chmod 777 /data${x}/impala/scratch
done

yum install -y ntp
service ntpd start
service ntpd status

#use the key from the key vault as the SSH authorized key
mkdir /home/$ADMINUSER/.ssh
chown $ADMINUSER /home/$ADMINUSER/.ssh
chmod 700 /home/$ADMINUSER/.ssh

ssh-keygen -y -f /var/lib/waagent/*.prv > /home/$ADMINUSER/.ssh/authorized_keys
chown $ADMINUSER /home/$ADMINUSER/.ssh/authorized_keys
chmod 600 /home/$ADMINUSER/.ssh/authorized_keys

#disable password authentication in ssh
sed -i "s/UsePAM\s*yes/UsePAM no/" /etc/ssh/sshd_config
sed -i "s/PasswordAuthentication\s*yes/PasswordAuthentication no/" /etc/ssh/sshd_config
/etc/init.d/sshd restart
