
$DockerConfig = 'C:\programdata\docker\runDockerDaemon.cmd'

#Set RDP and Docker Firewall Rules:
if (!(Get-NetFirewallRule | where {$_.Name -eq "HTTP"})) {
    New-NetFirewallRule -Name "HTTP" -DisplayName "HTTP" -Protocol tcp -LocalPort 80 -Action Allow -Enabled True
}

if (!(Get-NetFirewallRule | where {$_.Name -eq "Docker"})) {
    New-NetFirewallRule -Name "Docker" -DisplayName "Docker" -Protocol tcp -LocalPort 2375 -Action Allow -Enabled True
}

#Modify Docker Daemon Configuration
if (!($file = Get-Item -Path $DockerConfig)) {
    Write-Verbose "Docker Daemon Command File Missing" -Verbose
}
else {
    $file = Get-Content $DockerConfig
    $file = $file -replace '^docker daemon -D -b "Virtual Switch"$','docker daemon -D -b "Virtual Switch" -H 0.0.0.0:2375'
    Set-Content -Path $DockerConfig -Value $file
}

#Restart Docker Service
Restart-Service Docker