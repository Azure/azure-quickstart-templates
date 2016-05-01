#############################################################################
# Dependencies
#############################################################################
if ($PSVersionTable.PSVersion.Major -lt 4) {
    Throw "Please update your PowerShell"
}

#############################################################################
# Parameters
#############################################################################

# Description: Name of the resource group to create 
# Mandatory   : Yes
$ResourceGroup = ""
# Description : Azure location (e.g. eastus2)
# Mandatory   : Yes
$Location = ""
# Description : The Subscription ID to use in case you have more than one]
# Mandatory   : No
$SubscriptionId = ""
# Description : The Name of storage account to create
# Mandatory   : Yes
# Valid values: Globally unique, 3-24 lower case alphanumeric characters.
$StorageAccount = ""

# Set one of the following

# Description : The Administrator password
# Mandatory   : Yes, if installing management or if not supplying an SSH public key. 
$Password = ""
# Description : The Administrator SSH public key (if using SSH public key authentication)
# Mandatory   : Only if not providing an SSH password 
$SSHPublicKey = ""

# Description : Set to true to install the VM as a Security Gateway
# Mandatory   : Yes 
# Valid values: "true", "false"
$InstallSecurityGateway="true"
# Description : 
# Set to true if you want the gateway to manage itself. 
# Alternatively, set this to false so that the gateway could be managed from a 
# separate (on-premise or in Azure) management server
# Mandatory   : Yes 
# Valid values: "true", "false"
$InstallSecurityManagement="true"

# Description : 
# If installSecurityManagement is set to true, specify the network from which GUI clients 
# are allowed to connect to it. 
# Mandatory   : Yes
# Valid Values: CIDR notation (e.g. 198.51.100.0/24)
$ManagementGUIClientNetwork="0.0.0.0/0"

# Description : 
# Secure Internal Communication (SIC) one time key used to establish initial 
# trust between the gateway and its management server.
# Mandatory   : Yes
$SicKey = ""

# Description : The name of the Virtual Network to create
# Mandatory   : Yes
$VNetName = "vnet"

# Description : The address range of the Virtual Network to create
# Mandatory   : Yes
# Valid values: CIDR notation
$AddressPrefix = "10.0.0.0/16"

# Description : And address range of an on Premise network for VPN purposes
# Mandatory   : No
# Valid values: CIDR notation
$OnPremiseNetwork = ""

# Description : The names of the subnets to create
# Mandatory   : Yes
$Subnet1Name = "External-Subnet"
$Subnet2Name = "Internal-Subnet"

# Description : The address prefix of each subnet
# Mandatory   : Yes
# Valid values: CIDR notation
$Subnet1Prefix = "10.0.1.0/24"
$Subnet2Prefix = "10.0.2.0/24"

# Description : The gateway address on the external subnet
# Mandatory   : Yes
# Valid values: IPv4 address
$Subnet1PrivateAddress = "10.0.1.10"

# Description : The gateway name
# Mandatory   : Yes
# Valid values: Must begin with a lower case letter and consist only of low case letters and numbers.
$GatewayName = ""
# Description : The size of the gateway VM
# Mandatory   : Yes
$GatewayVMSize = "Standard_D1_v2"

$IdleTimeoutInMinutes = 30
$Publisher = "checkpoint"
$Offer = "check-point-r77-10"
# Description : The licensing model
# Mandatory   : Yes
# Valid values: 
#                "sg-byol" - for Bring Your Own License
#                "sg-ngtp" - for a Pay-As-You-Go offering 
$SKU = "sg-byol"
$Version = "latest"

#############################################################################
# End of parameters
#############################################################################

$ErrorActionPreference = "Stop"

if (!$Password -and !$SSHPublicKey) {
    Throw "A password or public key must be specified" 
}

$StorageAccount = $StorageAccount.ToLower()
if (!($StorageAccount -cmatch "^[a-z0-9]*$")) {
    Throw "The StorageAccount should contain only lower case alphanumeric characters"
}
$set    = "abcdefghijklmnopqrstuvwxyz0123456789".ToCharArray()
for (; $StorageAccount.Length -lt 24; $x++) {
    $StorageAccount += $set | Get-Random
}

# Login:
Login-AzureRmAccount

if ($SubscriptionId) {
    Select-AzureRmSubscription -SubscriptionId $SubscriptionId
}
    
# Create a new resource group:
New-AzureRmResourceGroup -Name $ResourceGroup `
    -Location $Location
        

# Create the Virtual Network, its subnets and routing tables
$Subnet2RT = New-AzureRmRouteTable `
    -ResourceGroupName $ResourceGroup `
    -Location $Location `
    -Name $Subnet2Name 
    
