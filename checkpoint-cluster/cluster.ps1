#############################################################################
# Dependencies
#############################################################################
Add-Type -AssemblyName System.Web

#############################################################################
# Parameters
#############################################################################

# Description : A user principle name used by the cluster to make Azure API calls 
# Mandatory   : Yes
$UserPrincipalName = ""
# Description : The above user's password used by the cluster to make Azure API calls
# Mandatory   : Yes
$ClusterPassword = [System.Web.Security.Membership]::GeneratePassword(20,10)

# Description : Name of the resource group to create 
# Mandatory   : Yes
$ResourceGroup = ""
# Description : Azure location (e.g. eastus2)
# Mandatory   : Yes
$Location = ""
# Description : The Subscription ID to use in case you have more than one
# Mandatory   : No
$SubscriptionId = ""
# Description : The Name of storage account to create
# Mandatory   : Yes
$StorageAccount = ""

# SSH settings, set one of the following
# Description : The Administrator password
# Mandatory   : Onlhy if not provoding an SSH public key
$SSHPassword = ""
# Description : The Administrator SSH public key (if using SSH public key authentication)
# Mandatory   : Only if not providing an SSH password 
$SSHPublicKey = ""

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

# Description : The names of the subnets to create
# Mandatory   : Yes
$Subnet1Name = "Frontend"
$Subnet2Name = "Web"
$Subnet3Name = "App"

# Description : The address prefix of each subnet
# Mandatory   : Yes
# Valid values: CIDR notation
$Subnet1Prefix = "10.0.1.0/24"
$Subnet2Prefix = "10.0.2.0/24"
$Subnet3Prefix = "10.0.3.0/24"

# Description : Cluster members IP private addresses
# Mandatory   : Yes
# Valid values: A list of IPv4 address
$Subnet1PrivateAddresses = @("10.0.1.10", "10.0.1.20")
$Subnet2PrivateAddresses = @("10.0.2.10", "10.0.2.20")
$Subnet3PrivateAddresses = @("10.0.3.10", "10.0.3.20")

# Description : The Cluster name
# Mandatory   : Yes
# Valid values: Must begin with a lower case letter and consist only of low case letters and numbers.
$ClusterName = ""

# Description : The size of the VMs of the cluster members
# Mandatory   : Yes
$ClusterVMSize = "Standard_D3_v2"

# Description : A list of web application to create
# Mandatory   : No
$WebApps = @(
    @{ 
        "name" = "WebApp1";
        "services" = @(
            @{
                "name" = "http";
                "protocol" = "tcp";
                "frontendport" = 80;
                "backendport" = "8081";
            }
        )
    },
    @{ 
        "name" = "WebApp2";
        "services" = @(
            @{
                "name" = "http";
                "protocol" = "tcp";
                "frontendport" = 80;
                "backendport" = "8082";
            }
        )
    }
)    

# Description : The licensing model
# Mandatory   : Yes
# Valid values:  "sg-byol" - for Bring Your Own License
#                "sg-ngtp" - for a Pay-As-You-Go offering 
$SKU = "sg-byol"

#############################################################################
# Variables - these should normally be left unchanged
#############################################################################
$IdleTimeoutInMinutes = 30
$Publisher = "checkpoint"
$Offer = "check-point-r77-10"
$Version = "latest"

# The following services are needed in order to manage the cluster members from an on premise management server
$CheckPointServices = @(
    @{ 
        "name" = "SSH";
        "protocol" = "tcp";
        "port" = 22
    },
    @{ 
        "name" = "WebUI";
        "protocol" = "tcp";
        "port" = 443
    },
    @{ 
        "name" = "FWD";
        "protocol" = "tcp";
        "port" = 256
    },
    @{ 
        "name" = "CPD";
        "protocol" = "tcp";
        "port" = 18191
    },
    @{ 
        "name" = "AMON";
        "protocol" = "tcp";
        "port" = 18192
    },
    @{ 
        "name" = "ICAPUSH";
        "protocol" = "tcp";
        "port" = 18211
    }
)

$Config = ConvertTo-Json @{
  "debug" =  $false;
  "subscriptionId" = $SubscriptionId;
  "resourceGroup" = $ResourceGroup;
  "userName" = $UserPrincipalName;
  "password" = $ClusterPassword;
  "virtualNetwork" = $VNetName;
  "clusterName" = $ClusterName;
  "lbName" = "$ClusterName-LoadBalancer";
}

$CustomData = @"
#!/bin/bash

