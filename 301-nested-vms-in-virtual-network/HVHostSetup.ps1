[cmdletbinding()]
param (
    [string]$GhostedSubnet = "172.16.2.0/24"
)

New-VMSwitch -Name "NestedSwitch" -SwitchType Internal

$NIC1IP = Get-NetIPAddress | Where-Object -Property AddressFamily -EQ IPv4 | Where-Object -Property InterfaceAlias -EQ Ethernet
$NIC2IP = Get-NetIPAddress | Where-Object -Property AddressFamily -EQ IPv4 | Where-Object -Property InterfaceAlias -EQ "Ethernet 2"
$NATSubnet = Get-Subnet -IP $NIC1IP.IPAddress -MaskBits $NIC1IP.PrefixLength
$HyperVSubnet = Get-Subnet -IP $NIC2IP.IPAddress -MaskBits $NIC2IP.PrefixLength
$NestedSubnet = Get-Subnet $GhostedSubnet

New-NetIPAddress -IPAddress $NestedSubnet.HostAddresses[0] -InterfaceAlias "vEthernet (NestedSwitch)"

Add-DhcpServerv4Scope -Name "Nested VMs" -StartRange $NestedSubnet.HostAddresses[1] -EndRange $NestedSubnet.HostAddresses[-1] -SubnetMask $NestedSubnet.SubnetMask.IPAddressToString
Set-DhcpServerv4OptionValue -DnsServer 168.63.129.16 -Router $NestedSubnet.HostAddresses[0]

Install-RemoteAccess -VpnType RoutingOnly