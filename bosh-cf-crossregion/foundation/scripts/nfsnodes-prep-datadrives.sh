#
# Create a mount-directory for the NFS share
#
mkdir /datadrive

if [ "$1" == "primary" ]
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