#!/usr/bin/env bash
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#
# See the License for the specific language governing permissions and
# limitations under the License.

LOG_FILE="/var/log/cloudera-azure-initialize.log"

log() {
  echo "$(date): $*" >> "${LOG_FILE}"
}

n=120
sleepInterval=10
internal_ip=$1

log "Verifying DNS configuration ..."

until grep "nameserver ${internal_ip}" /etc/resolv.conf || [ ${n} -le 0 ]
do
    service network restart
    log "Waiting for Azure DNS nameserver updates to propagate, this usually takes less than 2 minutes..."
    n=$((n - sleepInterval))
    sleep ${sleepInterval}
done

if [ "${n}" -le 0 ]; then
  log  "Failed to pick up dns server from VNET" & exit 1;
fi


# Verify DNS is working
hostname -f
if [ $? != 0 ]
then
    log "Unable to run the command 'hostname -f' (check 1 of 4)"
    exit 1
fi

hostname -i
if [ $? != 0 ]
then
    log "Unable to run the command 'hostname -i' (check 2 of 4)"
    exit 1
fi

host "$(hostname -f)"
if [ $? != 0 ]
then
    log "Unable to run the command 'host \`hostname -f\`' (check 3 of 4)"
    exit 1
fi

host "$(hostname -i)"
if [ $? != 0 ]
then
    log "Unable to run the command 'host \`hostname -i\`' (check 4 of 4)"
    exit 1
fi


log "Verifying DNS configuration ... Successful"

exit 0
