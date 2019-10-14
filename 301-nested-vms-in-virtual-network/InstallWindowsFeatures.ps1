Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module Subnet -Force
Install-WindowsFeature -Name Hyper-V,DHCP,RemoteAccess,Routing -IncludeManagementTools -Restart