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

ADDNS=$1
PDC=$2
BDC=$3
PDCIP=$4
BDCIP=$5
ADMINUSER=$6
DOMAINADMINUSER=$7
DOMAINADMINPWD=$8
ADOUPATH=$9

replace_ad_params() {
    target=${1}
    shortdomain=`echo ${ADDNS} | sed 's/\.[^.]*$//'`
    sed -i "s/REPLACEADDOMAIN/${ADDNS}/g" ${target}
    sed -i "s/REPLACEUPADDOMAIN/${ADDNS^^}/g" ${target}
    sed -i "s/REPLACESHORTADDOMAIN/${shortdomain}/g" ${target}
    sed -i "s/REPLACEPDC/${PDC}/g" ${target}
    sed -i "s/REPLACEBDC/${BDC}/g" ${target}
    sed -i "s/REPLACEIPPDC/${PDCIP}/g" ${target}
    sed -i "s/REPLACEIPBDC/${BDCIP}/g" ${target}
}

# Disable the need for a tty when running sudo and allow passwordless sudo for the admin user
sed -i '/Defaults[[:space:]]\+!*requiretty/s/^/#/' /etc/sudoers
echo "$ADMINUSER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Disable SELinux
setenforce 0 
sed -i 's^SELINUX=enforcing^SELINUX=disabled^g' /etc/selinux/config

# Install and configure domain join packages
yum install -y ntp
yum -y remove samba-client
yum -y remove samba-common
yum -y install sssd
yum -y install sssd-client
yum -y install krb5-workstation
yum -y install samba4
yum -y install openldap-clients
yum -y install policycoreutils-python

cp -f resolv.conf /etc/resolv.conf
replace_ad_params /etc/resolv.conf
cp -f krb5.conf /etc/krb5.conf
replace_ad_params /etc/krb5.conf
cp -f smb.conf /etc/samba/smb.conf
replace_ad_params /etc/samba/smb.conf
cp -f sssd.conf /etc/sssd/sssd.conf
replace_ad_params /etc/sssd/sssd.conf
cp -f ntp.conf /etc/ntp.conf
replace_ad_params /etc/ntp.conf
sed -i "s/session.*pam_oddjob_mkhomedir.so.*/session     optional      pam_oddjob_mkhomedir.so skel=\/etc\/skel umask=0077/" /etc/pam.d/system-auth

cat > /etc/dhcp/dhclient-enter-hooks << EOF
#!/bin/sh
make_resolv_conf() {
echo "do not change resolv.conf"
}
EOF
chmod a+x /etc/dhcp/dhclient-enter-hooks

chmod 600 /etc/sssd/sssd.conf
service ntpd start
chkconfig ntpd on
service smb start
chkconfig smb on

# Join domain, must join domain first, otherwise sssd won't start
shortHostName=`hostname`
hostname ${shortHostName}.${ADDNS}
n=0
until [ $n -ge 3 ]
do
  if [ ! -z "$ADOUPATH" ]; then
    net ads join createcomputer="$ADOUPATH" -U${DOMAINADMINUSER}@${ADDNS}%${DOMAINADMINPWD}  
  else
    net ads join -U${DOMAINADMINUSER}@${ADDNS}%${DOMAINADMINPWD}  
  fi
  result=$?
  [ $result -eq 0 ] && break
  n=$[$n+1]
  sleep 15
done
if [ $result -eq 0 ]; then
  klist -k
  authconfig --enablesssd --enablemkhomedir --enablesssdauth --update
  service sssd restart
  chkconfig sssd on
fi
hostname ${shortHostName}