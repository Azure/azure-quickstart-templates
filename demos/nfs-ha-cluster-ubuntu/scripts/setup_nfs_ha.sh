#!/bin/bash
#
# Script to set up highly available NFS server on an Ubuntu 16.04 (or higher) VM
# that should be used on Azure with the custom script extension (which runs this script as root)
#

set -e

# Parameters
NODE1NAME=$1
NODE1IP=$2
NODE2NAME=$3
NODE2IP=$4
NFS_CLIENTS_IP_RANGE=$5     # E.g., "10.0.0.0/24". Can be "*", but strongly discouraged

# This VM's IP address, to detect if this VM should be the master (Node 1 is the initial master)
MY_IP=$(hostname -i)

. ./helper_functions.sh

function setup_required_packages
{
    # Cleanup
    dpkg --configure -a
    apt-get install -f

    # Upgrade
    apt-get -y update
    apt-get -y dist-upgrade

    apt-get -y install build-essential autoconf flex nfs-kernel-server corosync pacemaker resource-agents

    # Shouldn't let systemd start nfs-kernel-server (Pacemaker should do that)
    systemctl stop nfs-kernel-server
    systemctl disable nfs-kernel-server

    # Setup static port assignments for mountd, statd, quotad, nlm (tcp), and nlm (udp) respectively:
	sed -i 's/^\(RPCMOUNTDOPTS="--manage-gids\)"/\1 -p 2000"/g' /etc/default/nfs-kernel-server
    sed -i 's/^STATDOPTS=.*$/STATDOPTS="--port 2001 --outgoing-port 2002"/' /etc/default/nfs-common
    if [ -f /etc/default/quota ]; then
        sed -i 's/^RPCQUOTADOPTS=.*$/RPCQUOTADOPTS="-p 2003"/' /etc/default/quota
    fi
	cat <<EOF > /etc/modprobe.d/azmdl-nfs-ports.conf
options lockd nlm_udpport=2004 nlm_tcpport=2004
options nfs callback_tcpport=2005
EOF

    cat <<EOF > /etc/sysctl.d/30-azmdl-nfs-ports.conf
fs.nfs.nlm_tcpport=2004
fs.nfs.nlm_udpport=2004
EOF
    # Reread modified sysctl settings for modified NFS static ports
    sysctl --system

    # Above alone still doesn't work for static ports. Try restarting related services.
    systemctl try-restart nfs-config.service rpcbind.service rpc-statd.service nfs-server.service

    # We need to install the "azure-lb" command separately if the resource-agents package didn't have it.
    pushd /usr/lib/ocf/resource.d/heartbeat
    if [ ! -e azure-lb ]; then
        curl -LO https://raw.githubusercontent.com/ClusterLabs/resource-agents/master/heartbeat/azure-lb
        chmod +x ./azure-lb
    fi
    ln -s /bin/nc /usr/bin/nc
    popd
}

function setup_drbd_module_and_tools
{
    # We currently have to build the DRBD kernel module, as it's not included
    # in the default linux-azure kernels or in any Azure extra packages.
    # We should use the packaged DRBD module once Azure starts releasing
    # extra modules packages that include DRBD module.

    pushd /tmp
    git clone http://github.com/LINBIT/drbd-9.0
    git clone http://github.com/LINBIT/drbd-utils
    cd drbd-9.0
    make && make install
    modprobe drbd
    cd ../drbd-utils
    ./autogen.sh
    ./configure --prefix=/usr --localstatedir=/var --sysconfdir=/etc
    make tools && make install-tools
    cd ..
    rm -rf drbd-9.0 drbd-utils
    popd
}

function setup_drbd_with_disk
{
    local disk=$1
    local node1name=$2
    local node1ip=$3
    local node2name=$4
    local node2ip=$5
    local drbd_resource_name=$6
    local drbd_device_path=$7
    local drbd_device_mount_point=$8

    # Put LVM (to gain more flexibility) on the whole disk
    local vgname=drbdvg
    local lvname=drbdlv
    wipefs -af $disk
    pvcreate $disk
    vgcreate $vgname $disk
    lvcreate -n $lvname -l 95%VG $vgname

    # Set up DRBD config
    cat <<EOF > /etc/drbd.d/${drbd_resource_name}.res
resource $drbd_resource_name {
    device      ${drbd_device_path};
    disk        /dev/${vgname}/${lvname};
    meta-disk   internal;
    disk {
        c-fill-target 1M;
        c-max-rate 110M;
        c-min-rate 120K;
    }
    net {
        max-buffers 20k;
    }
    on ${node1name} {
        address ${node1ip}:7789;
    }
    on ${node2name} {
        address ${node2ip}:7789;
    }
}
EOF

    # Initialize DRBD's metadata and bring up the device on both nodes
    drbdadm create-md $drbd_resource_name
    drbdadm up $drbd_resource_name
    drbdadm status

    # On the master (initially node 1) only, force DRBD into Primary and create an ext4 file system on the DRBD device
    if [ "$MY_IP" = "$NODE1IP" ]; then
        drbdadm primary $drbd_resource_name --force
        mkfs.ext4 $drbd_device_path
        mkdir -p $drbd_device_mount_point && mount $drbd_device_path $drbd_device_mount_point
    fi
}

