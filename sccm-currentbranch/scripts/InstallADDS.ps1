Param($DomainFullName,$Password)

Function TestADDSForeastInstall ($DomainFullName)
{
    $pwd = ConvertTo-SecureString -string $password -AsPlainText -Force
    $Result = Test-ADDSForestInstallation -DomainName $DomainFullName -SafeModeAdministratorPassword $pwd
    return $Result.Status
}

Function InstallADDSForest($DomainFullName)
{
    $NetBIOSName = $DomainFullName.split('.')[0]
    $pass = ConvertTo-SecureString -string $password -AsPlainText -Force
    Import-Module ADDSDeployment
    Install-ADDSForest -SafeModeAdministratorPassword $pass `
        -CreateDnsDelegation:$false `
        -DatabasePath "C:\Windows\NTDS" `
        -DomainName $DomainFullName `
        -DomainNetbiosName $NetBIOSName `
        -LogPath "C:\Windows\NTDS" `
        -InstallDNS:$true `
        -NoRebootOnCompletion:$true `
        -SysvolPath "C:\Windows\SYSVOL" `
        -Force:$true
}
$ProvisionToolPath = "$env:windir\temp\ProvisionScript"
if(!(Test-Path $ProvisionToolPath))
{
    New-Item $ProvisionToolPath -ItemType directory | Out-Null
}
$logpath = $ProvisionToolPath+"\InstallADDSlog.txt"

try
{
    $ADInstallState = Get-WindowsFeature AD-Domain-Services
}
catch
{
    Start-sleep -s 30
    $ADInstallState = Get-WindowsFeature AD-Domain-Services
}
   

if(!$ADInstallState.Installed)
{
    "[$(Get-Date -format HH:mm:ss)] AD have net installed yet" | Out-File -Append $logpath
    "[$(Get-Date -format HH:mm:ss)] Check Ad Install State..." | Out-File -Append $logpath
    if($ADInstallState.InstallState -eq 'Available')
    {
        "[$(Get-Date -format HH:mm:ss)] Check Ad Install State is Available" | Out-File -Append $logpath
        $Feature = Install-WindowsFeature -Name AD-Domain-Services -IncludeAllSubFeature -IncludeManagementTools 
        if($Feature.ExitCode -eq 'Success')
        {
            if(TestADDSForeastInstall -DomainFullName $DomainFullName -eq "Success")
            { 
                InstallADDSForest -DomainFullName $DomainFullName
            }
        }
    }
    else
    {
        "[$(Get-Date -format HH:mm:ss)] Cannot install AD now" | Out-File -Append $logpath
    }
}
else
{
    "[$(Get-Date -format HH:mm:ss)] AD have already installed" | Out-File -Append $logpath
    if(TestADDSForeastInstall -DomainFullName $DomainFullName -eq "Success")
    { 
        $result = InstallADDSForest -DomainFullName $DomainFullName
    }
}