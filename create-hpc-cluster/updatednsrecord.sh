#! /bin/bash
while true; do
  echo -e "server ${1}\nzone ${1}\nupdate delete ${HOSTNAME}.${1}\nupdate add ${HOSTNAME}.${1} 864000 A ${2}\nsend\n" | nsupdate -v
  excode=$?
  if [ $excode = 0 ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Succeeded to update IP to DNS server: ${2}" >> /tmp/update_dns.log
    break
  else
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Failed to update IP to DNS server: $excode, retry after 1 minute" >> /tmp/update_dns.log
    sleep 60
  fi
done
