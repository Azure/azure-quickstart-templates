# Set variables for existing r
$location              = "East US 2"
$vnetName              = "WTestVNet"
$backendSubnetName     = "BackEnd"

# Set variables to use for backend VMs
$backendCSName         = "IaaSStory-Backend"
$prmStorageAccountName = "iaasstoryprmstorage"
$avSetName             = "ASDB"
$vmSize                = "Standard_DS3"
$diskSize              = 127
$vmNamePrefix          = "DB"
$dataDiskSuffix        = "datadisk"
$ipAddressPrefix       = "192.168.2."
$numberOfVMs           = 2

# Create cloud service for VM
New-AzureService -ServiceName $backendCSName -Location $location

# Create storage account for VM disks
New-AzureStorageAccount -StorageAccountName $prmStorageAccountName `
    -Location $location `
    -Type Premium_LRS

# Set default storage account for current subscription
$subscription = Get-AzureSubscription `
    | where {$_.IsCurrent -eq $true}  
Set-AzureSubscription -SubscriptionName $subscription.SubscriptionName `
    -CurrentStorageAccountName $prmStorageAccountName

# Get image for VM
$image = Get-AzureVMImage `
    | where{$_.ImageFamily -eq "SQL Server 2014 RTM Web on Windows Server 2012 R2"} `
    | sort PublishedDate -Descending `
    | select -ExpandProperty ImageName -First 1

# Get credentials
$cred = Get-Credential -Message "Enter username and password for local admin account"

# Loop to create VMs and data disks
for ($suffixNumber = 1; $suffixNumber -le $numberOfVMs; $suffixNumber++){
    # Create VM config object
    $vmName = $vmNamePrefix + $suffixNumber
    $vmConfig = New-AzureVMConfig -Name $vmName `
                    -ImageName $image `
                    -InstanceSize $vmSize `
                    -AvailabilitySetName $avSetName                
    
    # Provision the VM
    Add-AzureProvisioningConfig -VM $vmConfig -Windows `
        -AdminUsername $cred.UserName `
        -Password $cred.Password 
    
    # Set deafult NIC and IP address
    Set-AzureSubnet -SubnetNames $backendSubnetName -VM $vmConfig
    Set-AzureStaticVNetIP -IPAddress ($ipAddressPrefix+$suffixNumber+3) -VM $vmConfig

    # Add a NIC
    Add-AzureNetworkInterfaceConfig -Name ("RemoteAccessNIC"+$suffixNumber) `
        -SubnetName $backendSubnetName `
        -StaticVNetIPAddress ($ipAddressPrefix+(53+$suffixNumber)) `
        -VM $vmConfig 

    # Create data disks
    $dataDisk1Name = $vmName + "-" + $dataDiskSuffix + "-1"    
    Add-AzureDataDisk -CreateNew -VM $vmConfig `
        -DiskSizeInGB $diskSize `
        -DiskLabel $dataDisk1Name `
        -LUN 0       

    $dataDisk2Name = $vmName + "-" + $dataDiskSuffix + "-2"   
    Add-AzureDataDisk -CreateNew -VM $vmConfig `
        -DiskSizeInGB $diskSize `
        -DiskLabel $dataDisk2Name `
        -LUN 1

    # Create the VM
    New-AzureVM -VM $vmConfig `
        -ServiceName $backendCSName `
        -Location $location `
        -VNetName $vnetName
}