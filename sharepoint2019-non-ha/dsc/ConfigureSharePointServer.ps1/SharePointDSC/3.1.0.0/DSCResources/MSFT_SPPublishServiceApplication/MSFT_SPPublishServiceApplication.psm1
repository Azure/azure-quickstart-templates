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
        [System.Management.Automation.PSCredential] 
        $InstallAccount,
        
        [Parameter()] 
        [ValidateSet("Present","Absent")] 
        [System.String] 
        $Ensure = "Present"
    )

    Write-Verbose -Message "Getting service application publish status '$Name'"

    $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                  -Arguments $PSBoundParameters `
                                  -ScriptBlock {
        $params = $args[0]
        
        $serviceApp = Get-SPServiceApplication -Name $params.Name -ErrorAction SilentlyContinue
        
        if ($null -eq $serviceApp) 
        {
            Write-Verbose -Message "The service application $Name does not exist"
            $sharedEnsure = "Absent"
        }

        if ($null -eq $serviceApp.Uri)
        {
            Write-Verbose -Message ("Only Business Data Connectivity, Machine Translation, Managed Metadata, " + `
                                    "User Profile, Search, Secure Store are supported to be published via DSC.")
            $sharedEnsure = "Absent"
        }
        else
        {
            if ($serviceApp.Shared -eq $true)
            {
                $sharedEnsure = "Present"
            }
            elseif ($serviceApp.Shared -eq $false)
            {
                $sharedEnsure = "Absent"
            }
        }  
               
        return @{
            Name = $params.Name
            Ensure = $sharedEnsure
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
        $Name,

        [Parameter()] 
        [System.Management.Automation.PSCredential] 
        $InstallAccount,
        
        [Parameter()] 
        [ValidateSet("Present","Absent")] 
        [System.String] 
        $Ensure = "Present"
    )

    Write-Verbose -Message "Setting service application publish status '$Name'"

    Invoke-SPDSCCommand -Credential $InstallAccount `
                        -Arguments $PSBoundParameters `
                        -ScriptBlock {
        $params = $args[0]
        
        $serviceApp = Get-SPServiceApplication -Name $params.Name -ErrorAction SilentlyContinue    
        if ($null -eq $serviceApp) 
        {
            throw [Exception] ("The service application $Name does not exist")
        }
        
        if ($null -eq $serviceApp.Uri)
        {
            throw [Exception] ("Only Business Data Connectivity, Machine Translation, Managed Metadata, " + `
                               "User Profile, Search, Secure Store are supported to be published via DSC.")
        }

        if ($Ensure -eq "Present") 
        {
            Write-Verbose -Message "Publishing Service Application $Name"
            Publish-SPServiceApplication -Identity $serviceApp            
        }

        if ($Ensure -eq "Absent") 
        {
            Write-Verbose -Message "Unpublishing Service Application $Name"            
            Unpublish-SPServiceApplication  -Identity $serviceApp
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
        [System.Management.Automation.PSCredential] 
        $InstallAccount,
        
        [Parameter()] 
        [ValidateSet("Present","Absent")] 
        [System.String] 
        $Ensure = "Present"
    )

    Write-Verbose -Message "Testing service application '$Name'"

    $currentValues = Get-TargetResource @PSBoundParameters

    return Test-SPDscParameterState -CurrentValues $CurrentValues `
                                    -DesiredValues $PSBoundParameters `
                                    -ValuesToCheck @("Name", "Ensure")
}

Export-ModuleMember -Function *-TargetResource
