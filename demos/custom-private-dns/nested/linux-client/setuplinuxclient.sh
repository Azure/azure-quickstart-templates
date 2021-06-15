set -e

grep -v -G domain-name /etc/dhcp/dhclient.conf  > dhclient.tmp
echo "supersede domain-name \"$1\";"    >> dhclient.tmp
sudo cp /etc/dhcp/dhclient.conf /etc/dhcp/dhclient.conf.old
sudo cp dhclient.tmp /etc/dhcp/dhclient.conf
sudo cp ddns-dhcphook /etc/dhcp/dhclient-exit-hooks.d

# do dhcp update to update resolv.conf and register ddns
sudo dhclient -v
