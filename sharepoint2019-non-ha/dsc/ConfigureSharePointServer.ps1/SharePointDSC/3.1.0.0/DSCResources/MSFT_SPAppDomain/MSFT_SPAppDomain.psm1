function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String] 
        $AppDomain,

        [Parameter(Mandatory = $true)]  
        [System.String] 
        $Prefix,

        [Parameter()] 
        [System.Management.Automation.PSCredential] 
        $InstallAccount
    )

    Write-Verbose -Message "Getting app domain settings"

    $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                  -Arguments $PSBoundParameters `
                                  -ScriptBlock {
        $params = $args[0]
        $appDomain =  Get-SPAppDomain
        $prefix = Get-SPAppSiteSubscriptionName -ErrorAction Continue

        return @{
            AppDomain = $appDomain
            Prefix= $prefix
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
        $AppDomain,

        [Parameter(Mandatory = $true)]  
        [System.String] 
        $Prefix,

        [Parameter()] 
        [System.Management.Automation.PSCredential] 
        $InstallAccount
    )

    Write-Verbose -Message "Setting app domain settings"

    Invoke-SPDSCCommand -Credential $InstallAccount `
                        -Arguments $PSBoundParameters `
                        -ScriptBlock {
        $params = $args[0]
        
        Set-SPAppDomain $params.AppDomain
        Set-SPAppSiteSubscriptionName -Name $params.Prefix -Confirm:$false
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
        $AppDomain,

        [Parameter(Mandatory = $true)]  
        [System.String] 
        $Prefix,

        [Parameter()] 
        [System.Management.Automation.PSCredential] 
        $InstallAccount
    )

    Write-Verbose -Message "Getting app domain settings"

    return Test-SPDscParameterState -CurrentValues (Get-TargetResource @PSBoundParameters) `
                                    -DesiredValues $PSBoundParameters `
                                    -ValuesToCheck @("AppDomain", "Prefix") 
}

Export-ModuleMember -Function *-TargetResource
