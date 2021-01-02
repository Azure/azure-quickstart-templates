#region Initialize Environment, Authenticate to Azure AD and setting Resource Parameters 

# Change Command Prompt #
function prompt {"$(get-date)> "} 
# Suppress Warning: https://aka.ms/azps-changewarnings #
Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings "true"
# Creating timer: #
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

# Setting subscription variables & AAD Login: #
$SubscriptionName = '<<< INSERT YOUR VALUE HERE >>>'
$subscriptionId = '<<< INSERT YOUR VALUE HERE >>>'
$TenantId = '<<< INSERT YOUR VALUE HERE >>>'
$Environment = 'AzureCloud' # Azure Public Cloud

# Authenticate to Azure AD: #
Connect-AzAccount -Tenant $TenantId -SubscriptionId $subscriptionId

# Set default subscription context: #
Set-AzContext -SubscriptionId $subscriptionId

# vWAN and Resource Group Parameters: #
$RGname = '<<< INSERT YOUR VALUE HERE >>>'       # Resource Group name
$location = '<<< INSERT YOUR VALUE HERE >>>'     # Azure Region  
$vWanName = '<<< INSERT YOUR VALUE HERE >>>'     # vWAN name 
$vmPrefix = "i1-"                                # prefix for VM name creation 
$defaultsubnetName = 'subnet1'                   # In each VNET, script will try to use subnet with this name, otherwise will select the last subnet available in the VNET.

# Credentials for Local Admin account inside VMs: #
$vmAdminUsername = '<<< INSERT YOUR VALUE HERE >>>'
$pwd = '<<< INSERT YOUR VALUE HERE >>>'
$vmAdminPassword = ConvertTo-SecureString $pwd -AsPlainText -Force
$vmCredential = New-Object System.Management.Automation.PSCredential ($vmAdminUsername, $vmAdminPassword)

# VM config parameters: #
$azureVmSize = "Standard_D2s_v3"
$azureVmPublisherName = "MicrosoftWindowsServer"
$azureVmOffer = "WindowsServer"
$azureVmSkus = "2019-Datacenter"

#endregion 


#region Getting existing vWAN configuration #
$ResourceGroup = Get-AzResourceGroup -Name $RGname -Location $location
$vWAN = Get-AzVirtualWan -ResourceGroupName $RGname -Name $vWanName 
$hubList = Get-AzVirtualHub -ResourceGroupName $RGname
$vNetList = Get-AzVirtualNetwork -ResourceGroupName $RGname
$hubCount = $hubList.Count
$vnetcount = $vNetList.Count
Write-Host "Found [$vnetcount] Virtual Networks in [$hubCount] vWAN hubs" -ForegroundColor Green
#endregion