cat <<EOF >"`$FWDIR/conf/azure-ha.json"
$Config
EOF

conf="install_security_gw=true"
conf="`${conf}&install_ppak=true"
conf="`${conf}&gateway_cluster_member=true"
conf="`${conf}&install_security_managment=false"
conf="`${conf}&ftw_sic_key=$SicKey"

config_system -s "`$conf"
shutdown -r now

"@.replace("`r", "")

#############################################################################
# Parameter validation
#############################################################################
if (!$UserPrincipalName -or !$ClusterPassword) {
    Throw "Invalid user credentials"
}
if (!$SSHPassword -and !$SSHPublicKey) {
    Throw "An SSH password or public key must be specified" 
}
if (!$ResourceGroup) {
    Throw -Message "Invalid resource group name"
}
if (!$Location) {
    Throw "Invalid Location"
}
if (!$StorageAccount) {
    Throw -Message "Invalid storage account"
}
if ($SicKey.Length -lt 8) {
    Throw -Message "SIC key should be at least 8 characters"
}
if (!$ClusterName) {
    Throw -Message "Invalid cluster name"
}
if (!@("sg-byol", "sg-ngtp").Contains($SKU))  {
    Throw -Message "Invalid SKU"
}

#############################################################################
# Resources
#############################################################################

$ErrorActionPreference = "Stop"

# Login:
$Cred = Get-Credential
Connect-MsolService -Credential $Cred
Login-AzureRmAccount -Credential $Cred

Select-AzureRmSubscription -SubscriptionId $SubscriptionId
    
# Create a user:
New-MsolUser `
    -DisplayName "ClusterXL" `
    -UserPrincipalName $UserPrincipalName `
    -ForceChangePassword $false `
    -Password $ClusterPassword `
    -PasswordNeverExpires $true
    
# Create a new resource group:
New-AzureRmResourceGroup -Name $ResourceGroup `
    -Location $Location
        
# Assign the user with permission to modify the resources in the resource group        
New-AzureRmRoleAssignment `
    -ResourceGroupName $ResourceGroup `
    -SignInName $UserPrincipalName `
    -RoleDefinitionName Contributor


# Create the Virtual Network, its subnets and routing tables
$Subnet1RT = New-AzureRmRouteTable `
    -ResourceGroupName $ResourceGroup `
    -Location $Location `
    -Name $Subnet1Name 
    
Add-AzureRmRouteConfig `
    -RouteTable $Subnet1RT `
    -Name "Local-Subnet" `
    -AddressPrefix $Subnet1Prefix `
    -NextHopType VnetLocal | Set-AzureRmRoutetable

Add-AzureRmRouteConfig `
    -RouteTable $Subnet1RT `
    -Name "To-Internal" `
    -AddressPrefix $AddressPrefix `
    -NextHopType VirtualAppliance `
    -NextHopIpAddress $Subnet1PrivateAddresses[0] | Set-AzureRmRoutetable
    
$Subnet2RT = New-AzureRmRouteTable `
    -ResourceGroupName $ResourceGroup `
    -Location $Location `
    -Name $Subnet2Name 
    
Add-AzureRmRouteConfig `
    -RouteTable $Subnet2RT `
    -Name "Local-Subnet" `
    -AddressPrefix $Subnet2Prefix `
    -NextHopType VnetLocal | Set-AzureRmRoutetable

Add-AzureRmRouteConfig `
    -RouteTable $Subnet2RT `
    -Name "Inside-Vnet" `
    -AddressPrefix $AddressPrefix `
    -NextHopType VirtualAppliance `
    -NextHopIpAddress $Subnet2PrivateAddresses[0] | Set-AzureRmRoutetable

Add-AzureRmRouteConfig `
    -RouteTable $Subnet2RT `
    -Name "To-Internet" `
    -AddressPrefix "0.0.0.0/0" `
    -NextHopType VirtualAppliance `
    -NextHopIpAddress $Subnet2PrivateAddresses[0] | Set-AzureRmRoutetable
    
$Subnet3RT = New-AzureRmRouteTable `
    -ResourceGroupName $ResourceGroup `
    -Location $Location `
    -Name $Subnet3Name 
    
Add-AzureRmRouteConfig `
    -RouteTable $Subnet3RT `
    -Name "Local-Subnet" `
    -AddressPrefix $Subnet3Prefix `
    -NextHopType VnetLocal | Set-AzureRmRoutetable

