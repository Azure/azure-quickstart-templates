#!/bin/bash

mysqlPassword=$1
osUser=$2

#install mha manager
cd /tmp/
wget http://mysql-master-ha.googlecode.com/files/mha4mysql-node_0.53_all.deb > /dev/null 2>&1
wget http://mysql-master-ha.googlecode.com/files/mha4mysql-manager_0.53_all.deb > /dev/null 2>&1
apt-get update > /dev/null 2>&1
apt-get install libdbd-mysql-perl -y > /dev/null 2>&1
apt-get install libconfig-tiny-perl -y > /dev/null 2>&1
apt-get install liblog-dispatch-perl -y > /dev/null 2>&1
apt-get install libparallel-forkmanager-perl -y > /dev/null 2>&1
dpkg -i mha4mysql-node_0.53_all.deb > /dev/null 2>&1
dpkg -i mha4mysql-manager_0.53_all.deb > /dev/null 2>&1

#install mysql-client
apt-get install mysql-client -y > /dev/null 2>&1

#configure mha manager
mkdir -p /var/log/masterha/app1
mkdir -p /script/masterha
cat > /etc/app1.cnf <<EOF
[server default]
# mysql user and password
user=root
password=$mysqlPassword
ssh_user=$osUser
master_binlog_dir= /var/log/mysql
# working directory on the manager
manager_workdir=/var/log/masterha/app1
# manager log file
manager_log=/var/log/masterha/app1/app1.log
# working directory on MySQL servers
remote_workdir=/var/log/masterha/app1
secondary_check_script= masterha_secondary_check -s 10.0.0.11 -s 10.0.0.12
ping_interval=1
#master_ip_failover_script=/script/masterha/master_ip_failover
#shutdown_script= /script/masterha/power_manager
#report_script= /script/masterha/send_report

[server1]
hostname=10.0.0.10

[server2]
hostname=10.0.0.11
candidate_master=1

[server3]
hostname=10.0.0.12
no_master=1
EOF


#install haproxy
cd /tmp
wget http://www.haproxy.org/download/1.6/src/haproxy-1.6.3.tar.gz > /dev/null 2>&1
tar zxvf haproxy-1.6.3.tar.gz
cd haproxy-1.6.3
apt-get install make gcc -y > /dev/null 2>&1

make TARGET=linux2628 PREFIX=/usr/local/haproxy
make install PREFIX=/usr/local/haproxy
cat > /usr/local/haproxy/haproxy.cfg <<EOF
global
       maxconn 4096
       chroot /usr/local/haproxy
        uid 99
        gid 99
       daemon
       pidfile /usr/local/haproxy/haproxy.pid

defaults
       log    global
        log     127.0.0.1       local3
       mode    tcp
       option  tcplog
        option  dontlognull
        option  httpclose
       retries 3
       option  redispatch
       maxconn 2000
       timeout connect     5000
       timeout client     50000
       timeout server     50000

frontend mysqlwrite-in
       bind *:3306
        mode    tcp
        option  tcplog
        log     global
        default_backend mysqlwritepool

frontend mysqlread-in
      bind *:3307
      mode tcp
      option tcplog
      log global
      default_backend mysqlreadpool

backend mysqlwritepool
       balance roundrobin
       server  mysql01 10.0.0.10:3306  weight 5 check inter 2000 rise 2 fall 3

backend mysqlreadpool
       balance roundrobin
        server  10.0.0.11 10.0.0.11:3306  weight 5 check inter 2000 rise 2 fall 3
        server  10.0.0.12 10.0.0.12:3306  weight 5 check inter 2000 rise 2 fall 3
EOF