if ($OnPremiseNetwork) {
    Add-AzureRmRouteConfig `
        -RouteTable $Subnet2RT `
        -Name "On-Premise-Network" `
        -AddressPrefix $OnPremiseNetwork `
        -NextHopType VirtualAppliance `
        -NextHopIpAddress $Subnet1PrivateAddress | Set-AzureRmRoutetable
}

Add-AzureRmRouteConfig `
    -RouteTable $Subnet2RT `
    -Name "External-Subnet" `
    -AddressPrefix $Subnet1Prefix `
    -NextHopType VirtualAppliance `
    -NextHopIpAddress $Subnet1PrivateAddress | Set-AzureRmRoutetable


Add-AzureRmRouteConfig `
    -RouteTable $Subnet2RT `
    -Name "Default" `
    -AddressPrefix "0.0.0.0/0" `
    -NextHopType VirtualAppliance `
    -NextHopIpAddress $Subnet1PrivateAddress | Set-AzureRmRoutetable
    

$Subnet1 = New-AzureRmVirtualNetworkSubnetConfig `
    -Name $Subnet1Name `
    -AddressPrefix $Subnet1Prefix `

$Subnet2 = New-AzureRmVirtualNetworkSubnetConfig `
    -Name $Subnet2Name `
    -AddressPrefix $Subnet2Prefix `
    -RouteTable $Subnet2RT
    
$Vnet = New-AzureRmVirtualNetwork `
    -ResourceGroupName $ResourceGroup `
    -Location $location `
    -Name $VNetName `
    -AddressPrefix $AddressPrefix `
    -Subnet @($Subnet1, $Subnet2)
$Subnet1 = Get-AzureRmVirtualNetworkSubnetConfig `
    -VirtualNetwork $Vnet -Name $Subnet1Name
$Subnet2 = Get-AzureRmVirtualNetworkSubnetConfig `
    -VirtualNetwork $Vnet -Name $Subnet2Name


# Create a storage account for storing the disk and boot diagnostics
New-AzureRmStorageAccount `
    -ResourceGroupName $ResourceGroup `
    -Location $Location `
    -Name $StorageAccount `
    -Type Standard_LRS

        
# Allocate the Gateway public address
$GatewayPublicAddress = New-AzureRmPublicIpAddress `
    -ResourceGroupName $ResourceGroup `
    -Location $Location `
    -Name $GatewayName `
    -AllocationMethod Static `
    -IdleTimeoutInMinutes $IdleTimeoutInMinutes

$InstallSecurityGateway=$InstallSecurityGateway.ToLower()
$InstallSecurityManagement=$InstallSecurityManagement.ToLower()

$ManagementGUIClientBase, $ManagementGUIClientMaskLength = $ManagementGUIClientNetwork.Split("/")

$CustomData = @"
#!/bin/bash

conf="install_security_gw=$InstallSecurityGateway"
if "$InstallSecurityGateway"; then
    conf="`${conf}&install_ppak=true"
    conf="`${conf}&gateway_cluster_member=false"
fi
conf="`${conf}&install_security_managment=$InstallSecurityManagement"
if "$InstallSecurityManagement"; then
    conf="`${conf}&install_mgmt_primary=true"
    conf="`${conf}&mgmt_admin_name=admin"
    conf="`${conf}&mgmt_admin_passwd=$Password"
    conf="`${conf}&mgmt_gui_clients_radio=network"
    conf="`${conf}&mgmt_gui_clients_ip_field=$ManagementGUIClientBase"
    conf="`${conf}&mgmt_gui_clients_subnet_field=$ManagementGUIClientMaskLength"
fi
conf="`${conf}&ftw_sic_key=$SicKey"

config_system -s "`$conf"
shutdown -r now

"@.replace("`r", "")

$nic1 = New-AzureRmNetworkInterface `
    -Name "ext" `
    -ResourceGroupName $ResourceGroup `
    -Location $Location `
    -PublicIpAddress $GatewayPublicAddress `
    -PrivateIpAddress $Subnet1PrivateAddress `
    -Subnet $Subnet1 `
    -EnableIPForwarding

$VMConfig = New-AzureRmVMConfig `
    -VMName $GatewayName `
    -VMSize $GatewayVMSize

$OSCred = $null
if ($PAssword) {
    $SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force
    $OSCred = New-Object System.Management.Automation.PSCredential ("notused", $SecurePassword)
}
Set-AzureRmVMOperatingSystem -VM $VMConfig `
    -Linux `
    -ComputerName $GatewayName `
    -Credential $OSCred `
    -CustomData $CustomData `
    
if ($SSHPublicKey) {
    Add-AzureRmVMSshPublicKey -VM $VMConfig `
        -KeyData $SSHPublicKey `
        -Path "/home/notused/.ssh/authorized_keys"
}
    
Set-AzureRmVMBootDiagnostics -VM $VMConfig `
    -Enable `
    -ResourceGroupName $ResourceGroup `
    -StorageAccountName $StorageAccount

Set-AzureRmVMSourceImage -VM $VMConfig `
    -PublisherName $Publisher `
    -Offer $Offer `
    -Skus $SKU `
    -Version $Version 

Add-AzureRmVMNetworkInterface -VM $VMConfig -Id $nic1.Id -Primary

Set-AzureRmVMOSDisk -VM $VMConfig `
    -Name "osDisk" `
    -VhdUri ("https://" + $StorageAccount + ".blob.core.windows.net/" + $GatewayName + "/osDisk.vhd") `
    -Caching ReadWrite `
    -CreateOption FromImage

$VMConfig.Plan = New-Object Microsoft.Azure.Management.Compute.Models.Plan
$VMConfig.Plan.Name = $SKU
$VMConfig.Plan.Publisher = $Publisher
$VMConfig.Plan.Product = $Offer
$VMConfig.Plan.PromotionCode = $null

New-AzureRmVM `
    -ResourceGroupName $ResourceGroup `
    -Location $Location `
    -VM $VMConfig

Write-Host "Allocated public IP addresses:"
Write-Host "=============================="
Write-Host "Gateway: " $GatewayPublicAddress.IpAddress
