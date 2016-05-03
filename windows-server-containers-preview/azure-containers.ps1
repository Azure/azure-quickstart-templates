<#
.SYNOPSIS
Installs Windows container role, Windows Server Core image, and Docker on an Azure Virtual Machine. Because the virtual machine requires a reboot, a scheduled task is created for post re-boot configuration.

.DESCRIPTION
Installs Windows container role, Windows Server Core image, and Docker on an Azure Virtual Machine. Because the virtual machine requires a reboot, a scheduled task is created for post re-boot configuration.

.PARAMETER adminUser
Administrative user name consumed from Azure Resource Manager template. This ensures that the post-reboot script runs under the context of the admin use, and thus is visible when this account is used to log into the virtual machine.

.EXAMPLE
azure-container.ps1 -admin azureuser
#>

param (
[string]$adminUser
)

# Script body for post reboot execution.

function install-script {
    "   
    # TP5 Contianer Installation`r
    # Install Windows Server Core Image`r`n
    Install-PackageProvider ContainerImage -Force`r
    Install-ContainerImage -Name WindowsServerCore`r`n    
    # Install Docker daemon and client`r`n
    Invoke-WebRequest https://aka.ms/tp5/Update-Container-Host -OutFile update-containerhost.ps1`r
    .\update-containerhost.ps1`r
    docker tag windowsservercore:10.0.14300.1000 windowsservercore:latest`r`n
    # Remove Scheduled Task`r`n
    schtasks /DELETE /TN scriptcontianers /F"
}

Install-Script > c:\windos-containers.ps1

# Create scheduled task.

$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoExit c:\windos-containers.ps1"
$trigger = New-ScheduledTaskTrigger -AtLogOn
Register-ScheduledTask -TaskName "scriptcontianers" -Action $action -Trigger $trigger -RunLevel Highest -User $adminUser | Out-Null

# Install container role

Install-WindowsFeature containers
Restart-Computer -Force      
