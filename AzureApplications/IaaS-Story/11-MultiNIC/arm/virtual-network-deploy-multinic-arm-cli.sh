#!/bin/bash
alias azure=azure.cmd

# Set variables for existing resource group
existingRGName="IaaSStory"
location="westus"
vnetName="WTestVNet"
backendSubnetName="BackEnd"
remoteAccessNSGName="NSG-RemoteAccess"

# Set variables to use for backend resource group
backendRGName="IaaSStory-Backend"
prmStorageAccountName="iaasstoryprmstorage"
avSetName="ASDB"
vmSize="Standard_DS3"
diskSize=127
publisher="Canonical"
offer="UbuntuServer"
sku="14.04.2-LTS"
version="latest"
vmNamePrefix="DB"
osDiskName="osdiskdb"
dataDiskName="datadisk"
nicNamePrefix="NICDB"
ipAddressPrefix="192.168.2."
username='adminuser'
password='adminP@ssw0rd'
numberOfVMs=2

# Retrieve the Ids for resources in the IaaSStory resource group
subnetId="$(azure network vnet subnet show --resource-group $existingRGName \
                --vnet-name $vnetName \
                --name $backendSubnetName|grep Id)"
subnetId=${subnetId#*/}

nsgId="$(azure network nsg show --resource-group $existingRGName \
                --name $remoteAccessNSGName|grep Id)"
nsgId=${nsgId#*/}

# Create necessary resources for VMs
azure group create $backendRGName $location

azure storage account create $prmStorageAccountName \
    --resource-group $backendRGName \
    --location $location --type PLRS 

azure availset create --resource-group $backendRGName \
    --location $location \
    --name $avSetName

# Loop to create NICs and VMs
for ((suffixNumber=1;suffixNumber<=numberOfVMs;suffixNumber++));
do
    # Create NIC for database access
    nic1Name=$nicNamePrefix$suffixNumber-DA
    x=$((suffixNumber+3))
    ipAddress1=$ipAddressPrefix$x
    azure network nic create --name $nic1Name \
        --resource-group $backendRGName \
        --location $location \
        --private-ip-address $ipAddress1 \
        --subnet-id $subnetId
    
    # Create NIC for remote access
    nic2Name=$nicNamePrefix$suffixNumber-RA
    x=$((suffixNumber+53))
    ipAddress2=$ipAddressPrefix$x
    azure network nic create --name $nic2Name \
        --resource-group $backendRGName \
        --location $location \
        --private-ip-address $ipAddress2 \
        --subnet-id $subnetId $vnetName \
        --network-security-group-id $nsgId

    #Create the VM
    azure vm create --resource-group $backendRGName \
        --name $vmNamePrefix$suffixNumber \
        --location $location \
        --vm-size $vmSize \
        --subnet-id $subnetId \
        --availset-name $avSetName \
        --nic-names $nic1Name,$nic2Name \
        --os-type linux \
        --image-urn $publisher:$offer:$sku:$version \
        --storage-account-name $prmStorageAccountName \
        --storage-account-container-name vhds \
        --os-disk-vhd $osDiskName$suffixNumber.vhd \
        --admin-username $username \
        --admin-password $password

    #Create two data disks, and end the loop.
    azure vm disk attach-new --resource-group $backendRGName \
        --vm-name $vmNamePrefix$suffixNumber \
        --storage-account-name $prmStorageAccountName \
        --storage-account-container-name vhds \
        --vhd-name $dataDiskName$suffixNumber-1.vhd \
        --size-in-gb $diskSize \
        --lun 0

    azure vm disk attach-new --resource-group $backendRGName \
        --vm-name $vmNamePrefix$suffixNumber \
        --storage-account-name $prmStorageAccountName \
        --storage-account-container-name vhds \
        --vhd-name $dataDiskName$suffixNumber-2.vhd \
        --size-in-gb $diskSize \
        --lun 1
done