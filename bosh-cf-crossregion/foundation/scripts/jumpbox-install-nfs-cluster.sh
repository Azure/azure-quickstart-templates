#
# This script installs a distributed NFS cluster across two regions
# It assumes two NFS servers per region inter-connected with a cross-region virtual network
#

#
# General configuration settings
#
NFSROOTUSER=  # Enter the NFS Root User Here
DSHGROUP=nfsall

# Change these IP addresses as per your networking configuration
nfsIP[0]=10.10.200.4
nfsIP[1]=10.10.200.5
nfsIP[2]=10.12.200.4
nfsIP[3]=10.12.200.5

FIRST=${nfsIP[0]}

if [ ! $NFSROOTUSER ]
then
 echo "###################################################################"
 echo "## NFS ROOT USER NAME, PLEASE UPDATE NFSROOTUSER= IN THIS SCRIPT ##"
 echo "###################################################################"
 exit -1
fi

#
# Prepare DSH for the NFS servers
#
isDSHAvailable=$(type -P dsh)
if [ ! $isDSHAvailable ]
then
    sudo apt-get -y install dsh 
fi

mkdir -p ~/.dsh/group
if [ -f ~/.dsh/group/$DSHGROUP ]
then
    rm ~/.dsh/group/$DSHGROUP
fi
touch ~/.dsh/group/$DSHGROUP
for ip in "${nfsIP[@]}"
  do :
  echo "$NFSROOTUSER@$ip"
  echo "$NFSROOTUSER@$ip" | sudo tee --append /etc/dsh/machines.list > /dev/null
  echo "$NFSROOTUSER@$ip" >> ~/.dsh/group/$DSHGROUP
done

#
# Get all needed shell scripts to the target nodes
#
for n in "${nfsIP[@]}"
do :
  scp nfsnodes-prep-datadrives.sh $NFSROOTUSER@$n:~/prep-datadrive.sh
  scp nfsnodes.drbd.d.r0.res $NFSROOTUSER@$n:~/nfsnodes.drbd.d.r0.res
done
# Now make all shell-scripts executable
dsh -M -g $DSHGROUP -c -- "chmod +x ~/prep-datadrive.sh"

#
# Next install DRDB on the NFS Cluster
#
dsh -M -g $DSHGROUP -c -- "sudo apt-get -y install corosync pacemaker drbd8-utils"
dsh -M -g $DSHGROUP -c -- "sudo cp ~/nfsnodes.drbd.d.r0.res /etc/drbd.d/r0.res"
dsh -M -g $DSHGROUP -c -- "sudo drbdadm -c /etc/drbd.conf role r0"
dsh -M -g $DSHGROUP -c -- "sudo drbdadm up r0"
ssh $NFSROOTUSER@$FIRST "sudo drbdadm primary --force r0"

# Mount the DRDB file system used for the NFS replication
for n in "${nfsIP[@]}"
do :
  if [ $n = $FIRST ]
  then
    ssh $NFSROOTUSER@$n "sudo ~/prep-datadrive.sh primary"
    # Wait for the first synchronization to complete
    sleep 30
  else
    ssh $NFSROOTUSER@$n "sudo ~/prep-datadrive.sh secondary"  
  fi
done

#
# Install the NFS Server package on all target servers
#
dsh -M -g $DSHGROUP -c -- "sudo apt-get -y install nfs-kernel-server"
dsh -M -g $DSHGROUP -c -- "echo '/datadrive/exports/ 10.x.x.x/255.255.255.0(rw,no_root_squash,no_all_squash,sync)' | sudo tee -a /etc/exports"