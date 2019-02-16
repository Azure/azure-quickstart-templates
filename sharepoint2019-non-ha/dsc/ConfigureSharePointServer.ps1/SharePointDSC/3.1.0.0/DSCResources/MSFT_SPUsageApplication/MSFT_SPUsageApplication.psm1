function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]  
        [System.String] 
        $Name,

        [Parameter()] 
        [ValidateSet("Present","Absent")] 
        [System.String] 
        $Ensure = "Present",

        [Parameter()] 
        [System.Management.Automation.PSCredential] 
        $InstallAccount,

        [Parameter()] 
        [System.String] 
        $DatabaseName,

        [Parameter()] 
        [System.String] 
        $DatabaseServer,

        [Parameter()] 
        [System.Management.Automation.PSCredential] 
        $DatabaseCredentials,

        [Parameter()] 
        [System.String] 
        $FailoverDatabaseServer,

        [Parameter()] 
        [System.UInt32] 
        $UsageLogCutTime,

        [Parameter()] 
        [System.String] 
        $UsageLogLocation,

        [Parameter()] 
        [System.UInt32] 
        $UsageLogMaxFileSizeKB,

        [Parameter()] 
        [System.UInt32] 
        $UsageLogMaxSpaceGB
    )

    Write-Verbose -Message "Getting usage application '$Name'"

    $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                  -Arguments $PSBoundParameters `
                                  -ScriptBlock {
        $params = $args[0]

        $serviceApps = Get-SPServiceApplication -Name $params.Name `
                                                -ErrorAction SilentlyContinue
        $nullReturn = @{
            Name = $params.Name
            Ensure = "Absent"
        } 

        if ($null -eq $serviceApps) 
        {
            return $nullReturn
        }
        $serviceApp = $serviceApps | Where-Object -FilterScript {
            $_.GetType().FullName -eq "Microsoft.SharePoint.Administration.SPUsageApplication"
        }

        if ($null -eq $serviceApp)
        {
            return $nullReturn
        }
        else
        {
            $spUsageApplicationProxy = Get-SPServiceApplicationProxy | Where-Object -FilterScript {
                $_.GetType().FullName -eq "Microsoft.SharePoint.Administration.SPUsageApplicationProxy"
            }
            
            $ensure = "Present"
            if($spUsageApplicationProxy.Status -eq "Disabled") 
            {
                $ensure = "Absent"
            }
            
            $service = Get-SPUsageService
            return @{
                Name = $serviceApp.DisplayName
                InstallAccount = $params.InstallAccount
                DatabaseName = $serviceApp.UsageDatabase.Name
                DatabaseServer = $serviceApp.UsageDatabase.NormalizedDataSource
                DatabaseCredentials = $params.DatabaseCredentials
                FailoverDatabaseServer = $serviceApp.UsageDatabase.FailoverServer
                UsageLogCutTime = $service.UsageLogCutTime
                UsageLogLocation = $service.UsageLogDir
                UsageLogMaxFileSizeKB = $service.UsageLogMaxFileSize / 1024
                UsageLogMaxSpaceGB = $service.UsageLogMaxSpaceGB
                Ensure = $ensure
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
        $Name,

        [Parameter()] 
        [ValidateSet("Present","Absent")] 
        [System.String] 
        $Ensure = "Present",

        [Parameter()] 
        [System.Management.Automation.PSCredential] 
        $InstallAccount,

        [Parameter()] 
        [System.String] 
        $DatabaseName,

        [Parameter()] 
        [System.String] 
        $DatabaseServer,

        [Parameter()] 
        [System.Management.Automation.PSCredential] 
        $DatabaseCredentials,

        [Parameter()] 
        [System.String] 
        $FailoverDatabaseServer,

        [Parameter()] 
        [System.UInt32] 
        $UsageLogCutTime,

        [Parameter()] 
        [System.String] 
        $UsageLogLocation,

        [Parameter()] 
        [System.UInt32] 
        $UsageLogMaxFileSizeKB,

        [Parameter()] 
        [System.UInt32] 
        $UsageLogMaxSpaceGB
    )

    Write-Verbose -Message "Setting usage application $Name"

    $CurrentState = Get-TargetResource @PSBoundParameters

    if ($CurrentState.Ensure -eq "Absent" -and $Ensure -eq "Present") 
    {
        Invoke-SPDSCCommand -Credential $InstallAccount `
                            -Arguments $PSBoundParameters `
                            -ScriptBlock {
            $params = $args[0]
            
            $newParams = @{}
            $newParams.Add("Name", $params.Name)
            if ($params.ContainsKey("DatabaseName")) 
            {
                $newParams.Add("DatabaseName", $params.DatabaseName) 
            }
            if ($params.ContainsKey("DatabaseCredentials")) 
            {
                $params.Add("DatabaseUsername", $params.DatabaseCredentials.Username)
                $params.Add("DatabasePassword", $params.DatabaseCredentials.Password)
            }
            if ($params.ContainsKey("DatabaseServer")) 
            {
                $newParams.Add("DatabaseServer", $params.DatabaseServer) 
            }
            if ($params.ContainsKey("FailoverDatabaseServer")) 
            {
                $newParams.Add("FailoverDatabaseServer", $params.FailoverDatabaseServer) 
            }

            New-SPUsageApplication @newParams
        }
    }

    if ($Ensure -eq "Present") 
    {
        Write-Verbose -Message "Configuring usage application $Name"
        Invoke-SPDSCCommand -Credential $InstallAccount `
                            -Arguments $PSBoundParameters `
                            -ScriptBlock {
            $params = $args[0]
            
            $spUsageApplicationProxy = Get-SPServiceApplicationProxy | Where-Object -FilterScript {
                $_.GetType().FullName -eq "Microsoft.SharePoint.Administration.SPUsageApplicationProxy"
            }
            
            if($spUsageApplicationProxy.Status -eq "Disabled") 
            {
                $spUsageApplicationProxy.Provision()
            }
            
            $setParams = @{}
            $setParams.Add("LoggingEnabled", $true)
            if ($params.ContainsKey("UsageLogCutTime")) 
            {
                $setParams.Add("UsageLogCutTime", $params.UsageLogCutTime) 
            }
            if ($params.ContainsKey("UsageLogLocation")) 
            {
                $setParams.Add("UsageLogLocation", $params.UsageLogLocation) 
            }
            if ($params.ContainsKey("UsageLogMaxFileSizeKB")) 
            {
                $setParams.Add("UsageLogMaxFileSizeKB", $params.UsageLogMaxFileSizeKB) 
            }
            if ($params.ContainsKey("UsageLogMaxSpaceGB")) 
            {
                $setParams.Add("UsageLogMaxSpaceGB", $params.UsageLogMaxSpaceGB) 
            }
            Set-SPUsageService @setParams
        }    
    }
    
    if ($Ensure -eq "Absent") 
    {
        Write-Verbose -Message "Removing usage application $Name"
        Invoke-SPDSCCommand -Credential $InstallAccount `
                            -Arguments $PSBoundParameters `
                            -ScriptBlock {
            $params = $args[0]
            
            $service = Get-SPServiceApplication -Name $params.Name `
                    | Where-Object -FilterScript {
                        $_.GetType().FullName -eq "Microsoft.SharePoint.Administration.SPUsageApplication"
                    }
            Remove-SPServiceApplication $service -Confirm:$false
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
        $Name,

        [Parameter()] 
        [ValidateSet("Present","Absent")] 
        [System.String] 
        $Ensure = "Present",

        [Parameter()] 
        [System.Management.Automation.PSCredential] 
        $InstallAccount,

        [Parameter()] 
        [System.String] 
        $DatabaseName,

        [Parameter()] 
        [System.String] 
        $DatabaseServer,

        [Parameter()] 
        [System.Management.Automation.PSCredential] 
        $DatabaseCredentials,

        [Parameter()] 
        [System.String] 
        $FailoverDatabaseServer,

        [Parameter()] 
        [System.UInt32] 
        $UsageLogCutTime,

        [Parameter()] 
        [System.String] 
        $UsageLogLocation,

        [Parameter()] 
        [System.UInt32] 
        $UsageLogMaxFileSizeKB,

        [Parameter()] 
        [System.UInt32] 
        $UsageLogMaxSpaceGB
    )

    Write-Verbose -Message "Testing for usage application '$Name'"

    $PSBoundParameters.Ensure = $Ensure

    $CurrentValues = Get-TargetResource @PSBoundParameters

    if ($Ensure -eq "Present") 
    {
        return Test-SPDscParameterState -CurrentValues $CurrentValues `
                                        -DesiredValues $PSBoundParameters `
                                        -ValuesToCheck @("UsageLogCutTime", 
                                                         "UsageLogLocation", 
                                                         "UsageLogMaxFileSizeKB", 
                                                         "UsageLogMaxSpaceGB", 
                                                         "Ensure")
    } 
    else 
    {
        return Test-SPDscParameterState -CurrentValues $CurrentValues `
                                        -DesiredValues $PSBoundParameters `
                                        -ValuesToCheck @("Ensure")
    }
}

Export-ModuleMember -Function *-TargetResource
