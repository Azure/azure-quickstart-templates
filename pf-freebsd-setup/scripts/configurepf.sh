#!/bin/sh

vm1PrivateNicIP=${1}
vm2PrivateNicIP=${2}

invoke_bash()
{
	echo 'pf_enable="YES"' >> /etc/rc.conf
	echo 'ifconfig_hn1="DHCP"' >> /etc/rc.conf

	echo 'ext_if="hn0"' >> /etc/pf.conf
	echo 'int_if="hn1"' >> /etc/pf.conf 
	echo "servers = \"{" $vm1PrivateNicIP $vm2PrivateNicIP "}\"" >> /etc/pf.conf
	echo 'nat pass on $ext_if from ($int_if:network) to any -> ($ext_if)' >> /etc/pf.conf
	echo 'rdr pass on $ext_if proto tcp from any to ($ext_if) port 80 -> $servers round-robin' >> /etc/pf.conf 
	echo 'pass in all' >> /etc/pf.conf
	echo 'pass out all' >> /etc/pf.conf

	echo 'net.inet.ip.forwarding=1' >> /etc/sysctl.conf
	sysctl net.inet.ip.forwarding=1
    
	ifconfig hn1 up
	service pf start
	
}

invoke_bash

