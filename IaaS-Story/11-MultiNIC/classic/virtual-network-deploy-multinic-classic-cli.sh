#!/bin/bash
alias azure=azure.cmd

# Set variables for existing resource group
location="useast2"
vnetName="WTestVNet"
backendSubnetName="BackEnd"

# Set variables to use for backend resource group
backendCSName="IaaSStory-Backend"
prmStorageAccountName="iaasstoryprmstorage4"
image="0b11de9248dd4d87b18621318e037d37__RightImage-Ubuntu-14.04-x64-v14.2.1"
avSetName="ASDB"
vmSize="Standard_DS3"
diskSize=127
vmNamePrefix="DB"
osDiskName="osdiskdb"
dataDiskPrefix="db"
dataDiskName="datadisk"
ipAddressPrefix="192.168.2."
username='adminuser'
password='adminP@ssw0rd'
numberOfVMs=2

# Create necessary resources for VMs
azure service create --serviceName $backendCSName \
    --location $location

azure storage account create $prmStorageAccountName \
    --location $location \
    --type PLRS 

# Loop to create NICs and VMs
for ((suffixNumber=1;suffixNumber<=numberOfVMs;suffixNumber++));
do
    nic1Name=$vmNamePrefix$suffixNumber-DA
    x=$((suffixNumber+3))
    ipAddress1=$ipAddressPrefix$x

    nic2Name=$vmNamePrefix$suffixNumber-RA
    x=$((suffixNumber+53))
    ipAddress2=$ipAddressPrefix$x

    #Create the VM
    azure vm create $backendCSName $image $username $password \
        --connect $backendCSName \
        --vm-name $vmNamePrefix$suffixNumber \
        --vm-size $vmSize \
        --availability-set $avSetName \
        --blob-url $prmStorageAccountName.blob.core.windows.net/vhds/$osDiskName$suffixNumber.vhd \
        --virtual-network-name $vnetName \
        --subnet-names $backendSubnetName \
        --nic-config $nic1Name:$backendSubnetName:$ipAddress1::,$nic2Name:$backendSubnetName:$ipAddress2::

    #Create two data disks, and end the loop.
    azure vm disk attach-new $vmNamePrefix$suffixNumber \
        $diskSize \
        vhds/$dataDiskPrefix$suffixNumber$dataDiskName-1.vhd

    azure vm disk attach-new $vmNamePrefix$suffixNumber \
        $diskSize \
        vhds/$dataDiskPrefix$suffixNumber$dataDiskName-2.vhd
done