#!/bin/bash
sed -i 's|-A INPUT -p icmp -m icmp --icmp-type echo-request -j ACCEPT|-A INPUT -p icmp -m icmp --icmp-type echo-request -j DROP|' /etc/iptables.up.rules
sed -i "/--dport 11211/d" /etc/iptables.up.rules
iptables-restore < /etc/iptables.up.rules
