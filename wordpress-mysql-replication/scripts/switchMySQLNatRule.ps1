#this script switches the NAT rule on the Azure Load Balancer from the old MySQL master to the new one
$rg="mySQLResourceGroupName"
$dns="mySQLDNSName"
$from="0" #current mysql master VM postfix, disable its mysql public port 
$to="1" #new mysql master VM postfix, enable its mysql public port

$nic0=Get-AzureNetworkInterface -Name $dns-nic$from -ResourceGroupName $rg
$nic1=Get-AzureNetworkInterface -Name $dns-nic$to -ResourceGroupName $rg

$nic0Rules=$nic0.IpConfigurations[0].LoadBalancerInboundNatRules
$nic1Rules=$nic1.IpConfigurations[0].LoadBalancerInboundNatRules

$nic0RuleCnt=$nic0.IpConfigurations[0].LoadBalancerInboundNatRules.Count
$nic1RuleCnt=$nic1.IpConfigurations[0].LoadBalancerInboundNatRules.Count

#find the mysql NAT rule on the old master and remove it
for ($i=0; $i -lt $nic0RuleCnt; ++$i) {if ($nic0Rules[$i].Id -like "*MySQLNatRule*") {break;}}; 
if ($i -ge $nic0RuleCnt) {exit 1}
 
$rule0=$nic0.IpConfigurations[0].LoadBalancerInboundNatRules[$i]
$nic0.IpConfigurations[0].LoadBalancerInboundNatRules.removeRange($i,1)
Set-AzureNetworkInterface -NetworkInterface $nic0

#find the mysql NAT rule on the new master, replace it with the old master's NAT rule
for ($j=0; $j -lt $nic1RuleCnt; ++$j) {if ($nic1Rules[$j].Id -like "*MySQLNatRule*") {break;}}; 
if ($j -ge $nic1RuleCnt) {exit 1}

$rule1=$nic1.IpConfigurations[0].LoadBalancerInboundNatRules[$j]
$nic1.IpConfigurations[0].LoadBalancerInboundNatRules.removeRange($j,1)
$nic1.IpConfigurations[0].LoadBalancerInboundNatRules.add($rule0)
Set-AzureNetworkInterface -NetworkInterface $nic1

#the old master resumes the new master's previous NAT rule
$nic0.IpConfigurations[0].LoadBalancerInboundNatRules.add($rule1)
Set-AzureNetworkInterface -NetworkInterface $nic0
exit 0

