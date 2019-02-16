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
        [System.String]
        $ProjectProfessionalMinBuildNumber,

        [Parameter()]  
        [System.String]
        $ServerCurrency,

        [Parameter()]  
        [System.Boolean]
        $EnforceServerCurrency,

        [Parameter()] 
        [System.Management.Automation.PSCredential] 
        $InstallAccount
    )

    Write-Verbose -Message "Getting additional settings for $Url"

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

        $script:ProjectProfessionalMinBuildNumberValue = $null
        $script:ServerCurrencyValue = $null
        $script:EnforceServerCurrencyValue = $false
        Use-SPDscProjectServerWebService -Service $adminService -ScriptBlock {
            $buildInfo = $adminService.GetProjectProfessionalMinimumBuildNumbers().Versions
            $script:ProjectProfessionalMinBuildNumberValue = "$($buildInfo.Major).$($buildInfo.Minor).$($buildInfo.Build).$($buildInfo.Revision)"
            $script:ServerCurrencyValue = $adminService.GetServerCurrency()
            $script:EnforceServerCurrencyValue = $adminService.GetSingleCurrencyEnforced()
        }

        return @{
            Url = $params.Url
            ProjectProfessionalMinBuildNumber = $script:ProjectProfessionalMinBuildNumberValue
            ServerCurrency = $script:ServerCurrencyValue
            EnforceServerCurrency = $script:EnforceServerCurrencyValue
            InstallAccount = $params.InstallAccount
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
        [System.String]
        $ProjectProfessionalMinBuildNumber,

        [Parameter()]  
        [System.String]
        $ServerCurrency,
        
        [Parameter()]  
        [System.Boolean]
        $EnforceServerCurrency,

        [Parameter()] 
        [System.Management.Automation.PSCredential] 
        $InstallAccount
    )

    Write-Verbose -Message "Setting additional settings for $Url"

    if ((Get-SPDSCInstalledProductVersion).FileMajorPart -lt 16) 
    {
        throw [Exception] ("Support for Project Server in SharePointDsc is only valid for " + `
                           "SharePoint 2016 and 2019.")
    }

    Invoke-SPDSCCommand -Credential $InstallAccount `
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

        Use-SPDscProjectServerWebService -Service $adminService -ScriptBlock {
            if ($params.ContainsKey("ProjectProfessionalMinBuildNumber") -eq $true)
            {
                $buildInfo = $adminService.GetProjectProfessionalMinimumBuildNumbers()
                $versionInfo = [System.Version]::New($params.ProjectProfessionalMinBuildNumber)
                $buildInfo.Versions.Rows[0]["Major"] = $versionInfo.Major
                $buildInfo.Versions.Rows[0]["Minor"] = $versionInfo.Minor
                $buildInfo.Versions.Rows[0]["Build"] = $versionInfo.Build
                $buildInfo.Versions.Rows[0]["Revision"] = $versionInfo.Revision
                $adminService.SetProjectProfessionalMinimumBuildNumbers($buildInfo)
            }

            if ($params.ContainsKey("ServerCurrency") -eq $true)
            {
                $adminService.SetServerCurrency($params.ServerCurrency)
            }

            if ($params.ContainsKey("EnforceServerCurrency") -eq $true)
            {
                $adminService.SetSingleCurrencyEnforced($params.EnforceServerCurrency)
            }
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
        [System.String]
        $ProjectProfessionalMinBuildNumber,

        [Parameter()]  
        [System.String]
        $ServerCurrency,

        [Parameter()]  
        [System.Boolean]
        $EnforceServerCurrency,

        [Parameter()] 
        [System.Management.Automation.PSCredential] 
        $InstallAccount
    )

    Write-Verbose -Message "Testing additional settings for $Url"

    $currentValues = Get-TargetResource @PSBoundParameters

    return Test-SPDscParameterState -CurrentValues $CurrentValues `
                                    -DesiredValues $PSBoundParameters `
                                    -ValuesToCheck @(
                                        "ProjectProfessionalMinBuildNumber"
                                        "ServerCurrency",
                                        "EnforceServerCurrency"
                                    )
}

Export-ModuleMember -Function *-TargetResource