Add-AzureRmRouteConfig `
    -RouteTable $Subnet3RT `
    -Name "Inside-Vnet" `
    -AddressPrefix $AddressPrefix `
    -NextHopType VirtualAppliance `
    -NextHopIpAddress $Subnet3PrivateAddresses[0] | Set-AzureRmRoutetable

Add-AzureRmRouteConfig `
    -RouteTable $Subnet3RT `
    -Name "To-Internet" `
    -AddressPrefix "0.0.0.0/0" `
    -NextHopType VirtualAppliance `
    -NextHopIpAddress $Subnet3PrivateAddresses[0] | Set-AzureRmRoutetable

$Subnet1 = New-AzureRmVirtualNetworkSubnetConfig `
    -Name $Subnet1Name `
    -AddressPrefix $Subnet1Prefix `
    -RouteTable $Subnet1RT
$Subnet2 = New-AzureRmVirtualNetworkSubnetConfig `
    -Name $Subnet2Name `
    -AddressPrefix $Subnet2Prefix `
    -RouteTable $Subnet2RT
$Subnet3 = New-AzureRmVirtualNetworkSubnetConfig `
    -Name $Subnet3Name `
    -AddressPrefix $Subnet3Prefix `
    -RouteTable $Subnet3RT
    
$Vnet = New-AzureRmVirtualNetwork `
    -ResourceGroupName $ResourceGroup `
    -Location $Location `
    -Name $VNetName `
    -AddressPrefix $AddressPrefix `
    -Subnet @($Subnet1, $Subnet2, $Subnet3)
$Subnet1 = Get-AzureRmVirtualNetworkSubnetConfig `
    -VirtualNetwork $Vnet -Name $Subnet1Name
$Subnet2 = Get-AzureRmVirtualNetworkSubnetConfig `
    -VirtualNetwork $Vnet -Name $Subnet2Name
$Subnet3 = Get-AzureRmVirtualNetworkSubnetConfig `
    -VirtualNetwork $Vnet -Name $Subnet3Name


# Create a storage account for storing disks and boot diagnostics
New-AzureRmStorageAccount `
    -ResourceGroupName $ResourceGroup `
    -Location $Location `
    -Name $StorageAccount `
    -Type Standard_LRS

# Create an availability set. We will later place the cluster members in it.
$AvailabilitySet = New-AzureRmAvailabilitySet `
    -ResourceGroupName $ResourceGroup `
    -Location $Location `
    -Name "$ClusterName-AvailabilitySet" 
    
# Allocate the cluster public address
$ClusterPublicAddress = New-AzureRmPublicIpAddress `
    -ResourceGroupName $ResourceGroup `
    -Location $Location `
    -Name $ClusterName `
    -AllocationMethod Static `
    -IdleTimeoutInMinutes $IdleTimeoutInMinutes

# Create a load balancer    
$LoadBalancer = New-AzureRmLoadBalancer `
    -ResourceGroupName $ResourceGroup `
    -Location $Location `
    -Name $ClusterName-LoadBalancer

