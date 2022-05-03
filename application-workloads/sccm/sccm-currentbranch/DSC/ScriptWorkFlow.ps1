Param($DomainFullName,$CM,$CMUser,$DPMPName,$ClientName,$Config,$CurrentRole,$LogFolder,$CSName,$PSName)

$CSRole = "CAS"
$PSRole = "PS1"

$Role = $PSRole
if($CurrentRole -eq "CS")
{
    $Role = $CSRole
}
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
    if($Config -eq "Standalone")
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
    else 
    {
        if($CurrentRole -eq "CS")
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
                PSReadytoUse = @{
                    Status = 'NotStart'
                    StartTime = ''
                    EndTime = ''
                }
            }
        }
        elseif($CurrentRole -eq "PS") 
        {
            [hashtable]$Actions = @{
                WaitingForCASFinsihedInstall = @{
                    Status = 'NotStart'
                    StartTime = ''
                    EndTime = ''
                }
                InstallSCCM = @{
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
    }
    $Configuration = New-Object -TypeName psobject -Property $Actions
    $Configuration | ConvertTo-Json | Out-File -FilePath $ConfigurationFile -Force
}

if($Config -eq "Standalone")
{
    #Install CM and Config
    $ScriptFile = Join-Path -Path $ProvisionToolPath -ChildPath "InstallAndUpdateSCCM.ps1"

    . $ScriptFile $DomainFullName $CM $CMUser $Role $ProvisionToolPath

    #Install DP
    $ScriptFile = Join-Path -Path $ProvisionToolPath -ChildPath "InstallDP.ps1"

    . $ScriptFile $DomainFullName $DPMPName $Role $ProvisionToolPath

    #Install MP
    $ScriptFile = Join-Path -Path $ProvisionToolPath -ChildPath "InstallMP.ps1"

    . $ScriptFile $DomainFullName $DPMPName $Role $ProvisionToolPath

    #Install Client
    $ScriptFile = Join-Path -Path $ProvisionToolPath -ChildPath "InstallClient.ps1"

    . $ScriptFile $DomainFullName $CMUser $ClientName $DPMPName $Role $ProvisionToolPath
}
else {
    if($CurrentRole -eq "CS")
    {
        #Install CM and Config
        $ScriptFile = Join-Path -Path $ProvisionToolPath -ChildPath "InstallCSForHierarchy.ps1"
    
        . $ScriptFile $DomainFullName $CM $CMUser $Role $ProvisionToolPath $LogFolder $PSName $PSRole

    }
    elseif($CurrentRole -eq "PS")
    {
        #Install CM and Config
        $ScriptFile = Join-Path -Path $ProvisionToolPath -ChildPath "InstallPSForHierarchy.ps1"
    
        . $ScriptFile $DomainFullName $CM $CMUser $Role $ProvisionToolPath $CSName $CSRole $LogFolder
    
        #Install DP
        $ScriptFile = Join-Path -Path $ProvisionToolPath -ChildPath "InstallDP.ps1"
    
        . $ScriptFile $DomainFullName $DPMPName $Role $ProvisionToolPath
    
        #Install MP
        $ScriptFile = Join-Path -Path $ProvisionToolPath -ChildPath "InstallMP.ps1"
    
        . $ScriptFile $DomainFullName $DPMPName $Role $ProvisionToolPath

        #Install Client
        $ScriptFile = Join-Path -Path $ProvisionToolPath -ChildPath "InstallClient.ps1"

        . $ScriptFile $DomainFullName $CMUser $ClientName $DPMPName $Role $ProvisionToolPath
    }
}