#!/bin/bash

## What is this?
# Use this script to install MariaDB with Galera Cluster on a cluster of machines with no prior MariaDB setup.

# Note: MariaDB 10.1 currently fails to install on Ubuntu 16.04 LTS due to an unmet package dependency on libsystemd-daemon0
# As a result, please use Ubuntu 14.04 LTS instead.

## config ##
## edit here ##

## TAKE CARE, SETTING OVERWRITE TO 1 WILL REMOVE ANY EXISTING MYSQL/MARIADB INSTALATION ON THE SPECIFIED CLUSTER NODES!
OVERWRITE=0

# start cluster directly after setup
START=1

# the system user with sudo privileges on the cluster nodes
DBNODEUSER=  # Enter your MySQL Root User Here
# dsh group containing all cluster nodes to set up
DSHGROUP=dball
# MySQL root user password
MYSQLPASSWORD= # PUT A PASSWORD HERE
# InnoDB buffer pool size (in M)
INNOBUFFER=1024M # this seems a good size for A1 Standard on Azure, pick 80% of available memory for dedicated DB server

# cluster node IP addresses
IP[0]=10.10.100.6
IP[1]=10.10.100.7
IP[2]=10.10.100.8
IP[3]=10.12.100.6
IP[4]=10.12.100.7

# settings you shouldn't probably need to change ever
# first node to start the cluster
FIRST=${IP[0]} # you probably should not touch this ever, this NEEDS to be the first element of the IP address array, or the cluster won't start correctly
# cluster address for cluster.cnf
CLUSTERADDRESS="gcomm://"$(IFS=, ; echo "${IP[*]}")
unset IFS
## end config ##

## script start - do not edit below this line ##

if [ ! $DBNODEUSER ]
then
 echo "###########################################################"
 echo "## MYSQL ROOT USER NAME, HIT CTRL + C WITHIN 30 SECONDS! ##"
 echo "###########################################################"
 exit -1
fi

if [ ! $MYSQLPASSWORD ] 
then
 echo "######################################################################################"
 echo "## MYSQL ROOT PASSWORD OR DEBIAN SYSMAINT PASSWORD IS EMPTY. PLEASE ADD A PASSWORD! ##"
 echo "######################################################################################"
 exit -1
fi

# setting up dsh for concurrent command execution across all cluster nodes
ISDSH=$(type -P dsh)
if [ ! $ISDSH ]
then
 sudo apt-get -y install dsh
fi
mkdir -p ~/.dsh/group
if [ -f ~/.dsh/group/$DSHGROUP ]
then
 rm ~/.dsh/group/$DSHGROUP
fi
touch ~/.dsh/group/$DSHGROUP
for I in "${IP[@]}"
 do :
  echo "$DBNODEUSER@$I" | sudo tee --append /etc/dsh/machines.list > /dev/null
  echo "$DBNODEUSER@$I" >> ~/.dsh/group/$DSHGROUP
done

if [ $OVERWRITE = 1 ]
then
 dsh -M -g $DSHGROUP -c -- 'sudo service mysql stop'
 dsh -M -g $DSHGROUP -c -- 'sudo rm -f /etc/mysql/conf.d/cluster.cnf'
 dsh -M -g $DSHGROUP -c -- 'sudo apt-get -y purge mariadb-server-10.1 && sudo apt-get -y autoremove && sudo apt-get -y autoclean && sudo rm -rf /var/lib/mysql'
fi

# now that we have dsh, we can install all required binaries in parallel (much faster than looping over the nodes)
for I in "${IP[@]}"
do :
 scp dbnodes-mariadb-installation.sh $DBNODEUSER@$I:~/install.sh
 scp dbnodes-mariadb-setup.sh $DBNODEUSER@$I:~/setup.sh
 scp cluster.cnf $DBNODEUSER@$I:~/cluster.cnf
done
dsh -M -g $DSHGROUP -c -- 'chmod +x ~/install.sh'
dsh -M -g $DSHGROUP -c -- "~/install.sh $MYSQLPASSWORD"
dsh -M -g $DSHGROUP -c -- 'chmod +x ~/setup.sh'
dsh -M -g $DSHGROUP -c -- "~/setup.sh $CLUSTERADDRESS $INNOBUFFER"
sleep 10

if [ $START == 1 ]
then
 #DEBIAN workaround: https://mariadb.atlassian.net/browse/MDEV-5500 #
 # Our workaround is to copy the credentials file from the bootstrap node to the others (via the jump host)
 ssh $DBNODEUSER@$FIRST "sudo cp /etc/mysql/debian.cnf ~/debian.cnf && sudo chmod 644 ~/debian.cnf"
 scp $DBNODEUSER@$FIRST:~/debian.cnf ~/debian.cnf
 #/DEBIAN workaround #
 ssh $DBNODEUSER@$FIRST "sudo service mysql stop && sudo service mysql bootstrap && sleep 5"
 if [ $? = 0 ]
 then
  for I in "${IP[@]}"
  do :
   if [ ! $I = $FIRST ]
   then
    #DEBIAN workaround: https://mariadb.atlassian.net/browse/MDEV-5500 #
    scp ~/debian.cnf $DBNODEUSER@$I:~/debian.cnf
    ssh $DBNODEUSER@$I "sudo cp ~/debian.cnf /etc/mysql/debian.cnf"
    #/DEBIAN workaround #
    ssh $DBNODEUSER@$I "sudo service mysql start"
    if [ ! $? = 0 ]
    then
     echo "####################################################################################################################"
     echo "## NOT SUCCESSFUL! ONE OR MORE NODES DID NOT START AFTER SUCCESSFULLY STARTING THE FIRST NODE!                      "
     echo "## --------------------------------------------------------------------------------------------------------------   "
     echo "## Suggestion: log into $DBNODEUSER@$I and start mysql manually, checking for errors. Thanks.                       "
     echo "####################################################################################################################"
     exit $?
    fi
   fi
  done
 else
  echo "####################################################################################################################"
  echo "## NOT SUCCESSFUL! FIRST CLUSTER NODE DID NOT BOOTSTRAP SUCCESSFULLY!                                               "
  echo "## --------------------------------------------------------------------------------------------------------------   "
  echo "## Suggestion: log into $DBNODEUSER@$FIRST and bootstrap mysql manually, checking for errors. Thanks.               "
  echo "####################################################################################################################"
  exit $?
 fi
 dsh -M -g $DSHGROUP -w -- 'sudo service mysql status'
 #dsh -M -g $DSHGROUP -w -- 'mysql --user=root --password=$MYSQLPASSWORD -e \'SELECT VARIABLE_VALUE as \"cluster size\" FROM INFORMATION_SCHEMA.GLOBAL_STATUS WHERE VARIABLE_NAME=\"wsrep_cluster_size\"\''  
fi