#region Create a VM inside each VNET
ForEach ($vnet in $vNetList)
 { 
  $vnetname= $vnet.Name
  $vnetlocation = $vnet.Location 
  $maxvnetnamelenght = 15 - 2 - $vmPrefix.Length 
    if ($maxvnetnamelenght  -gt  $vnetname.Length)
    { $maxvnetnamelenght  = $vnetname.Length }
  $vmname = ($vmPrefix + (($vnetname).Substring(0,$maxvnetnamelenght)) + "vm").ToLower()
    
  # Selecting the subnet #
  # In each VNET, will try to use subnet with name "$defaultsubnetName", otherwise will select the last subnet in the VNET. 
  $vmSubnetList = $vnet.Subnets
  $vmSubnetCount = $vnet.Subnets.Count
  if ($vmSubnetCount -eq 0) 
    { 
        Write-Host "No suitable subnet for Virtual Network [$vnetname], VM will be not created, proceeding with next one...." -BackgroundColor Red
        continue 
    }
  $vmSubnet = $null
  $vmSubnet = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $defaultsubnetName -ErrorAction SilentlyContinue
  $vmSubnetName = $vmSubnet.Name
  if (!$vmSubnet)
   {
        # Default subnet with name "$defaultsubnetName" not existing, try to use the last one #
        $vmSubnet = $vnet.Subnets[($vmSubnetCount-1)]
        $vmSubnetName = $vmSubnet.Name
        Write-Host "No default subnet with name [$defaultsubnetName] is present, going to use [$vmSubnetName]..." -BackgroundColor Yellow -ForegroundColor DarkRed
   }
  
  Write-Host "Creating VM [$vmname] inside subnet [$vmSubnetName] for Virtual Network [$vnetname] in [$vnetlocation] --> " -NoNewline -ForegroundColor Green 

  # Setting VM parameters: #
  $azureVmOsDiskName = $vmname + "-osdisk"
  $azurePublicIpName = $vmname + "-pip"
  $azureNicName = $vmname + "-nic"
  $azureNSGname = $vmname + "-nsg"
  $zones = 1
  
  # Create the public IP address: #
  $azurePublicIp = New-AzPublicIpAddress -Name $azurePublicIpName -ResourceGroupName $RGname -Location $vnetlocation -AllocationMethod Static -Sku Standard -Zone $zones
 
  # Creating NSG with default DENY: you will have to change NSG to allow RDP access: #
  $rule = New-AzNetworkSecurityRuleConfig -Name "rdp-rule" -Description "Allow RDP" -Access Deny -Protocol Tcp -Direction Inbound -Priority 100 -SourceAddressPrefix `
            Internet -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389
  $nsg = New-AzNetworkSecurityGroup -ResourceGroupName $RGname -Location $vnetlocation -Name $azureNSGname -SecurityRules $rule

  #Create the NIC and associate the public IpAddress and NSG: #
  $azureNIC = New-AzNetworkInterface -Name $azureNicName -ResourceGroupName $RGname -Location $vnetlocation -SubnetId $vmSubnet.Id -PublicIpAddressId $azurePublicIp.Id -NetworkSecurityGroupId $nsg.Id
 
  #Define the parameters for the new virtual machine: #
  $VM = New-AzVMConfig -VMName $vmname -VMSize $azureVmSize
  $VM = Set-AzVMOperatingSystem -VM $VM -Windows -ComputerName $vmname -Credential $vmCredential -ProvisionVMAgent -EnableAutoUpdate
  $VM = Add-AzVMNetworkInterface -VM $VM -Id $azureNIC.Id
  $VM = Set-AzVMSourceImage -VM $VM -PublisherName $azureVmPublisherName -Offer $azureVmOffer -Skus $azureVmSkus -Version "latest"
  $VM = Set-AzVMBootDiagnostic -VM $VM -Disable
  $VM = Set-AzVMOSDisk -VM $VM -StorageAccountType StandardSSD_LRS -Caching ReadWrite -Name $azureVmOsDiskName -CreateOption FromImage
 
  #Create the VM: #
  $stopwatch.Reset()
  $stopwatch.Start()
  New-AzVM -ResourceGroupName $RGname -Location $vnetlocation -VM $VM
  $stopwatch.Stop()
  $elapsed = $stopwatch.Elapsed.TotalMinutes
  Write-Host "Execution completed in [$elapsed] minutes..." -ForegroundColor Green 
  
 }
 #endregion 


#region STOP ALL VMs in vWAN Resource Groups

############################################# STOP ALL VMs in vWAN Resource Groups #############################################

Get-AzVM -ResourceGroupName $RGname | Stop-AzVM -Force

#endregion


#region START ALL VMs in vWAN Resource Groups
############################################# START ALL VMs in vWAN Resource Groups #############################################

Get-AzVM -ResourceGroupName $RGname | Start-AzVM

#endregion


#region List all VMs inside the Resource Group with NIC name, Public and Private IPs

############################################# List all VMs inside the Resource Group with NIC name, Public and Private IPs #############################################

$nicList = Get-AzNetworkInterface -ResourceGroupName $RGname
foreach ($nic in $nicList)
{
   # $nic
    # Write-Host("NIC name = " + $nic.Name + "---")
    $vmname = $nic.VirtualMachine.Id
    $vmname = $vmname.Substring(($vmname.LastIndexOf('/')+1),($vmname.Length - $vmname.LastIndexOf('/')-1))
    # $vmname 

    # $nic.Name 
        
    $vmprivateip = $nic.Ipconfigurations[0].PrivateIpAddress
    # $vmprivateip 

    $pipname = $nic.Ipconfigurations[0].PublicIpAddress[0].Id
    $pipname = $pipname.Substring(($pipname.LastIndexOf('/')+1),($pipname.Length - $pipname.LastIndexOf('/')-1))
    
    $pip = (Get-AzPublicIpAddress -ResourceGroupName $RGname -Name $pipname).IpAddress
    # $pip 
    Write-Host("VM Name = [" + $vmname + "], NIC Name = [" + $nic.Name + "], Private IP = [" + $vmprivateip + "], Public IP = [" + $pip + "]") -ForegroundColor Green
}
#endregion 


#region Get Effective Routes for a specific VM in vWAN VNET

############################################# Get Effective Routes for a specific VM in vWAN VNET ##############################

# Get effective Route Table for a specific VM: #
$vmname = "i1-vnet2vm"
$vm = Get-AzVM -Name $vmname -ResourceGroupName $RGname
$nicName = $vm.NetworkProfile.NetworkInterfaces[0].Id
$nicName = $nicName.Substring(($nicName.LastIndexOf('/')+1),($nicName.Length - $nicName.LastIndexOf('/')-1))
$routeTable = Get-AzEffectiveRouteTable -NetworkInterfaceName $nicName -ResourceGroupName $RGname
$routeTable | Format-Table -AutoSize 

#################################################################################################################################

#endregion 
