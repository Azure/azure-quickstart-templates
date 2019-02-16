function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]  
        [System.String] 
        $Url,
        
        [Parameter()]  
        [System.String[]] 
        $GroupNames,

        [Parameter()] 
        [ValidateSet("Present","Absent")] 
        [System.String] 
        $Ensure = "Present",

        [Parameter()]  
        [System.Boolean] 
        $AutoReactivateUsers = $false,

        [Parameter()] 
        [System.Management.Automation.PSCredential] 
        $InstallAccount
    )

    Write-Verbose -Message "Getting AD Resource Pool Sync settings for $Url"

    if ((Get-SPDSCInstalledProductVersion).FileMajorPart -lt 16) 
    {
        throw [Exception] ("Support for Project Server in SharePointDsc is only valid for " + `
                           "SharePoint 2016 and 2019.")
    }

    $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                  -Arguments @($PSBoundParameters, $PSScriptRoot) `
                                  -ScriptBlock {
        $params = $args[0]
        $scriptRoot = $args[1]
        
        $modulePath = "..\..\Modules\SharePointDsc.ProjectServer\ProjectServerConnector.psm1"
        Import-Module -Name (Join-Path -Path $scriptRoot -ChildPath $modulePath -Resolve)

        $webAppUrl = (Get-SPSite -Identity $params.Url).WebApplication.Url
        $useKerberos = -not (Get-SPAuthenticationProvider -WebApplication $webAppUrl -Zone Default).DisableKerberos
        $adminService = New-SPDscProjectServerWebService -PwaUrl $params.Url `
                                                         -EndpointName Admin `
                                                         -UseKerberos:$useKerberos

        $script:currentSettings = $null
        $script:reactivateUsers = $false
        Use-SPDscProjectServerWebService -Service $adminService -ScriptBlock {
            $script:currentSettings = $adminService.GetActiveDirectorySyncEnterpriseResourcePoolSettings2()
            $secondSettings = $adminService.GetActiveDirectorySyncEnterpriseResourcePoolSettings()
            $script:reactivateUsers = $secondSettings.AutoReactivateInactiveUsers
        }

        if ($null -eq $script:currentSettings)
        {
            return @{
                Url = $params.Url
                GroupNames = @()
                Ensure = "Absent"
                AutoReactivateUsers = $false
                InstallAccount = $params.InstallAccount
            }
        }
        else
        {
            if ($null -eq $script:currentSettings.ADGroupGuids -or $script:currentSettings.ADGroupGuids.Length -lt 1)
            {
                return @{
                    Url = $params.Url
                    GroupNames = @()
                    Ensure = "Absent"
                    AutoReactivateUsers = $script:reactivateUsers
                    InstallAccount = $params.InstallAccount
                }
            }
            else 
            {
                $adGroups = @()
                $script:currentSettings.ADGroupGuids | ForEach-Object -Process {
                    $groupName = Convert-SPDscADGroupIDToName -GroupID $_
                    $adGroups += $groupName
                }

                return @{
                    Url = $params.Url
                    GroupNames = $adGroups
                    Ensure = "Present"
                    AutoReactivateUsers = $script:reactivateUsers
                    InstallAccount = $params.InstallAccount
                }
            }
        }
    }
    return $result
}


function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]  
        [System.String] 
        $Url,
        
        [Parameter()]  
        [System.String[]] 
        $GroupNames,

        [Parameter()] 
        [ValidateSet("Present","Absent")] 
        [System.String] 
        $Ensure = "Present",

        [Parameter()]  
        [System.Boolean] 
        $AutoReactivateUsers = $false,

        [Parameter()] 
        [System.Management.Automation.PSCredential] 
        $InstallAccount
    )

    Write-Verbose -Message "Setting AD Resource Pool Sync settings for $Url"

    if ((Get-SPDSCInstalledProductVersion).FileMajorPart -lt 16) 
    {
        throw [Exception] ("Support for Project Server in SharePointDsc is only valid for " + `
                           "SharePoint 2016 and 2019.")
    }

    if ($Ensure -eq "Present")
    {
        Invoke-SPDSCCommand -Credential $InstallAccount `
                            -Arguments $PSBoundParameters `
                            -ScriptBlock {

            $params = $args[0]

            $groupIDs = New-Object -TypeName "System.Collections.Generic.List[System.Guid]"

            $params.GroupNames | ForEach-Object -Process {
                $groupName = Convert-SPDscADGroupNameToID -GroupName $_
                $groupIDs.Add($groupName)
            }
            
            Enable-SPProjectActiveDirectoryEnterpriseResourcePoolSync -Url $params.Url `
                                                                      -GroupUids $groupIDs.ToArray()

            if ($params.ContainsKey("AutoReactivateUsers") -eq $true)
            {
                $webAppUrl = (Get-SPSite -Identity $params.Url).WebApplication.Url
                $useKerberos = -not (Get-SPAuthenticationProvider -WebApplication $webAppUrl -Zone Default).DisableKerberos
                $adminService = New-SPDscProjectServerWebService -PwaUrl $params.Url `
                                                                 -EndpointName Admin `
                                                                 -UseKerberos:$useKerberos

                Use-SPDscProjectServerWebService -Service $adminService -ScriptBlock {
                    $settings = $adminService.GetActiveDirectorySyncEnterpriseResourcePoolSettings()
                    $settings.AutoReactivateInactiveUsers  = $params.AutoReactivateUsers
                    $adminService.SetActiveDirectorySyncEnterpriseResourcePoolSettings($settings)
                }
            }
        }
    }
    else
    {
        Invoke-SPDSCCommand -Credential $InstallAccount `
                            -Arguments $PSBoundParameters `
                            -ScriptBlock {

            $params = $args[0]

            Disable-SPProjectActiveDirectoryEnterpriseResourcePoolSync -Url $params.Url
        }
    }
}


function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]  
        [System.String] 
        $Url,
        
        [Parameter()]  
        [System.String[]] 
        $GroupNames,

        [Parameter()] 
        [ValidateSet("Present","Absent")] 
        [System.String] 
        $Ensure = "Present",

        [Parameter()]  
        [System.Boolean] 
        $AutoReactivateUsers = $false,

        [Parameter()] 
        [System.Management.Automation.PSCredential] 
        $InstallAccount
    )

    Write-Verbose -Message "Testing AD Resource Pool Sync settings for $Url"

    $currentValues = Get-TargetResource @PSBoundParameters

    $PSBoundParameters.Ensure = $Ensure

    $paramsToCheck = @("Ensure")
    
    if ($Ensure -eq "Present")
    {
        $paramsToCheck += "GroupNames"
        if ($PSBoundParameters.ContainsKey("AutoReactivateUsers") -eq $true)
        {
            $paramsToCheck += "AutoReactivateUsers"
        }
    }

    return Test-SPDscParameterState -CurrentValues $CurrentValues `
                                    -DesiredValues $PSBoundParameters `
                                    -ValuesToCheck $paramsToCheck
}

Export-ModuleMember -Function *-TargetResource
