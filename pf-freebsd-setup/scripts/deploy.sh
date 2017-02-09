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
vmSize=${14}
storageAccountType=${15}
privateSubnet=${16}

invoke_bash()
{
	#install Azure CLI
	echo "install azure-cli start" >> /tmp/install.log 
	if [ "$environment" = "AzureCloud" ]
		then
			npm install azure-cli --global  >> /tmp/install.log 2>&1
		else
			npm install --global --registry http://chinamirror.westus.cloudapp.azure.com:4873 azure-cli >> /tmp/install.log 2>&1
	fi
	echo "install azure-cli end" >> /tmp/install.log 

	echo "enable azure-cli telemetry" >> /tmp/install.log 
	/usr/local/bin/azure telemetry --enable  >> /tmp/install.log 2>&1

	#remove this line from /etc/rc.conf to avoid noise
	sed -ie '/deploy\.sh/d' /etc/rc.conf

	echo "azure login start" >> /tmp/install.log 
	#login into Azure using service principal
	if [ "$environment" = "AzureCloud" ]
		then
			/usr/local/bin/azure login -u $servicePrincipalClientID --service-principal --tenant $servicePrincipalTenantID -p $servicePrincipalkey >> /tmp/install.log 2>&1
		else
			/usr/local/bin/azure login -u $servicePrincipalClientID --service-principal --tenant $servicePrincipalTenantID -p $servicePrincipalkey -e AzureChinaCloud >> /tmp/install.log 2>&1
	fi
	echo "azure login end" >> /tmp/install.log 

	echo "create security group start" >> /tmp/install.log 
	#new security group and associate it into the private subnet
	sgname=$rgname"-sg"
	/usr/local/bin/azure network nsg create -g $rgname -n $sgname -l $location >> /tmp/install.log 2>&1
	/usr/local/bin/azure network nsg rule create --protocol tcp --direction inbound --priority 1000 --destination-port-range 22 --access allow $rgname $sgname SSHRule >> /tmp/install.log 2>&1
	/usr/local/bin/azure network nsg rule create --direction inbound --priority 1001  --source-address-prefix VirtualNetwork --destination-port-range 0-65535 --access allow $rgname $sgname PrivateToPublicRule >> /tmp/install.log 2>&1

	echo "create security group end" >> /tmp/install.log 
	/usr/local/bin/azure network nic set -g $rgname -n $frontendPrivateNic -o $sgname >> /tmp/install.log 2>&1

	#create a route table for the private subnet
	routeTableName=$rgname"UT"
	echo "create route table start" >> /tmp/install.log
	/usr/local/bin/azure network route-table create -g $rgname -n $routeTableName -l $location >> /tmp/install.log 2>&1
	/usr/local/bin/azure network route-table route create -g $rgname -r $routeTableName -n RouteToInternet -a 0.0.0.0/0 -y VirtualAppliance -p $frontEndVMPrivateIP >> /tmp/install.log 2>&1
	echo "create route table end" >> /tmp/install.log 
	/usr/local/bin/azure network vnet subnet set -g $rgname -e $vnetName -n $privateSubnet -r $routeTableName >> /tmp/install.log 2>&1

	ssh-keygen -f /tmp/sshkey -q -N ""

	#create VMs in private subnet
	echo "create storage account start" >> /tmp/install.log
	case $storageAccountType in
		"Premium_LRS")  type="PLRS";;
		"Standard_LRS") type="LRS";;
		"Standard_GRS") type="GRS";;
		"Standard_RAGRS") type="RAGRS";;
		"Standard_ZRS") type="ZRS";;
	esac

	storageAccount=$rgname`cat /dev/urandom | tr -dc 'a-z' | fold -w 8 | head -n 1`
	azure storage account create --sku-name $type -g $rgname -l $location --kind Storage $storageAccount >> /tmp/install.log 2>&1
	echo "create storage account end" >> /tmp/install.log

    password=`echo $password | /usr/local/bin/base64 --decode`

	echo "create vm1 start" >> /tmp/install.log 

	nicName1=$rgname"-nic-"1
	vm1=$rgname"-vm-"1
	ip1=$vm1PrivateNicIP
	/usr/local/bin/azure network nic create --subnet-name $privateSubnet --subnet-vnet-name $vnetName $rgname $nicName1 $location -a $ip1 >> /tmp/install.log 2>&1
	/usr/local/bin/azure network nic set -g $rgname -n $nicName1 -f true >> /tmp/install.log 2>&1
	/usr/local/bin/azure vm create --resource-group $rgname --name $vm1 --location $location --os-type linux --nic-name $nicName1 --vnet-subnet-name $privateSubnet --storage-account-name $storageAccount --image-urn MicrosoftOSTC:FreeBSD:11.0:latest --admin-username $username --admin-password $password --vm-size $vmSize --ssh-publickey-file /tmp/sshkey.pub >> /tmp/install.log 2>&1
	echo "create vm1 end" >> /tmp/install.log 

	echo "create vm2 start" >> /tmp/install.log 
	nicName2=$rgname"-nic-"2
	vm2=$rgname"-vm-"2
	ip2=$vm2PrivateNicIP
	/usr/local/bin/azure network nic create --subnet-name $privateSubnet --subnet-vnet-name $vnetName $rgname $nicName2 $location -a $ip2 >> /tmp/install.log 2>&1
	/usr/local/bin/azure network nic set -g $rgname -n $nicName2 -f true >> /tmp/install.log 2>&1
	/usr/local/bin/azure vm create --resource-group $rgname --name $vm2 --location $location --os-type linux --nic-name $nicName2 --vnet-subnet-name $privateSubnet --storage-account-name $storageAccount --image-urn MicrosoftOSTC:FreeBSD:11.0:latest --admin-username $username --admin-password $password --vm-size $vmSize --ssh-publickey-file /tmp/sshkey.pub >> /tmp/install.log 2>&1
	echo "create vm2 end" >> /tmp/install.log 
    
	service pf restart
	
	echo "/usr/bin/ssh -o StrictHostKeyChecking=no -i /tmp/sshkey $username@$ip1 'echo $password | sudo -S env ASSUME_ALWAYS_YES=YES pkg bootstrap' >> /tmp/install.log && /usr/bin/ssh -o StrictHostKeyChecking=no -i /tmp/sshkey $username@$ip1 'echo $password | sudo -S pkg install -y nginx' >> /tmp/install.log && /usr/bin/ssh -o StrictHostKeyChecking=no -i /tmp/sshkey $username@$ip1 'echo $password | sudo -S service nginx onestart' >> /tmp/install.log "| at now + 1 minute
	echo "/usr/bin/ssh -o StrictHostKeyChecking=no -i /tmp/sshkey $username@$ip2 'echo $password | sudo -S env ASSUME_ALWAYS_YES=YES pkg bootstrap' >> /tmp/install.log && /usr/bin/ssh -o StrictHostKeyChecking=no -i /tmp/sshkey $username@$ip2 'echo $password | sudo -S pkg install -y nginx' >> /tmp/install.log && /usr/bin/ssh -o StrictHostKeyChecking=no -i /tmp/sshkey $username@$ip2 'echo $password | sudo -S service nginx onestart' >> /tmp/install.log "| at now + 1 minute
}

invoke_bash