# Allocate public addresses for the applications
$WebAppsPublicAddresses = @()
foreach ($WebApp in $WebApps) {
    $WebAppPublicAddress = New-AzureRmPublicIpAddress `
        -ResourceGroupName $ResourceGroup `
        -Location $Location `
        -Name $WebApp.name `
        -AllocationMethod Static `
        -IdleTimeoutInMinutes $IdleTimeoutInMinutes
    $WebAppsPublicAddresses += $WebAppPublicAddress
    
    Add-AzureRmLoadBalancerFrontendIpConfig `
        -Name $WebApp.name `
        -LoadBalancer $LoadBalancer `
        -PublicIpAddress $WebAppPublicAddress
    $IpConfig = $LoadBalancer.FrontendIpConfigurations | where -Property Name -EQ $WebApp.name

    foreach ($Service in $WebApp.services) {
        Add-AzureRmLoadBalancerInboundNatRuleConfig `
            -Name ($WebApp.name + "-" + $Service.name) `
            -LoadBalancer $LoadBalancer `
            -FrontendIpConfiguration $IpConfig `
            -Protocol $Service.protocol `
            -FrontendPort $Service.frontendport `
            -BackendPort $Service.backendport `
            -IdleTimeoutInMinutes $IdleTimeoutInMinutes
    }
}


$MembersPublicAddresses = @()
for ($i = 0; $i -lt 2; $i += 1) {
    $MemberName = $ClusterName + "-" + ($i + 1)
    $MembersPublicAddresses += New-AzureRmPublicIpAddress `
        -ResourceGroupName $ResourceGroup `
        -Location $Location `
        -Name $MemberName `
        -AllocationMethod Static `
        -IdleTimeoutInMinutes $IdleTimeoutInMinutes

    Add-AzureRmLoadBalancerFrontendIpConfig `
        -Name $MemberName `
        -LoadBalancer $LoadBalancer `
        -PublicIpAddress $membersPublicAddresses[$i]
    $IpConfig = $LoadBalancer.FrontendIpConfigurations | where -Property Name -EQ $MemberName

    foreach ($service in $CheckPointServices) {
        Add-AzureRmLoadBalancerInboundNatRuleConfig `
            -Name ("checkpoint-" + $service.name + ($i+1)) `
            -LoadBalancer $LoadBalancer `
            -FrontendIpConfiguration $IpConfig `
            -Protocol $service.protocol `
            -FrontendPort $service.port `
            -BackendPort $service.port `
            -IdleTimeoutInMinutes $IdleTimeoutInMinutes
    }

    $addr = $null
    if ($i -eq 0) {
        # Associate the cluster public IP address with the 1st cluster member
        $addr = $ClusterPublicAddress
    }

    $LoadBalancer = Set-AzureRmLoadBalancer -LoadBalancer $LoadBalancer
    $IpConfig = $LoadBalancer.FrontendIpConfigurations | where -Property Name -EQ $MemberName
    $InboundNatRules = $LoadBalancer.InboundNatRules | where {$_.FrontendIPConfiguration.Id -EQ $IpConfig.Id}
    if ($i -eq 0) {
        $InboundNatRules += $LoadBalancer.InboundNatRules | where {! $_.Name.StartsWith("checkpoint") }
    }
   
    $nic1 = New-AzureRmNetworkInterface `
        -Name ("ext-" + ($i + 1)) `
        -ResourceGroupName $ResourceGroup `
        -Location $Location `
        -PublicIpAddress $addr `
        -PrivateIpAddress $Subnet1PrivateAddresses[$i] `
        -Subnet $Subnet1 `
        -LoadBalancerInboundNatRule $InboundNatRules `
        -EnableIPForwarding

    $nic2 = New-AzureRmNetworkInterface `
        -Name ("int0-" + ($i + 1)) `
        -ResourceGroupName $ResourceGroup `
        -Location $Location `
        -PrivateIpAddress $Subnet2PrivateAddresses[$i] `
        -Subnet $Subnet2 `
        -EnableIPForwarding

    $nic3 = New-AzureRmNetworkInterface `
        -Name ("int1-" + ($i + 1)) `
        -ResourceGroupName $ResourceGroup `
        -Location $Location `
        -PrivateIpAddress $Subnet3PrivateAddresses[$i] `
        -Subnet $Subnet3 `
        -EnableIPForwarding
        
    $VMConfig = New-AzureRmVMConfig `
        -VMName $MemberName `
        -VMSize $ClusterVMSize `
        -AvailabilitySetId $AvailabilitySet.Id 

    $OSCred = $null
    if ($SSHPAssword) {
        $SecureSSHPassword = ConvertTo-SecureString $SSHPassword -AsPlainText -Force
        $OSCred = New-Object System.Management.Automation.PSCredential ("notused", $SecureSSHPassword)
    }
    Set-AzureRmVMOperatingSystem -VM $VMConfig `
        -Linux `
        -ComputerName $MemberName `
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

    Add-AzureRmVMNetworkInterface -VM $VMConfig `
        -Id $nic1.Id -Primary
    Add-AzureRmVMNetworkInterface -VM $VMConfig `
        -Id $nic2.Id
    Add-AzureRmVMNetworkInterface -VM $VMConfig `
        -Id $nic3.Id

    Set-AzureRmVMOSDisk -VM $VMConfig `
        -Name "osDisk" `
        -VhdUri ("https://" + $StorageAccount + ".blob.core.windows.net/" + $ClusterName + "/osDisk" + ($i + 1) + ".vhd") `
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
        
}

#############################################################################
# Output
#############################################################################

Write-Host "Allocated public IP addresses:"
Write-Host "=============================="
Write-Host "Cluster: " $ClusterPublicAddress.IpAddress
Write-Host "Member1: " $MembersPublicAddresses[0].IpAddress
Write-Host "Member2: " $MembersPublicAddresses[1].IpAddress

