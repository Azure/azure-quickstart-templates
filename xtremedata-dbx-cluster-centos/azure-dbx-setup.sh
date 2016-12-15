#!/bin/bash

#
# Usage:  $0 [-v] <headip> <clustername> [<number-of-nodes> <this-node-index>]
#
set -e

logger -t azure-dbx-setup "started, args: $*"
echo "dbx-setup Started: $*. `date`"

[ $1 = '-v' ] && shift || quiet='-q'

headip=$1
clustername=$2
myip="$(ip -4 address show eth0 | sed -rn 's/^[[:space:]]*inet ([[:digit:].]+)[/[:space:]].*$/\1/p')"


echo $myip `hostname` >> /etc/hosts
umount /mnt/resource || true

ephemdev="sdb"
grep '^/dev/sdb1 / ' /etc/mtab >/dev/null && ephemdev="sda"

cat >/etc/dbx-amp-conf.json <<end
{
  "xd_cloud_id"         : "azure",
  "xd_location_id"      : "azure",
  "xd_instance_type"    : "unknown",
  "xd_instance_id"      : "$(hostname)",
  "xd_local_host"       : "$(hostname)",
  "xd_local_ip"         : "$myip",
  "xd_public_host"      : "",
  "xd_head_host"        : "$headip",
  "xd_cluster_name"     : "$clustername",
  "xd_block_device"     : [
  {"name":"/dev/$ephemdev", "type":"local", "persistent":"N", "class":"U", "size":$(cat /sys/block/$ephemdev/size)}
end
cd /sys/block
for ii in sd*; do
  [[ $ii = sda || $ii = sdb ]] && continue
cat >>/etc/dbx-amp-conf.json <<end
  ,{"name":"/dev/$ii", "type":"local", "persistent":"Y", "class":"U", "size":$(cat $ii/size)}
end
done
cd -
cat >>/etc/dbx-amp-conf.json <<end
  ]
}
end

rm -f ~xdcrm/tmp/my_config.out
/etc/init.d/dbx_checkin stop || true
/etc/init.d/dbx_checkin start

# temp img fixes
cd /opt/xdDB/xdadm
chown -R xdAdm:xdAdm .
chmod a+x webServer/xdjet webServer/xdapp scriptServer/scriptServer
cd -

echo dbx-setup Done. `date`
logger -t azure-dbx-setup "Done: success"

[ "$4" = 0 ] && chmod u+x azure-dbx-start.sh && ./azure-dbx-start.sh $3
exit 0
