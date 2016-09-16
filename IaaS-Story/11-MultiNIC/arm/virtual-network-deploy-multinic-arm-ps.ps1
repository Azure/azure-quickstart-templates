# Set variables for existing resource group
$existingRGName        = "IaaSStory"
$location              = "West US"
$vnetName              = "WTestVNet"
$backendSubnetName     = "BackEnd"
$remoteAccessNSGName   = "NSG-RemoteAccess"
$stdStorageAccountName = "wtestvnetstoragestd"

# Set variables to use for backend resource group
$backendRGName         = "IaaSStory-Backend"
$prmStorageAccountName = "wtestvnetstorageprm"
$avSetName             = "ASDB"
$vmSize                = "Standard_DS3"
$diskSize              = 127
$publisher             = "MicrosoftSQLServer"
$offer                 = "SQL2014SP1-WS2012R2"
$sku                   = "Standard"
$version               = "latest"
$vmNamePrefix          = "DB"
$osDiskSuffix          = "osdiskdb"
$dataDiskSuffix        = "datadisk"
$nicNamePrefix         = "NICDB"
$ipAddressPrefix       = "192.168.2."
$numberOfVMs           = 2

# Retrieve existing resources
$vnet                  = Get-AzureVirtualNetwork -Name $vnetName -ResourceGroupName $existingRGName
$backendSubnet         = $vnet.Subnets|?{$_.Name -eq $backendSubnetName}
$remoteAccessNSG       = Get-AzureNetworkSecurityGroup -Name $remoteAccessNSGName -ResourceGroupName $existingRGName
$stdStorageAccount     = Get-AzureStorageAccount -Name $stdStorageAccountName -ResourceGroupName $existingRGName

# Create necessary resources for VMs
New-AzureResourceGroup -Name $backendRGName -Location $location
$prmStorageAccount = New-AzureStorageAccount -Name $prmStorageAccountName -ResourceGroupName $backendRGName -Type Premium_LRS -Location $location
$avSet = New-AzureAvailabilitySet -Name $avSetName -ResourceGroupName $backendRGName -Location $location

# Loop to create NICs and VMs
for ($suffixNumber = 1; $suffixNumber -le $numberOfVMs; $suffixNumber++){
    # Create NIC for database access
    $nic1Name = $nicNamePrefix + $suffixNumber + "-DA"
    $ipAddress1 = $ipAddressPrefix + ($suffixNumber + 3)
    $nic1 = New-AzureNetworkInterface -Name $nic1Name -ResourceGroupName $backendRGName -Location $location -SubnetId $backendSubnet.Id -PrivateIpAddress $ipAddress1

    #Create NIC for management (RDP)
    $nic2Name = $nicNamePrefix + $suffixNumber + "-RA"
    $ipAddress2 = $ipAddressPrefix + (53 + $suffixNumber)
    $nic2 = New-AzureNetworkInterface -Name $nic2Name -ResourceGroupName $backendRGName -Location $location -SubnetId $backendSubnet.Id -PrivateIpAddress $ipAddress2 -NetworkSecurityGroupId $remoteAccessNSG.Id

    # Create VM config object
    $vmName = $vmNamePrefix + $suffixNumber
    $vmConfig = New-AzureVMConfig -VMName $vmName -VMSize $vmSize -AvailabilitySetId $avSet.Id
    
    # Create data disks
    $dataDisk1Name = $vmName + "-" + $dataDiskSuffix + "-1"    
    $data1VhdUri = $prmStorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $dataDisk1Name + ".vhd"
    Add-AzureVMDataDisk -VM $vmConfig -Name $dataDisk1Name -DiskSizeInGB $diskSize -VhdUri $data1VhdUri -CreateOption empty -Lun 0

    $dataDisk2Name = $vmName + "-" + $dataDiskSuffix + "-2"    
    $data2VhdUri = $prmStorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $dataDisk2Name + ".vhd"
    Add-AzureVMDataDisk -VM $vmConfig -Name $dataDisk2Name -DiskSizeInGB $diskSize -VhdUri $data2VhdUri -CreateOption empty -Lun 1

    # Set credentials, OS, and Image
    $cred = Get-Credential -Message "Type the name and password for the local administrator account."
    $vmConfig = Set-AzureVMOperatingSystem -VM $vmConfig -Windows -ComputerName $vmName -Credential $cred -ProvisionVMAgent -EnableAutoUpdate
    $vmConfig = Set-AzureVMSourceImage -VM $vmConfig -PublisherName $publisher -Offer $offer -Skus $sku -Version $version

    # Add NICs
    $vmConfig = Add-AzureVMNetworkInterface -VM $vmConfig -Id $nic1.Id -Primary
    $vmConfig = Add-AzureVMNetworkInterface -VM $vmConfig -Id $nic2.Id

    # Specify OS disk and create VM
    $osDiskName = $vmName + "-" + $osDiskSuffix
    $osVhdUri = $stdStorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $osDiskName + ".vhd"
    $vmConfig = Set-AzureVMOSDisk -VM $vmConfig -Name $osDiskName -VhdUri $osVhdUri -CreateOption fromImage
    New-AzureVM -VM $vmConfig -ResourceGroupName $backendRGName -Location $location
}