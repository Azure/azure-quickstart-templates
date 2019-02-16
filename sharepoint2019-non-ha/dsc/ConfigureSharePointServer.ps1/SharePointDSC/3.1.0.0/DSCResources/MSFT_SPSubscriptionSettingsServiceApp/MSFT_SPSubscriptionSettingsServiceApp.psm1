function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]  
        [System.String] 
        $Name,

        [Parameter(Mandatory = $true)]  
        [System.String] 
        $ApplicationPool,

        [Parameter()]
        [System.String] 
        $DatabaseName,

        [Parameter()]
        [System.String] 
        $DatabaseServer,

        [Parameter()]
        [ValidateSet("Present","Absent")] 
        [System.String] 
        $Ensure = "Present",

        [Parameter()]
        [System.Management.Automation.PSCredential] 
        $InstallAccount
    )

    Write-Verbose -Message "Getting Subscription Settings Service '$Name'"

    $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                  -Arguments $PSBoundParameters `
                                  -ScriptBlock {
        $params = $args[0]
        
        $serviceApps = Get-SPServiceApplication -Name $params.Name `
                                                -ErrorAction SilentlyContinue 
        $nullReturn = @{
            Name = $params.Name
            ApplicationPool = $params.ApplicationPool
            Ensure = "Absent"
        }

        if ($null -eq $serviceApps) 
        {
            return $nullReturn
        }
        $serviceApp = $serviceApps | Where-Object -FilterScript {
            $_.GetType().FullName -eq "Microsoft.SharePoint.SPSubscriptionSettingsServiceApplication"
        }

        if ($null -eq $serviceApp) 
        {
            return $nullReturn
        } 
        else 
        {
            $propertyFlags = [System.Reflection.BindingFlags]::Instance `
                                -bor [System.Reflection.BindingFlags]::NonPublic

            $propData = $serviceApp.GetType().GetProperties($propertyFlags)

            $dbProp = $propData | Where-Object -FilterScript {
                $_.Name -eq "Database"
            }

            $db = $dbProp.GetValue($serviceApp)

            return  @{
                Name = $serviceApp.DisplayName
                ApplicationPool = $serviceApp.ApplicationPool.Name
                DatabaseName = $db.Name
                DatabaseServer = $db.NormalizedDataSource
                InstallAccount = $params.InstallAccount
                Ensure = "Present"
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

        [Parameter(Mandatory = $true)]  
        [System.String] 
        $ApplicationPool,

        [Parameter()]
        [System.String] 
        $DatabaseName,

        [Parameter()]
        [System.String] 
        $DatabaseServer,

        [Parameter()]
        [ValidateSet("Present","Absent")] 
        [System.String] 
        $Ensure = "Present",

        [Parameter()]
        [System.Management.Automation.PSCredential] 
        $InstallAccount
    )

    Write-Verbose -Message "Setting Subscription Settings Service '$Name'"

    $result = Get-TargetResource @PSBoundParameters

    if ($result.Ensure -eq "Absent" -and $Ensure -eq "Present") 
    {
        Write-Verbose -Message "Creating Subscription Settings Service Application $Name"
        Invoke-SPDSCCommand -Credential $InstallAccount `
                            -Arguments $PSBoundParameters `
                            -ScriptBlock {
            $params = $args[0]
            
            $newParams = @{
                Name = $params.Name 
                ApplicationPool = $params.ApplicationPool
            }
            if ($params.ContainsKey("DatabaseName") -eq $true) 
            {
                $newParams.Add("DatabaseName", $params.DatabaseName) 
            }
            if ($params.ContainsKey("DatabaseServer") -eq $true) 
            {
                $newParams.Add("DatabaseServer", $params.DatabaseServer) 
            }
            $serviceApp = New-SPSubscriptionSettingsServiceApplication @newParams
            New-SPSubscriptionSettingsServiceApplicationProxy -ServiceApplication $serviceApp | Out-Null 
        }
    }
    if ($result.Ensure -eq "Present" -and $Ensure -eq "Present") 
    {
        if ($ApplicationPool -ne $result.ApplicationPool) 
        {
            Write-Verbose -Message "Updating Subscription Settings Service Application $Name"
            Invoke-SPDSCCommand -Credential $InstallAccount `
                                -Arguments $PSBoundParameters `
                                -ScriptBlock {

                $params = $args[0]
                $appPool = Get-SPServiceApplicationPool -Identity $params.ApplicationPool
                $service = Get-SPServiceApplication -Name $params.Name `
                    | Where-Object -FilterScript {
                        $_.GetType().FullName -eq "Microsoft.SharePoint.SPSubscriptionSettingsServiceApplication" 
                    } 
                $service.ApplicationPool = $appPool
                $service.Update()
            }
        }
    }
    if ($Ensure -eq "Absent") 
    {
        Write-Verbose -Message "Removing Subscription Settings Service Application $Name"
        Invoke-SPDSCCommand -Credential $InstallAccount `
                            -Arguments $PSBoundParameters `
                            -ScriptBlock {
            $params = $args[0]
            
            $service = Get-SPServiceApplication -Name $params.Name `
                    | Where-Object -FilterScript {
                        $_.GetType().FullName -eq "Microsoft.SharePoint.SPSubscriptionSettingsServiceApplication" 
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

        [Parameter(Mandatory = $true)]  
        [System.String] 
        $ApplicationPool,

        [Parameter()]
        [System.String] 
        $DatabaseName,

        [Parameter()]
        [System.String] 
        $DatabaseServer,

        [Parameter()]
        [ValidateSet("Present","Absent")] 
        [System.String] 
        $Ensure = "Present",

        [Parameter()]
        [System.Management.Automation.PSCredential] 
        $InstallAccount
    )
    
    Write-Verbose -Message "Testing Subscription Settings Service '$Name'"

    $PSBoundParameters.Ensure = $Ensure
    
    $CurrentValues = Get-TargetResource @PSBoundParameters

    if ($Ensure -eq "Present") 
    {
        return Test-SPDscParameterState -CurrentValues $CurrentValues `
                                        -DesiredValues $PSBoundParameters `
                                        -ValuesToCheck @("ApplicationPool", "Ensure")    
    } 
    else 
    {
        return Test-SPDscParameterState -CurrentValues $CurrentValues `
                                        -DesiredValues $PSBoundParameters `
                                        -ValuesToCheck @("Ensure")
    }
}

Export-ModuleMember -Function *-TargetResource
