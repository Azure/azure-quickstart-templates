#!/bin/sh

servicePrincipalClientID=$1
servicePrincipalTenantID=$2
servicePrincipalkey=$3
environment=$4
rgname=$5
location=$6
frontendPrivateNic=$7
frontEndVMPrivateIP=$8 
vnetName=$9
username=${10}
password=${11}
vm1PrivateNicIP=${12}
vm2PrivateNicIP=${13}
baseUriAzureCloud=${14}
vmSize=${15}
storageAccountType=${16}
privateSubnet=${17}

invoke_bash()
{
	env ASSUME_ALWAYS_YES=YES pkg bootstrap
	
	pkg install -y wget
	pkg install -y unix2dos

	echo "install npm start" >> /tmp/install.log  
	pkg install -y npm >> /tmp/install.log

	pkg info npm >> /tmp/install.log 
	while [ $? != 0 ]; do
		pkg install -y npm >> /tmp/install.log 
		pkg info npm >> /tmp/install.log 
	done

	ln -s /usr/local/bin/node  /bin/node
	ln -s /usr/local/lib/node /usr/lib/node
	ln -s /usr/local/bin/npm /usr/bin/npm
	echo "install npm end" >> /tmp/install.log 


	echo 'pf_enable="YES"' >> /etc/rc.conf
	echo 'ifconfig_hn1="DHCP"' >> /etc/rc.conf

	echo 'ext_if="hn0"' >> /etc/pf.conf
	echo 'int_if = "hn1"' >> /etc/pf.conf 
	echo "servers = \"{" $vm1PrivateNicIP $vm2PrivateNicIP "}\"" >> /etc/pf.conf
	echo 'nat pass on $ext_if from $int_if:network to any -> $ext_if' >> /etc/pf.conf
	echo 'rdr pass on $ext_if proto tcp from any to $ext_if port 80 -> $servers round-robin' >> /etc/pf.conf 
	echo 'pass in all' >> /etc/pf.conf
	echo 'pass out all' >> /etc/pf.conf

	echo 'net.inet.ip.forwarding=1' >> /etc/sysctl.conf
	sysctl net.inet.ip.forwarding=1

	ifconfig hn1 up

	service pf start >> /tmp/install.log  

	wget -P /tmp $baseUriAzureCloud/scripts/deploy.sh
	echo sh /tmp/deploy.sh $servicePrincipalClientID $servicePrincipalTenantID $servicePrincipalkey $environment $rgname $location $frontendPrivateNic $frontEndVMPrivateIP $vnetName $username $password $vm1PrivateNicIP $vm2PrivateNicIP $vmSize $storageAccountType $privateSubnet >> /etc/rc.conf
	dos2unix /tmp/deploy.sh
	
	echo "/bin/sh /etc/rc.conf" | at now + 2 minutes
}

invoke_bash

