#
# Create a mount-directory for the NFS share
#

# The datadrive mount point needs to exist on all nodes
if [ ! -d /datadrive ]
then
    mkdir /datadrive
fi 

# Next make sure the NFS metadata is included in the DRBD sync
if [ "$1" = "primary" ]
then

    # On the primary server, copy the original NFS config data

    mount -t ext3 /dev/drbd1 /datadrive
    mv /var/lib/nfs /datadrive/
    ln -s /datadrive/nfs/ /var/lib/nfs
    mkdir /datadrive/exports
    unmount /datadrive

else

    # On all secondary servers, link the NFS config to the synced NFS config
    rm -fr /var/lib/nfs/
    ln -s /datadrive/nfs/ /var/lib/nfs

fi