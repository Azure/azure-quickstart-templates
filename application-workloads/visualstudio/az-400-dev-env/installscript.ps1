param (
    $UserName  
)
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux  -NoRestart
Enable-WindowsOptionalFeature -Online -FeatureName Containers -All -NoRestart

Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

New-LocalGroup -Name docker-users -Description "Users of Docker Desktop"
Add-LocalGroupMember -Group 'docker-users' -Member $UserName

# removed packages VS Code and Git which were included in base-image !
# Included a new tool "DBeaver" : A universal sql-client
# Included a new tool "MobaXTerm" : A multi-tabbed SSH client with embedded X-Server
choco install wsl-ubuntu-2204 docker-desktop dbeaver mobaxterm azure-cli choco install -y

$trig = New-ScheduledTaskTrigger -AtLogOn 
$task = New-ScheduledTaskAction -Execute "C:\Program Files\Docker\Docker\Docker Desktop.exe" 
Register-ScheduledTask -TaskName start-docker -Force -Action $task -Trigger $trig -User $UserName

#Trigger a restart to enable hyper-v and containers
Restart-Computer -Force
