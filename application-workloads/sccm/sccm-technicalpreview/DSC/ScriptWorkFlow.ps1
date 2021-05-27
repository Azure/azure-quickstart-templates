Param($DomainFullName,$CM,$CMUser,$DPMPName,$ClientName)

$Role = "PS1"
$ProvisionToolPath = "$env:windir\temp\ProvisionScript"
if(!(Test-Path $ProvisionToolPath))
{
    New-Item $ProvisionToolPath -ItemType directory | Out-Null
}

$ConfigurationFile = Join-Path -Path $ProvisionToolPath -ChildPath "$Role.json"

if (Test-Path -Path $ConfigurationFile) 
{
    $Configuration = Get-Content -Path $ConfigurationFile | ConvertFrom-Json
} 
else 
{
    if($ClientName -eq 'Empty')
    {
        [hashtable]$Actions = @{
            InstallSCCM = @{
                Status = 'NotStart'
                StartTime = ''
                EndTime = ''
            }
            UpgradeSCCM = @{
                Status = 'NotStart'
                StartTime = ''
                EndTime = ''
            }
            InstallDP = @{
                Status = 'NotStart'
                StartTime = ''
                EndTime = ''
            }
            InstallMP = @{
                Status = 'NotStart'
                StartTime = ''
                EndTime = ''
            }
        }
    }
    else
    {
        [hashtable]$Actions = @{
            InstallSCCM = @{
                Status = 'NotStart'
                StartTime = ''
                EndTime = ''
            }
            UpgradeSCCM = @{
                Status = 'NotStart'
                StartTime = ''
                EndTime = ''
            }
            InstallDP = @{
                Status = 'NotStart'
                StartTime = ''
                EndTime = ''
            }
            InstallMP = @{
                Status = 'NotStart'
                StartTime = ''
                EndTime = ''
            }
            InstallClient = @{
                Status = 'NotStart'
                StartTime = ''
                EndTime = ''
            }
        }
    }
    $Configuration = New-Object -TypeName psobject -Property $Actions
    $Configuration | ConvertTo-Json | Out-File -FilePath $ConfigurationFile -Force
}

#Install CM and Config
$ScriptFile = Join-Path -Path $ProvisionToolPath -ChildPath "InstallAndUpdateSCCM.ps1"

. $ScriptFile $DomainFullName $CM $CMUser $Role $ProvisionToolPath

#Install DP
$ScriptFile = Join-Path -Path $ProvisionToolPath -ChildPath "InstallDP.ps1"

. $ScriptFile $DomainFullName $DPMPName $Role $ProvisionToolPath

#Install MP
$ScriptFile = Join-Path -Path $ProvisionToolPath -ChildPath "InstallMP.ps1"

. $ScriptFile $DomainFullName $DPMPName $Role $ProvisionToolPath

if($ClientName -ne 'Empty')
{
    #Install Client
    $ScriptFile = Join-Path -Path $ProvisionToolPath -ChildPath "InstallClient.ps1"

    . $ScriptFile $DomainFullName $CMUser $ClientName $DPMPName $Role $ProvisionToolPath
}
