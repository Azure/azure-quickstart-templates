# Install Chocolatey package manager
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco source add -n=ros-win -s="https://aka.ms/ros/public" --priority=1

# Install ROS1 - Melodic
choco upgrade ros-melodic-desktop_full -y --execution-timeout=0 -i

# Install ROS1 - Noetic
choco upgrade ros-noetic-desktop_full -y --execution-timeout=0 -i

# Install ROS2
choco upgrade ros-foxy-desktop -y --execution-timeout=0 -i

# finally enable RemotePS 
Enable-PSRemoting -Force -SkipNetworkProfileCheck
New-NetFirewallRule -Name "Allow WinRM HTTPS" -DisplayName "WinRM HTTPS" -Enabled True -Profile Any -Action Allow -Direction Inbound -LocalPort 5986 -Protocol TCP
$thumbprint = (New-SelfSignedCertificate -DnsName $env:COMPUTERNAME -CertStoreLocation Cert:\LocalMachine\My).Thumbprint
$command = "winrm create winrm/config/Listener?Address=*+Transport=HTTPS @{Hostname=""$env:computername""; CertificateThumbprint=""$thumbprint""}"
cmd.exe /C $command

# adding telemetry footprint
$localDeviceIdPath = "HKLM:SOFTWARE\Microsoft\SQMClient"
$localDeviceIdName = "MachineId"
$localDeviceIdValue = "{df713376-9b62-46d6-a363-cede5b1bf2c5}"
New-ItemProperty -Path $localDeviceIdPath -Name $localDeviceIdName -Value $localDeviceIdValue -PropertyType String -Force | Out-Null