function setup_corosync_and_pacemaker_for_nfs
{
    local node1ip=$1
    local node2ip=$2
    local drbd_resource_name=$3     # E.g., azmdlr0
    local drbd_device_path=$4       # E.g., /dev/drbd0
    local drbd_mount_point=$5       # E.g., /drbd
    local nfs_export_path=$6        # E.g., /drbd/moodle
    local nfs_client_spec=$7        # E.g., * or 10.11.22.0/24

    mv /etc/corosync/corosync.conf /etc/corosync/corosync.conf.orig || true

    local cluster_name=azmdl-cluster

    cat <<EOF > /etc/corosync/corosync.conf
totem {
    version: 2
    secauth: off
    cluster_name: ${cluster_name}
    transport: udpu
}

nodelist {
    node {
        ring0_addr: ${node1ip}
        nodeid: 1
    }
    node {
        ring0_addr: ${node2ip}
        nodeid: 2
    }
}

quorum {
    provider: corosync_votequorum
    two_node:1
}

logging {
    to_syslog: yes
}
EOF

    systemctl enable corosync pacemaker
    systemctl restart corosync pacemaker

    # TODO Should confirm if 'corosync-cfgtool -s' gives a non-loopback IP address (not 127.0.0.1), e.g.:
    # $ corosync-cfgtool -s
    # Printing ring status.
    # Local node ID 2
    # RING ID 0
    #     id = 10.0.0.5
    #     status = ring 0 active with no faults

    # Finally, configure Pacemaker cluster resources, only on the initial master
    if [ "$MY_IP" = "$node1ip" ]; then
        mkdir -p ${nfs_export_path}
        crm configure <<EOF
primitive p_drbd_r0 ocf:linbit:drbd \
    params drbd_resource=${drbd_resource_name} \
    op monitor interval=29s role=Master \
    op monitor interval=31s role=Slave \
    op start interval=0s timeout=240s \
    op stop interval=0s timeout=100s
ms ms_drbd_r0 p_drbd_r0 \
    meta master-max=1 master-node-max=1 clone-node-max=1 clone-max=2 notify=true
primitive p_fs_data Filesystem \
    params device="${drbd_device_path}" directory="${drbd_mount_point}" \
    fstype=ext4 options=noatime,nodiratime \
    op start interval=0s timeout=100s \
    op stop interval=0s timeout=100s \
    op monitor interval=10s timeout=100s
primitive p_nfsserver ocf:heartbeat:nfsserver \
    params nfs_shared_infodir="${drbd_mount_point}/nfs_shared_infodir" \
    op start interval=0s timeout=40s \
    op stop interval=0s timeout=20s \
    op monitor interval=10s timeout=20s
primitive p_exportfs ocf:heartbeat:exportfs \
    params clientspec="${nfs_client_spec}" directory="${nfs_export_path}" fsid=1 \
    unlock_on_stop=1 options=rw,sync,no_root_squash \
    op start interval=0s timeout=40s \
    op stop interval=0s timeout=120s \
    op monitor interval=10s timeout=20s
primitive p_azure-lb azure-lb \
    params nc="/bin/nc" port="61000" \
    op start interval=0s timeout=20s \
    op stop interval=0s timeout=20s \
    op monitor interval=10s timeout=20s
group g_services p_fs_data p_nfsserver p_exportfs p_azure-lb
colocation cl-g_services-with-ms_drbd_r0 inf: g_services ms_drbd_r0:Master
order o-ms_drbd_r0-before-g_services inf: ms_drbd_r0:promote g_services:start
property stonith-enabled=false
EOF
    fi
    # TODO STONITH is disabled for now (two lines above). Should enable it soon.

    # TODO 'crm status' should show the correctly configured/started cluster resources.
}

# Main

setup_required_packages

setup_drbd_module_and_tools

# Don't create a file system, but just set up a disk (RAID if multiple unpartitioned disks)
# AZMDL_DISK env var is set by the function as the discovered/initialized disk
setup_raid_disk_and_filesystem None /dev/md0 None False

DRBD_RESOURCE_NAME=azmdlr0   # TODO Avoid hard-coded value
DRBD_DEVICE_PATH=/dev/drbd0
DRBD_MOUNT_POINT=/drbd       # TODO Avoid hard-coded value

setup_drbd_with_disk $AZMDL_DISK $NODE1NAME $NODE1IP $NODE2NAME $NODE2IP $DRBD_RESOURCE_NAME $DRBD_DEVICE_PATH $DRBD_MOUNT_POINT

NFS_EXPORT_PATH=${DRBD_MOUNT_POINT}/data  # TODO Allow different export dir name -- This requires changes all along the pipeline, from the top-level template to this script...

setup_corosync_and_pacemaker_for_nfs $NODE1IP $NODE2IP $DRBD_RESOURCE_NAME $DRBD_DEVICE_PATH $DRBD_MOUNT_POINT $NFS_EXPORT_PATH "$NFS_CLIENTS_IP_RANGE"

echo "NFS-HA setup succeeded. NFS_EXPORT_PATH=${NFS_EXPORT_PATH}, NFS_CLIENT_SPEC=${NFS_CLIENT_SPEC}"
