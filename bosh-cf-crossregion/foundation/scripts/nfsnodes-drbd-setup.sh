#
# Configures DRBD on the primary and secondary nodes assuming the resource file has been copied under ~/nfsnodes.drbd.d.r0.res
#

# Configuration that is equal on all nodes
cp ~/nfsnodes.drbd.d.r0.res /etc/drbd.d/r0.res
drbdadm create-md r0
drbdadm attach r0
drbdadm up r0

# Configuration different between master and secondary nodes
if [ "$1" = "primary" ]
then
  drbdadm primary --force r0
else
  drbdadm secondary r0
fi

# Again configuration needed on all nodes
drbdadm connect r0
drbdadm -c /etc/drbd.conf role r0