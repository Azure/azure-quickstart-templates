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
# We start with a 2-node setup first since more nodes need DRBD stacking
nfsIP[0]=10.10.200.4
nfsIP[2]=10.12.200.4

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
# Get all needed shell scripts to the target nodes and install/configure the basics
#
for n in "${nfsIP[@]}"
do :
  scp nfsnodes-drbd-setup.sh $NFSROOTUSER@$n:~/nfsnodes-drbd-setup.sh
  scp nfsnodes-prep-datadrives.sh $NFSROOTUSER@$n:~/nfsnodes-prep-datadrive.sh
  scp nfsnodes.drbd.d.r0.res $NFSROOTUSER@$n:~/nfsnodes.drbd.d.r0.res
done

dsh -M -g $DSHGROUP -c -- "chmod +x ~/*.sh"
dsh -M -g $DSHGROUP -c -- "sudo apt-get -qq -y install nfs-kernel-server corosync pacemaker drbd8-utils"

#
# Configure the DRBD setup on the nodes
#

# Basic DRBD Setup
ssh $NFSROOTUSER@${nfsIP[0]} "sudo ~/nfsnodes-drbd-setup.sh primary"
ssh $NFSROOTUSER@${nfsIP[1]} "sudo ~/nfsnodes-drbd-setup.sh secondary"

# Mount the DRDB file system used for the NFS replication
ssh $NFSROOTUSER@${nfsIP[0]} "sudo ~/nfsnodes-prep-datadrive.sh primary"
ssh $NFSROOTUSER@${nfsIP[1]} "sudo ~/nfsnodes-prep-datadrive.sh secondary"

# Now on Server 1 start the inital sync process
ssh $NFSROOTUSER@${nfsIP[0]} "drbdadm -- --overwrite-data-of-peer primary r0"

#
# Final NFS Server Configurations
#
dsh -M -g $DSHGROUP -c -- "echo '/datadrive/exports/ 10.0.0.0/8(rw,no_root_squash,no_all_squash,sync)' | sudo tee -a /etc/exports"
dsh -M -g $DSHGROUP -c -- "service nfs-kernel-server restart"