#master ip check script
cat > /usr/local/haproxy/master_ip_check.sh <<EOF
#!/usr/bin/env bash
haproxyDir=/usr/local/haproxy
haproxyConFile=/usr/local/haproxy/haproxy.cfg
haproxyPidFile=/usr/local/haproxy/haproxy.pid
masterIP=\$1
candiMasterIP=\$2
mysqlUser=root
mysqlPass=$mysqlPassword
usage() {

echo "execution method: \`basename \$0\` masterip candimasterip

Most import thing is the 1st parameter should be the mysql running master ip address; the 2nd parameter is the candidate master ip address
"
}
if [[ \$# -ne 2 ]] ;then
usage
exit
fi
while :
do
result=\`mysql -u\$mysqlUser -p\$mysqlPass -h \$candiMasterIP -e "show slave status\G"\`
if [[ -n \$result ]];then   #the candidate master is still slave

slaveRunningNumber=\`mysql -u\$mysqlUser -p\$mysqlPass -h \$candiMasterIP -e "show slave status\G" |grep -i "running: Yes" |wc -l\`
  if [[ \$slaveRunningNumber -ne 2 ]];then                     #master-slave has problem
     echo "checked at \$(date +"%F %H:%M:%S"):candidate master \$candiMasterIP slave status is not OK, please check ! "
  fi
else              #the candidate master is no longer slave
sed -i "s/\$masterIP:3306/\$candiMasterIP:3306/" \$haproxyConFile         #master ip failover
\$haproxyDir/sbin/haproxy -f \$haproxyConFile -st \`cat \$haproxyPidFile\`   #reload
  if [[ \$? -eq 0 ]];then
    echo "at \$(date +"%F %H:%M:%S"): master ip failover, \$candiMasterIP becomes the master, reloaded haproxy process. "
    exit  #quit with mha manager the same time
  else
    echo "at \$(date +"%F %H:%M:%S"): reloaded haproxy process failed. Please check haproxy ! quit the shell script ! "
    exit
  fi
fi
sleep 1
done
EOF



#slave ip check script
cat > /usr/local/haproxy/slave_ip_check.sh <<EOF
#!/usr/bin/env bash
haproxyDir=/usr/local/haproxy
haproxyConFile=/usr/local/haproxy/haproxy.cfg
haproxyPidFile=/usr/local/haproxy/haproxy.pid
mysqlBackendReadPool=mysqlreadpool
mysqlUser=root
mysqlPass=$mysqlPassword

usage() {

echo "execution method: \`basename \$0\` slaveip1 slaveip2 ...

"
}

restartHaproxy() {
\$haproxyDir/sbin/haproxy -f \$haproxyConFile -st \`cat \$haproxyPidFile\`   #reload
if [[ \$? -eq 0 ]];then
  echo "at \$(date +"%F %H:%M:%S"): reloaded haproxy process. "
else
  echo "at \$(date +"%F %H:%M:%S"): reloaded haproxy process failed. Please check haproxy ! "
fi
}

if [[ \$# -eq 0 ]] ;then
usage
exit
fi


while :
do
for slaveIP in "\$@"
do
result=\`mysql -u\$mysqlUser -p\$mysqlPass -h \$slaveIP -e "show slave status\G"\`
slaveResult=\`sed -n "/^backend.*\$mysqlBackendReadPool/,/^backend/{/\$slaveIP/p}" \$haproxyConFile\`
if [[ -n \$result ]];then   #the slave is still slave

slaveRunningNumber=\`mysql -u\$mysqlUser -p\$mysqlPass -h \$slaveIP -e "show slave status\G" |grep -i "running: Yes" |wc -l\`
  if [[ \$slaveRunningNumber -ne 2 ]];then                      #master-slave has problem
     echo "checked at \$(date +"%F %H:%M:%S"):MySQL \$slaveIP slave status is not OK, please check ! "
  elif [[ -z \$slaveResult ]];then  #slave is not in the read pool
      #add the slave in the read pool
      sed -i "/^backend.*\$mysqlBackendReadPool/,/^backend/{:a;N;s/balance.*/&\n        server  \$slaveIP \$slaveIP:3306  weight 5 check inter 2000 rise 2 fall 3/}" \$haproxyConFile
      restartHaproxy
  fi
else              #the slave is no longer slave
  sed -i "/^backend.*\$mysqlBackendReadPool/,/^backend/{/\$slaveIP/d}" \$haproxyConFile         #remove from the read pool
  restartHaproxy
  exit   #quit with mha manager the same time
fi
sleep 1
done
done
EOF

sed -i '/my \$msg  = \$args{message};$/a $msg = \"\" unless($msg);' /usr/share/perl5/MHA/ManagerConst.pm
sed -i 's/^\($msg = "" unless($msg);\)$/  \1/' /usr/share/perl5/MHA/ManagerConst.pm
chown ${osUser}:${osUser} /etc/app1.cnf
chmod 600 /etc/app1.cnf
chown ${osUser}:${osUser} -R /var/log/masterha/
chown ${osUser}:${osUser} /usr/local/haproxy/master_ip_check.sh
chown ${osUser}:${osUser} /usr/local/haproxy/slave_ip_check.sh
chmod 700 /usr/local/haproxy/master_ip_check.sh
chmod 700 /usr/local/haproxy/slave_ip_check.sh

