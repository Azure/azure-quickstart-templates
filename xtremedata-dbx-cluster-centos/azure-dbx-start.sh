#!/bin/bash
#
# Start DBX cluster
# Arguments: $1 - total number of nodes in cluster (1 = single node)
#
set -e

data_nodes="$1"; shift
login_user="azure-user"

logger -t azure-dbx-start "started: $*"
echo "Started. `date`"

[ "$data_nodes" -ge 1 ] || { echo "bad number of nodes: $data_nodes" && exit 1; }
: $((data_nodes--))


###### copy $login_user's password to dbxdba ######
adm_pwd="$(getent shadow $login_user | awk -F: '{print $2}')"
[ -n "$adm_pwd" ] && echo -e "dbxdba:$adm_pwd" | chpasswd -e


###### start dbx ######

echo "*** waiting for $data_nodes nodes *** `date`"
declare -i nn=240
while [ "$(/opt/xdcluster/bin/getnodes.sh | wc -l)" -ne $data_nodes ]; do
  sleep 5
  if [ $((--nn)) -eq 0 ]; then
	  clustererr="TIMEOUT waiting for nodes: have $(/opt/xdcluster/bin/getnodes.sh | wc -l), want $data_nodes"
	  break
  fi
done

[ -n "$clustererr" ] || \
su - xdcrm -c "echo '*** cluster_init ***' && ~/cluster_init.sh -i -p -y $data_nodes && \
  sleep 1 && echo '*** cluster_start ***' && ~/cluster_start.sh && \
  sleep 1 && echo '*** dbx_start ***' && ~/dbx_start.sh" || clustererr="ERROR $?"

echo "Finished: ${clustererr:-SUCCESS} `date`"
logger -t azure-dbx-start "Done: ${clustererr:-SUCCESS}"

[ -z "$clustererr" ]; exit

# vim: set tabstop=4 sw=4 et:
