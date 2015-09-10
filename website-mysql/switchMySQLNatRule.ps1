$rg="mySQlResourceGroupName"
$from="0" #current mysql master VM postfix, disable its mysql public port 
$to="1" #new mysql master VM postfix, enable its mysql public port

$nic0=Get-AzureNetworkInterface -Name $rg-nic$from -ResourceGroupName $rg
$nic1=Get-AzureNetworkInterface -Name $rg-nic$to -ResourceGroupName $rg

$rule0=$nic0.IpConfigurations[0].LoadBalancerInboundNatRules[1]
$nic0.IpConfigurations[0].LoadBalancerInboundNatRules.removeRange(1,1)
Set-AzureNetworkInterface $nic0

$rule1=$nic1.IpConfigurations[0].LoadBalancerInboundNatRules[1]
$nic1.IpConfigurations[0].LoadBalancerInboundNatRules.removeRange(1,1)
$nic1.IpConfigurations[0].LoadBalancerInboundNatRules.add($rule0)
Set-AzureNetworkInterface $nic0

$nic0.IpConfigurations[0].LoadBalancerInboundNatRules.add($rule1)
Set-AzureNetworkInterface $nic0


