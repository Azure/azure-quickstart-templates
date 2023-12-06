[cmdletbinding()]
param (
    [string]$NIC1IPAddress,
    [string]$NIC2IPAddress,
    [string]$GhostedSubnetPrefix,
    [string]$VirtualNetworkPrefix
)

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module Subnet -Force

New-VMSwitch -Name "NestedSwitch" -SwitchType Internal

$NIC1IP = Get-NetIPAddress | Where-Object -Property AddressFamily -EQ IPv4 | Where-Object -Property IPAddress -EQ $NIC1IPAddress
$NIC2IP = Get-NetIPAddress | Where-Object -Property AddressFamily -EQ IPv4 | Where-Object -Property IPAddress -EQ $NIC2IPAddress

$NATSubnet = Get-Subnet -IP $NIC1IP.IPAddress -MaskBits $NIC1IP.PrefixLength
$HyperVSubnet = Get-Subnet -IP $NIC2IP.IPAddress -MaskBits $NIC2IP.PrefixLength
$NestedSubnet = Get-Subnet $GhostedSubnetPrefix
$VirtualNetwork = Get-Subnet $VirtualNetworkPrefix

New-NetIPAddress -IPAddress $NestedSubnet.HostAddresses[0] -PrefixLength $NestedSubnet.MaskBits -InterfaceAlias "vEthernet (NestedSwitch)"
New-NetNat -Name "NestedSwitch" -InternalIPInterfaceAddressPrefix "$GhostedSubnetPrefix"

Add-DhcpServerv4Scope -Name "Nested VMs" -StartRange $NestedSubnet.HostAddresses[1] -EndRange $NestedSubnet.HostAddresses[-1] -SubnetMask $NestedSubnet.SubnetMask
Set-DhcpServerv4OptionValue -DnsServer 168.63.129.16 -Router $NestedSubnet.HostAddresses[0]

Install-RemoteAccess -VpnType RoutingOnly
cmd.exe /c "netsh routing ip nat install"
cmd.exe /c "netsh routing ip nat add interface ""$($NIC1IP.InterfaceAlias)"""
cmd.exe /c "netsh routing ip add persistentroute dest=$($NatSubnet.NetworkAddress) mask=$($NATSubnet.SubnetMask) name=""$($NIC1IP.InterfaceAlias)"" nhop=$($NATSubnet.HostAddresses[0])"
cmd.exe /c "netsh routing ip add persistentroute dest=$($VirtualNetwork.NetworkAddress) mask=$($VirtualNetwork.SubnetMask) name=""$($NIC2IP.InterfaceAlias)"" nhop=$($HyperVSubnet.HostAddresses[0])"

# Initialize the disk with GPT partition style
$disk = Get-Disk | Where-Object -Property PartitionStyle -EQ "RAW" | Initialize-Disk -PartitionStyle GPT -PassThru

# Retrieve physical disks that can be used in a storage pool
$PhysicalDisks = Get-PhysicalDisk -CanPool $True

# Create a storage pool with the specified physical disks
$pool = New-StoragePool -FriendlyName "Hyper-V Pool" -StorageSubsystemFriendlyName "Windows Storage*" -PhysicalDisks $PhysicalDisks

# Create a virtual disk in the pool
$virtualDisk = New-VirtualDisk -StoragePoolUniqueId $pool.UniqueId -UseMaximumSize -FriendlyName "Hyper-V Disk" -ResiliencySettingName Simple

# Retrieve the associated disk number for the virtual disk
$virtualDiskNumber = Get-Disk | Where-Object { $_.UniqueId -eq $virtualDisk.UniqueId } | Select-Object -ExpandProperty Number

# Initialize the virtual disk
Initialize-Disk -Number $virtualDiskNumber -PassThru

# Create a partition on the virtual disk
$partition = New-Partition -DiskNumber $virtualDiskNumber -UseMaximumSize

# Assign a drive letter to the partition
Add-PartitionAccessPath -DiskNumber $virtualDiskNumber -PartitionNumber $partition.PartitionNumber -AssignDriveLetter

# Format the partition with NTFS (optional)
$driveLetter = (Get-Partition -DiskNumber $virtualDiskNumber -PartitionNumber $partition.PartitionNumber).DriveLetter
Format-Volume -DriveLetter $driveLetter -FileSystem NTFS -NewFileSystemLabel "Hyper-V" -Confirm:$false

# Import the Deduplication module
Import-Module Deduplication

# Enable Data Deduplication on the newly created volume
Enable-DedupVolume -Volume $driveLetter -UsageType HyperV



#enable Dedup at startup
# Define the task action to run the PowerShell command
$action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument 'Get-ScheduledTask -TaskPath \Microsoft\Windows\Deduplication\* | Start-ScheduledTask'

# Create a trigger for the task (to run at startup)
$trigger = New-ScheduledTaskTrigger -AtStartup

# Register the scheduled task
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "StartupDeduplicationTask" -TaskPath "\CustomTasks\" -User "NT AUTHORITY\SYSTEM" -Force
