# PowerShell script to create the same two-NIC VM as the assoicated json template.
# Author, Colin Cole, Microsoft

Switch-AzureMode AzureResourceManager

# Variables 
$rgname = 'samplerg'
$vnetName = $rgname + 'vnet' 
$vnetAddressPrefix = '10.0.0.0/16'
$subnetName = $rgname + 'subnet' 
$subnetAddressPrefix = '10.0.1.0/24'
$publicIpName = $rgname + 'pubip' 
$lbName = $rgname + 'lb'
$frontendName = $rgname + 'frontend'
$backendAddressPoolName = $rgname + 'backend' 
$inboundNatRuleName1 = $rgname + 'nat1' 
$nicname1 = $rgname + 'nic1' 
$nicname2 = $rgname + 'nic2' 
$resourceTypeParent = "Microsoft.Network/loadBalancers" 
$location = 'westus'
$vmsize = 'Standard_D2';  # must be A2 or D2 or above for two nics
$vmname = $rgname + 'vm';
$stoname = $rgname.ToLower() + 'sto';
$stotype = 'Standard_LRS'; 
$osDiskName = 'osDisk';
$osDiskVhdUri = "https://$stoname.blob.core.windows.net/vhds/os.vhd"; 
$user = "ops";
$password = 'pass@word2';
 
# Create the resource group 
New-AzureResourceGroup -Name $rgname -Location $location 
          
# Create the Virtual Network 
$subnet = New-AzureVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix $subnetAddressPrefix 
$vnet = New-AzurevirtualNetwork -Name $vnetName -ResourceGroupName $rgname -Location $location -AddressPrefix $vnetAddressPrefix -Subnet $subnet 
          
# Create the publicip 
$publicip = New-AzurePublicIpAddress -ResourceGroupName $rgname -name $publicIpName -location $location -AllocationMethod Dynamic 
  
# Create LoadBalancer and open up a NAT rule
$frontend = New-AzureLoadBalancerFrontendIpConfig -Name $frontendName -PublicIpAddress $publicip 
$backendAddressPool = New-AzureLoadBalancerBackendAddressPoolConfig -Name $backendAddressPoolName 
$inboundNatRule1 = New-AzureLoadBalancerInboundNatRuleConfig -Name $inboundNatRuleName1 -FrontendIPConfiguration $frontend -Protocol Tcp -FrontendPort 50001 -BackendPort 3389 -IdleTimeoutInMinutes 15 
$lb = New-AzureLoadBalancer -Name $lbName -ResourceGroupName $rgname -Location $location -FrontendIpConfiguration $frontend -BackendAddressPool $backendAddressPool -InboundNatRule $inboundNatRule1 
          
# Create 2 network interfaces and accociate to loadbalancer to nic1  
$nic1 = New-AzureNetworkInterface -Name $nicname1 -ResourceGroupName $rgname -Location $location -Subnet $vnet.Subnets[0] -LoadBalancerBackendAddressPool $lb.BackendAddressPools[0] -LoadBalancerInboundNatRule $lb.InboundNatRules[0] 
$nic2 = New-AzureNetworkInterface -Name $nicname2 -ResourceGroupName $rgname -Location $location -SubnetId $vnet.Subnets[0].Id  

# Associate the nic to the load balancer 
$nic1.IpConfigurations[0].LoadBalancerBackendAddressPools.Add($lb.BackendAddressPools[0]); 
$nic1.IpConfigurations[0].LoadBalancerInboundNatRules.Add($lb.InboundNatRules[0]); 

# Configure VM and attach networking interfaces
$vm = New-AzureVMConfig -VMName $vmname -VMSize $vmsize;
$vm = Add-AzureVMNetworkInterface -VM $vm -Id $nic1.Id -Primary;
$vm = Add-AzureVMNetworkInterface -VM $vm -Id $nic2.Id;

# Setup storage account
New-AzureStorageAccount -ResourceGroupName $rgname -Name $stoname -Location $location -Type $stotype;
$stoaccount = Get-AzureStorageAccount -ResourceGroupName $rgname -Name $stoname;
   
# Add OS Disk
$vm = Set-AzureVMOSDisk -VM $vm -Name $osDiskName -VhdUri $osDiskVhdUri -Caching 'ReadWrite' -CreateOption fromImage;
    
# Setup OS 
$securePassword = ConvertTo-SecureString $password -AsPlainText -Force;
$cred = New-Object System.Management.Automation.PSCredential ($user, $securePassword);   
$vm = Set-AzureVMOperatingSystem -VM $vm -Windows -ComputerName $vmname -Credential $cred;

# Setup Image
$vm = Set-AzureVMSourceImage -VM $vm -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2012-R2-Datacenter -Version "latest"
    
# Create Virtual Machine
New-AzureVM -ResourceGroupName $rgname -Location $location -Name $vmname -VM $vm;
