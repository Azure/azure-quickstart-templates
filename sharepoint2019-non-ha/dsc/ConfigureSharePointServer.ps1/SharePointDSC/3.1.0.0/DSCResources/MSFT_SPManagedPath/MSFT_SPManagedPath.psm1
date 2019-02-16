function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]  
        [System.String]  
        $WebAppUrl,
        
        [Parameter(Mandatory = $true)]  
        [System.String]  
        $RelativeUrl,

        [Parameter(Mandatory = $true)]  
        [System.Boolean] 
        $Explicit,

        [Parameter(Mandatory = $true)]  
        [System.Boolean] 
        $HostHeader,

        [Parameter()] 
        [ValidateSet("Present","Absent")] 
        [System.String] 
        $Ensure = "Present",
        
        [Parameter()] 
        [System.Management.Automation.PSCredential] 
        $InstallAccount
    )

    Write-Verbose -Message "Getting managed path $RelativeUrl in $WebAppUrl"

    $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                  -Arguments $PSBoundParameters `
                                  -ScriptBlock {
        $params = $args[0]

        $getParams = @{
            Identity = $params.RelativeUrl 
        }
        if ($params.HostHeader) 
        {
            $getParams.Add("HostHeader", $true)
        } 
        else 
        {
            $getParams.Add("WebApplication", $params.WebAppUrl)
        }
        $path = Get-SPManagedPath @getParams -ErrorAction SilentlyContinue
        if ($null -eq $path) 
        {
            return @{
                WebAppUrl      = $params.WebAppUrl
                RelativeUrl    = $params.RelativeUrl
                Explicit       = $params.Explicit
                HostHeader     = $params.HostHeader
                InstallAccount = $params.InstallAccount
                Ensure         = "Absent" 
            } 
        }
        
        return @{
            RelativeUrl    = $path.Name
            Explicit       = ($path.Type -eq "ExplicitInclusion")
            WebAppUrl      = $params.WebAppUrl
            HostHeader     = $params.HostHeader
            InstallAccount = $params.InstallAccount
            Ensure         = "Present"
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
        $WebAppUrl,
        
        [Parameter(Mandatory = $true)]  
        [System.String]  
        $RelativeUrl,

        [Parameter(Mandatory = $true)]  
        [System.Boolean] 
        $Explicit,

        [Parameter(Mandatory = $true)]  
        [System.Boolean] 
        $HostHeader,

        [Parameter()] 
        [ValidateSet("Present","Absent")] 
        [System.String] 
        $Ensure = "Present",
        
        [Parameter()] 
        [System.Management.Automation.PSCredential] 
        $InstallAccount
    )

    Write-Verbose -Message "Setting managed path $RelativeUrl in $WebAppUrl"

    $CurrentResults = Get-TargetResource @PSBoundParameters

    if ($CurrentResults.Ensure -eq "Absent" -and $Ensure -eq "Present") 
    {
        Write-Verbose -Message "Creating the managed path $RelativeUrl in $WebAppUrl"
        Invoke-SPDSCCommand -Credential $InstallAccount `
                            -Arguments $PSBoundParameters `
                            -ScriptBlock {
            $params = $args[0]

            $newParams = @{
                RelativeURL = $params.RelativeUrl
                Explicit = $params.Explicit
            }
            if ($params.HostHeader) 
            {
                $newParams.Add("HostHeader", $params.HostHeader)
            }
            else 
            {
                $newParams.Add("WebApplication", $params.WebAppUrl)
            }
            New-SPManagedPath @newParams
        }
    }
    
    if ($Ensure -eq "Absent") 
    {
        Write-Verbose -Message "Removing the managed path $RelativeUrl from $WebAppUrl"
        Invoke-SPDSCCommand -Credential $InstallAccount `
                            -Arguments $PSBoundParameters `
                            -ScriptBlock {
            $params = $args[0]

            $removeParams = @{
                Identity = $params.RelativeUrl
            }
            if ($params.HostHeader) 
            {
                $removeParams.Add("HostHeader", $params.HostHeader)
            }
            else 
            {
                $removeParams.Add("WebApplication", $params.WebAppUrl)
            }

            Remove-SPManagedPath @removeParams -Confirm:$false
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
        $WebAppUrl,
        
        [Parameter(Mandatory = $true)]  
        [System.String]  
        $RelativeUrl,

        [Parameter(Mandatory = $true)]  
        [System.Boolean] 
        $Explicit,

        [Parameter(Mandatory = $true)]  
        [System.Boolean] 
        $HostHeader,

        [Parameter()] 
        [ValidateSet("Present","Absent")] 
        [System.String] 
        $Ensure = "Present",
        
        [Parameter()] 
        [System.Management.Automation.PSCredential] 
        $InstallAccount
    )

    Write-Verbose -Message "Testing managed path $RelativeUrl in $WebAppUrl"

    $PSBoundParameters.Ensure = $Ensure

    $CurrentValues = Get-TargetResource @PSBoundParameters

    return Test-SPDscParameterState -CurrentValues $CurrentValues `
                                    -DesiredValues $PSBoundParameters `
                                    -ValuesToCheck @("WebAppUrl",
                                                     "RelativeUrl",
                                                     "Explicit",
                                                     "HostHeader", 
                                                     "Ensure")
}

Export-ModuleMember -Function *-TargetResource
