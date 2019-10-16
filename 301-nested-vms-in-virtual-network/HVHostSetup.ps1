[cmdletbinding()]
param (
    [string]$NATSUbnetPrefix,
    [string]$HyperVSubnetPrefix,
    [string]$GhostedSubnetPrefix,
    [string]$VirtualNetworkPrefix
)

Start-Transcript C:\HVHostSetup\ScriptLog.log -Force -Append

Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module Subnet -Force


New-VMSwitch -Name "NestedSwitch" -SwitchType Internal

$NATSubnet = Get-Subnet $NATSubnetPrefix
$HyperVSubnet = Get-Subnet $HyperVSubnetPrefix
$NestedSubnet = Get-Subnet $GhostedSubnetPrefix
$VirtualNetwork = Get-Subnet $VirtualNetworkPrefix
$NIC1IP = Get-NetIPAddress | Where-Object -Property AddressFamily -EQ IPv4 | Where-Object -Property IPAddress -EQ $NATSubnet.HostAddresses[3]
$NIC2IP = Get-NetIPAddress | Where-Object -Property AddressFamily -EQ IPv4 | Where-Object -Property IPAddress -EQ $HyperVSubnet.HostAddresses[3]

New-NetIPAddress -IPAddress $NestedSubnet.HostAddresses[0] -InterfaceAlias "vEthernet (NestedSwitch)"

Add-DhcpServerv4Scope -Name "Nested VMs" -StartRange $NestedSubnet.HostAddresses[1] -EndRange $NestedSubnet.HostAddresses[-1] -SubnetMask $NestedSubnet.SubnetMask.IPAddressToString
Set-DhcpServerv4OptionValue -DnsServer 168.63.129.16 -Router $NestedSubnet.HostAddresses[0]

Install-RemoteAccess -VpnType RoutingOnly
cmd.exe /c "netsh routing ip nat install"
cmd.exe /c "netsh routing ip nat add interface $($NIC1IP.InterfaceAlias)"
cmd.exe /c "netsh routing ip add persistentroute dest=$($NatSubnet.NetworkAddress) mask=$($NATSubnet.SubnetMask) name=$($NIC1IP.InterfaceAlias) nhop=$($NATSubnet.HostAddresses[0])"
cmd.exe /c "netsh routing ip add persistentroute dest=$($VirtualNetwork.NetworkAddress) mask=$($VirtualNetwork.SubnetMask) name=""$($NIC2IP.InterfaceAlias)"" nhop=$($HyperVSubnet.HostAddresses[0])"

Stop-Transcript