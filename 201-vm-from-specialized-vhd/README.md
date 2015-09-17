# Create a VM from a specialized VHD disk

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vm-from-specialized-vhd%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vm-from-specialized-vhd%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

Prerequisite - VHD file that you want to create a VM from already exists in a storage account.

This template creates a VM from a specialized VHD. The VHD file can be located in a storage account using a tool such as Azure Storage Explorer http://azurestorageexplorer.codeplex.com/

If you are looking to accomplish the above scenario through PowerShell instead of a template, you can use a PowerShell script like below

##### Variables
    ## Global
    $rgName = "testrg"
    $location = "westus"

    ## Storage
    $storageName = "teststore"
    $storageType = "Standard_GRS"

    ## Network
    $nicname = "testnic"
    $subnet1Name = "subnet1"
    $vnetName = "testnet"
    $vnetAddressPrefix = "10.0.0.0/16"
    $vnetSubnetAddressPrefix = "10.0.0.0/24"

    ## Compute
    $vmName = "testvm"
    $computerName = "testcomputer"
    $vmSize = "Standard_A2"
    $osDiskName = $vmName + "osDisk"

##### Resource Group
    New-AzureResourceGroup -Name $rgName -Location $location

##### Storage
    $storageacc = New-AzureStorageAccount -ResourceGroupName $rgName -Name $storageName -Type $storageType -Location $location

##### Network
    $pip = New-AzurePublicIpAddress -Name $nicname -ResourceGroupName $rgName -Location $location -AllocationMethod Dynamic
    $subnetconfig = New-AzureVirtualNetworkSubnetConfig -Name $subnet1Name -AddressPrefix $vnetSubnetAddressPrefix
    $vnet = New-AzureVirtualNetwork -Name $vnetName -ResourceGroupName $rgName -Location $location -AddressPrefix $vnetAddressPrefix -Subnet $subnetconfig
    $nic = New-AzureNetworkInterface -Name $nicname -ResourceGroupName $rgName -Location $location -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id

##### Compute

    ## Setup local VM object
    $cred = Get-Credential
    $vm = New-AzureVMConfig -VMName $vmName -VMSize $vmSize

    $vm = Add-AzureVMNetworkInterface -VM $vm -Id $nic.Id

    $osDiskUri = "https://test.blob.core.windows.net/vhds/osdiskforlinuxsimple.vhd"
    $vm = Set-AzureVMOSDisk -VM $vm -Name $osDiskName -VhdUri $osDiskUri -CreateOption attach -Linux

    ## Create the VM in Azure
    New-AzureVM -ResourceGroupName $rgName -Location $location -VM $vm -Verbose -Debug
