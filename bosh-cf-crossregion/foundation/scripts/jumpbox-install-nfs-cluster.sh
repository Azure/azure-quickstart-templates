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

FIRST=nfsIP[0]

if [ ! $NFSROOTUSER ]
then
 echo "#########################################################"
 echo "## NFS ROOT USER NAME, HIT CTRL + C WITHIN 30 SECONDS! ##"
 echo "#########################################################"
 exit -1
fi

#
# Prepare DSH for the NFS servers
#
isDSHAvailable=$(type -P dsh)
if [ ! isDSHAvailable ]
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
  echo "$NFSROOTUSER@$I" | sudo tee --append /etc/dsh/machines.list > /dev/null
  echo "$NFSROOTUSER@$I" >> ~/.dsh/group/$DSHGROUP
done

#
# Mount the data disks on each NFS server
#
dsh -M -g $DSHGROUP -c -- 'sudo fdisk /dev/sdc'