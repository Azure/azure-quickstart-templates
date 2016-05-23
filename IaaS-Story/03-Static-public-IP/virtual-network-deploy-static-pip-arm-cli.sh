#!/bin/bash
alias azure=azure.cmd

# Set variables for the new resource group
rgName="IaaSStory2"
location="westus"

# Set variables for VNet
vnetName="TestVNet"
vnetPrefix="192.168.0.0/16"
subnetName="FrontEnd"
subnetPrefix="192.168.1.0/24"

# Set variables for storage
stdStorageAccountName="iaasstorystorage2"

# Set variables for VM
vmSize="Standard_A1"
diskSize=127
publisher="Canonical"
offer="UbuntuServer"
sku="14.04.2-LTS"
version="latest"
vmName="WEB1"
osDiskName="osdisk"
nicName="NICWEB1"
privateIPAddress="192.168.1.101"
username='adminuser'
password='adminP@ssw0rd'
pipName="PIPWEB1"
dnsName="iaasstoryws1"

# Create necessary resources for VMs
azure group create $rgName $location

# Create the VNet
azure network vnet create --resource-group $rgName \
    --name $vnetName \
    --address-prefixes $vnetPrefix \
    --location $location
azure network vnet subnet create --resource-group $rgName \
    --vnet-name $vnetName \
    --name $subnetName \
    --address-prefix $subnetPrefix

# Create a public IP
azure network public-ip create --resource-group $rgName \
    --name $pipName \
    --location $location \
    --allocation-method Static \
    --domain-name-label $dnsName 

# Get subnet ID
subnetId="$(azure network vnet subnet show --resource-group $rgName \
                --vnet-name $vnetName \
                --name $subnetName|grep Id)"
subnetId=${subnetId#*/}

# Create NIC for database access
azure network nic create --name $nicName \
    --resource-group $rgName \
    --location $location \
    --private-ip-address $privateIPAddress \
    --subnet-id $subnetId \
    --public-ip-name $pipName

# Create storage account

azure storage account create $stdStorageAccountName \
    --resource-group $rgName \
    --location $location --type LRS 

#Create the VM
azure vm create --resource-group $rgName \
    --name $vmName \
    --location $location \
    --vm-size $vmSize \
    --subnet-id $subnetId \
    --nic-names $nicName \
    --os-type linux \
    --image-urn $publisher:$offer:$sku:$version \
    --storage-account-name $stdStorageAccountName \
    --storage-account-container-name vhds \
    --os-disk-vhd $osDiskName.vhd \
    --admin-username $username \
    --admin-password $password